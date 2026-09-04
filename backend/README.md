# 🌿 Habit Tracker — Node.js & Express REST Backend

The official backend API for the **Habit Tracker** personal application, built using **Node.js**, **Express.js**, and **MongoDB** (with Mongoose).

---

## 🚀 Quick Start

1. Install dependencies:
   ```bash
   npm install
   ```
2. Configure `.env`:
   ```bash
   cp .env.example .env
   ```
3. Run the server:
   ```bash
   npm run dev
   ```
4. Run integration tests:
   ```bash
   npm test
   ```

---

## 🔒 Installation Scoping

All endpoints require or auto-generate an `x-installation-id` header to isolate personal data without requiring accounts, passwords, or emails.

---

## 📡 API Endpoints

- `GET /api/health` - Server health status
- `GET /api/habits` - Retrieve user habits
- `POST /api/habits` - Create a new habit
- `GET /api/completions` - Retrieve completions for a habit or date
- `POST /api/completions` - Record habit completion
- `POST /api/completions/undo` - Undo habit completion
- `GET /api/statistics/summary` - Habit completion summary
- `GET /api/statistics/trends` - Daily and weekly completion trends

