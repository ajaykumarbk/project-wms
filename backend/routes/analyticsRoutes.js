// backend/routes/analyticsRoutes.js
const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { protect, admin } = require('../middleware/auth');

router.get('/', protect, admin, async (req, res) => {
  try {
    const [[complaints]] = await db.query('SELECT COUNT(*) as total FROM complaints');
    const [[pending]] = await db.query('SELECT COUNT(*) as total FROM complaints WHERE status = "pending"');
    const [[resolved]] = await db.query('SELECT COUNT(*) as total FROM complaints WHERE status = "resolved"');
    const [[users]] = await db.query('SELECT COUNT(*) as total FROM users WHERE role = "user"');

    const [byCategory] = await db.query(`
      SELECT c.name, COUNT(comp.id) as count 
      FROM complaints comp 
      JOIN categories c ON comp.category_id = c.id 
      GROUP BY c.id
    `);

    res.json({
      totalComplaints: complaints.total,
      pending: pending.total,
      resolved: resolved.total,
      users: users.total,
      byCategory
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;