const db = require('../config/db');
const { sendEmail } = require('../utils/email');

exports.getComplaints = async (req, res) => {
  const page = +req.query.page || 1;
  const limit = 10;
  const offset = (page - 1) * limit;
  const userId = req.user.role === 'admin' ? null : req.user.id;

  try {
    let query = `
      SELECT c.*, u.name AS user_name, cat.name AS category_name
      FROM complaints c
      JOIN users u ON c.user_id = u.id
      JOIN categories cat ON c.category_id = cat.id
    `;
    let params = [];

    if (!userId) {
      query += ` ORDER BY c.created_at DESC LIMIT ? OFFSET ?`;
      params = [limit, offset];
    } else {
      query += ` WHERE c.user_id = ? ORDER BY c.created_at DESC LIMIT ? OFFSET ?`;
      params = [userId, limit, offset];
    }

    const [complaints] = await db.query(query, params);

    const [[{ total }]] = await db.query(
      `SELECT COUNT(*) AS total FROM complaints${userId ? ' WHERE user_id = ?' : ''}`,
      userId ? [userId] : []
    );

    res.json({
      complaints,
      total,
      page,
      pages: Math.ceil(total / limit)
    });
  } catch (err) {
    console.error('getComplaints error:', err);
    res.status(500).json({ message: 'Failed to fetch complaints' });
  }
};

exports.createComplaint = async (req, res) => {
  const { title, description, category_id, latitude, longitude } = req.body;
  const image_url = req.file ? `/uploads/${req.file.filename}` : null;

  try {
    const [result] = await db.query(
      `INSERT INTO complaints 
       (user_id, category_id, title, description, latitude, longitude, image_url)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [req.user.id, category_id, title, description, latitude, longitude, image_url]
    );

    const [rows] = await db.query(
      'SELECT * FROM complaints WHERE id = ?',
      [result.insertId]
    );

    const complaint = rows[0];

    /* =========================
       SAFE SOCKET EMIT (FIX)
    ========================= */
    if (req.io) {
      req.io.emit('complaintAdded', complaint);
    }

    /* =========================
       EMAIL (NON-BLOCKING)
    ========================= */
    try {
      await sendEmail(
        'admin@wms.com',
        'New Complaint Submitted',
        `Title: ${title}\nLocation: ${latitude}, ${longitude}`
      );
    } catch (emailErr) {
      console.error('Email send failed:', emailErr);
    }

    res.status(201).json(complaint);
  } catch (err) {
    console.error('createComplaint error:', err);
    res.status(400).json({ message: 'Failed to create complaint' });
  }
};

exports.updateStatus = async (req, res) => {
  const { status } = req.body;
  const { id } = req.params;

  try {
    await db.query(
      'UPDATE complaints SET status = ? WHERE id = ?',
      [status, id]
    );

    const [rows] = await db.query(
      'SELECT * FROM complaints WHERE id = ?',
      [id]
    );

    const complaint = rows[0];

    if (!complaint) {
      return res.status(404).json({ message: 'Complaint not found' });
    }

    const [[user]] = await db.query(
      'SELECT email FROM users WHERE id = ?',
      [complaint.user_id]
    );

    /* =========================
       SAFE EMAIL
    ========================= */
    try {
      await sendEmail(
        user.email,
        'Complaint Status Updated',
        `Your complaint status is now: ${status}`
      );
    } catch (emailErr) {
      console.error('Email send failed:', emailErr);
    }

    /* =========================
       SAFE SOCKET EMIT (FIX)
    ========================= */
    if (req.io) {
      req.io.emit('statusUpdated', complaint);
    }

    res.json(complaint);
  } catch (err) {
    console.error('updateStatus error:', err);
    res.status(400).json({ message: 'Failed to update status' });
  }
};
