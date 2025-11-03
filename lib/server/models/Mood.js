const mongoose = require('mongoose');

const MoodSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
  },
  date: {
    type: Date,
    required: true,
  },
  mood: {
    type: String,
    required: true,
  },
});

MoodSchema.index({ userId: 1, date: 1 }, { unique: true });

module.exports = mongoose.model('Mood', MoodSchema);
