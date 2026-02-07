const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { protect, admin } = require('../middleware/auth');
const {
  getComplaints,
  createComplaint,
  updateStatus
} = require('../controllers/complaintController');

const UPLOAD_DIR = path.join(__dirname, '..', 'uploads');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOAD_DIR);
  },
  filename: (req, file, cb) => {
    cb(null, `img_${Date.now()}${path.extname(file.originalname)}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const types = /jpeg|jpg|png/;
    if (types.test(file.mimetype)) cb(null, true);
    else cb(new Error('Only JPEG/PNG allowed'));
  }
});

router.get('/', protect, getComplaints);

router.post(
  '/',
  protect,
  upload.single('image'),
  createComplaint
);

router.patch('/:id/status', protect, admin, updateStatus);

router.get('/categories', async (req, res) => {
  const db = require('../config/db');
  const [cats] = await db.query('SELECT id, name FROM categories');
  res.json(cats);
});

module.exports = router;
