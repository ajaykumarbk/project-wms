// backend/routes/tipRoutes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { protect, admin } = require('../middleware/auth');

// GET all tips (public)
router.get('/', async (req, res) => {
  try {
    const page = +req.query.page || 1;
    const limit = 10;
    const offset = (page - 1) * limit;

    const [tips] = await db.query(
      'SELECT * FROM recycling_tips ORDER BY created_at DESC LIMIT ? OFFSET ?',
      [limit, offset]
    );

    const [[{ total }]] = await db.query('SELECT COUNT(*) as total FROM recycling_tips');

    res.json({
      tips,
      total,
      page,
      pages: Math.ceil(total / limit)
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET single tip
router.get('/:id', async (req, res) => {
  try {
    const [tips] = await db.query('SELECT * FROM recycling_tips WHERE id = ?', [req.params.id]);
    if (tips.length === 0) return res.status(404).json({ message: 'Tip not found' });
    res.json(tips[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// CREATE tip (admin only)
router.post('/', protect, admin, async (req, res) => {
  const { title, content, image_url } = req.body;
  if (!title || !content) return res.status(400).json({ message: 'Title and content required' });

  try {
    const [result] = await db.query(
      'INSERT INTO recycling_tips (title, content, image_url) VALUES (?, ?, ?)',
      [title, content, image_url || null]
    );
    const [newTip] = await db.query('SELECT * FROM recycling_tips WHERE id = ?', [result.insertId]);
    res.status(201).json(newTip[0]);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// UPDATE tip (admin only)
router.put('/:id', protect, admin, async (req, res) => {
  const { title, content, image_url } = req.body;
  try {
    await db.query(
      'UPDATE recycling_tips SET title = ?, content = ?, image_url = ? WHERE id = ?',
      [title, content, image_url || null, req.params.id]
    );
    const [updated] = await db.query('SELECT * FROM recycling_tips WHERE id = ?', [req.params.id]);
    res.json(updated[0]);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// DELETE tip (admin only)
router.delete('/:id', protect, admin, async (req, res) => {
  try {
    await db.query('DELETE FROM recycling_tips WHERE id = ?', [req.params.id]);
    res.json({ message: 'Tip deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;