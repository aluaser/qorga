const express = require('express');
const connectDB = require('./db');
const User = require('./models/User.js');
const Mood = require('./models/Mood.js');
const bcrypt = require('bcryptjs');
const cors = require('cors');
require('dotenv').config();

const nodemailer = require('nodemailer');
const crypto = require('crypto');

const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'blebpio@gmail.com',
    pass: 'utjc jnqp zztn pbgi',
  },
});

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const aiModel = genAI.getGenerativeModel({
  model: "gemini-2.5-flash-preview-09-2025",
  systemInstruction: "You are 'Qorga', a friendly and supportive AI assistant for students in Kazakhstan. Your role is to provide helpful, safe, and encouraging answers to their questions. If a student seems to be in serious mental distress, gently suggest they talk to a trusted adult or a professional. Do not give medical or legal advice. Keep your answers clear, supportive, and respectful. Do not use * symbol or bold text in your responses.",
});

app.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Өтініш, барлық өрістерді толтырңыз' });
  }
  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: 'Пайдаланушы тіркеліп қойған' });
    }
    user = new User({ name, email, password });
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);
    await user.save();
    res.status(201).json({
      msg: 'Пайдаланушы сәтті тіркелді!',
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Жарамсыз тіркелгі деректері' });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Жарамсыз тіркелгі деректері' });
    }
    res.json({
      msg: 'Кіру сәтті өтті',
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

app.get('/users', async (req, res) => {
  try {
    const users = await User.find({}).select('-password');
    res.json(users);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

app.put("/user/:id", async (req, res) => {
  const { id } = req.params;
  const { name, email, password } = req.body;
  try {
    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ message: "Пайдаланушы табылмады" });
    }
    const updates = {
      name: name,
      email: email,
    };
    if (password && password.length >= 6) {
      const salt = await bcrypt.genSalt(10);
      updates.password = await bcrypt.hash(password, salt);
    }
    const updatedUser = await User.findByIdAndUpdate(id, updates, { new: true });
    res.status(200).json({
      message: "Профиль сәтті жаңартылды!",
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        name: updatedUser.name,
      },
    });
  } catch (error) {
    if (error.code === 11000 && error.keyPattern && error.keyPattern.email) {
      return res.status(400).json({ message: "Бұл email-мен басқа аккаунт тіркелген." });
    }
    console.error("Profile update error:", error);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

app.post('/ask-ai', async (req, res) => {
  const { prompt } = req.body;
  if (!prompt) {
    return res.status(400).json({ message: 'Prompt is required' });
  }
  try {
    const result = await aiModel.generateContent(prompt);
    const response = await result.response;
    const text = response.text();
    res.json({ text: text });
  } catch (err) {
    console.error("AI Error:", err.message);
    res.status(500).json({ message: 'AI-мен сөйлесу кезінде қате пайда болды' });
  }
});

app.post('/mood', async (req, res) => {
  const { userId, date, mood, note } = req.body;
  if (!userId || !date || !mood) {
    return res.status(400).json({ message: 'userId, date, and mood are required' });
  }
  const entryDate = new Date(date);
  entryDate.setUTCHours(0, 0, 0, 0);
  try {
    const updatedMood = await Mood.findOneAndUpdate(
      { userId: userId, date: entryDate },
      { mood: mood, note: note },
      { new: true, upsert: true }
    );
    res.status(200).json(updatedMood);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

app.get('/mood/stats', async (req, res) => {
  const { userId, month, year } = req.query;
  if (!userId || !month || !year) {
    return res.status(400).json({ message: 'userId, month, and year are required' });
  }
  const startDate = new Date(Date.UTC(year, month - 1, 1));
  const endDate = new Date(Date.UTC(year, month, 0, 23, 59, 59));
  try {
    const stats = await Mood.aggregate([
      {
        $match: {
          userId: userId,
          date: { $gte: startDate, $lte: endDate },
        },
      },
      {
        $group: {
          _id: '$mood',
          count: { $sum: 1 },
        },
      },
    ]);
    res.json(stats);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

app.get('/mood/by-date', async (req, res) => {
  const { userId, date } = req.query;
  if (!userId || !date) {
    return res.status(400).json({ message: 'userId and date are required' });
  }
  const entryDate = new Date(date);
  entryDate.setUTCHours(0, 0, 0, 0);
  try {
    const mood = await Mood.findOne({ userId: userId, date: entryDate });
    if (!mood) {
      return res.status(404).json({ message: 'Mood not found' });
    }
    res.json(mood);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

app.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Егер email дұрыс болса, код жіберіледі' });
    }
    const resetCode = crypto.randomInt(1000, 9999).toString();
    const resetCodeExpires = Date.now() + 10 * 60 * 1000;
    user.resetPasswordCode = resetCode;
    user.resetPasswordExpires = resetCodeExpires;
    await user.save();
    try {
      await transporter.sendMail({
        from: '"Qorga App" <blebpio@gmail.com>',
        to: user.email,
        subject: 'Qorga App - Құпия сөзді қалпына келтіру коды',
        html: `
          <p>Сәлеметсіз бе!</p>
          <p>Құпия сөзді қалпына келтіру үшін сіздің кодыңыз:</p>
          <h2 style="font-size: 24px; letter-spacing: 2px;"><b>${resetCode}</b></h2>
          <p>Бұл код 10 минут жарамды.</p>
          <p>Егер сіз бұл сұрауды жасамасаңыз, осы хатты елемеңіз.</p>
        `,
      });
      console.log(`Код сброса ${resetCode} отправлен на ${user.email}`);
      res.status(200).json({
        ok: true,
        message: 'Код жіберілді',
        testCode: resetCode,
      });
    } catch (mailError) {
      console.error('Email жіберу қатесі:', mailError);
      return res.status(500).json({ message: 'Email жіберу кезінде қате орын алды' });
    }
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

app.post('/reset-password', async (req, res) => {
  const { email, code, newPassword } = req.body;
  if (!email || !code || !newPassword) {
    return res.status(400).json({ message: 'Барлық өрістерді толтырыңыз' });
  }
  try {
    const user = await User.findOne({
      email: email,
      resetPasswordCode: code,
      resetPasswordExpires: { $gt: Date.now() },
    });
    if (!user) {
      return res.status(400).json({ message: 'Код қате немесе ескірген' });
    }
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    user.resetPasswordCode = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();
    res.status(200).json({
      ok: true,
      message: 'Құпия сөз сәтті жаңартылды!',
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server started on port ${PORT} `));
