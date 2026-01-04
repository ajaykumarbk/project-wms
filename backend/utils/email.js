const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

const sendEmail = (to, subject, text) => {
  transporter.sendMail({
    from: `"Waste Management" <${process.env.EMAIL_USER}>`,
    to, subject, text
  }, (err) => {
    if (err) console.error('Email error:', err);
  });
};

module.exports = { sendEmail };