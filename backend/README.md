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
