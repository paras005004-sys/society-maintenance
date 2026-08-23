# Society Maintenance Tracker

A web-based platform designed to coordinate maintenance requests and community announcements within a residential building complex. The system enables residents to raise and track complaints with supporting photos, while providing administrators with a central management dashboard, overdue tracking, and pinned community notices.

## 🚀 Live Hosted Application

- **Frontend (Vercel):** [https://societymaintenance.pancred.space](https://societymaintenance.pancred.space)
- **Backend API (Render):** [https://society-maintenance-mkgu.onrender.com/api](https://society-maintenance-mkgu.onrender.com/api)

## ✨ Core Features (Assignment Scope)

### 1. Resident Features
- **Authentication:** Residents can securely register and log in via JWT role-based authentication.
- **Raise Complaints:** Submit maintenance issues with a specific category, detailed description, and optional photo attachment (handled via Cloudinary).
- **Track Status:** View a personal dashboard of all raised complaints, including a full timestamped history of status updates.
- **Email Notifications:** Receive automated emails (via Resend) whenever a complaint's status changes or a new pinned notice is published.

### 2. Admin Features
- **Complaint Management:** View all incoming complaints. Filter by category, status, or date, and assign a priority level (`Low`, `Medium`, `High`).
- **Status Lifecycle:** Update ticket statuses (`OPEN` → `IN_PROGRESS` → `RESOLVED`). Every change is immutably logged with the admin's name, a timestamp, and an optional note.
- **Overdue Detection:** A background scheduler automatically flags complaints that stay open beyond a configurable threshold, pinning them to the top of the admin dashboard for urgent attention.
- **Notice Board:** Post announcements to the community notice board. Important notices can be pinned to the top of the feed and instantly broadcasted via email.
- **Reporting Dashboard:** View aggregated metrics of total complaints by status, category, and overdue counts.

## 📚 Documentation
Detailed documentation is available in the `/docs` directory:
- [API Documentation](./docs/api-reference.md)
- [Database Schema](./docs/database-schema.md)
- [System Design Write-up](./SYSTEM_DESIGN.md)
- [Deployment Guide](./docs/deployment.md)

## 🛠️ Tech Stack

- **Frontend:** React, Vite, Vanilla CSS
- **Backend:** Node.js, Express.js
- **Database:** PostgreSQL (with Prisma ORM)
- **Storage:** Cloudinary
- **Email:** Resend

## 💻 Local Setup Guide

### 1. Prerequisites
Ensure you have [Node.js](https://nodejs.org/) (v20+) and [PostgreSQL](https://www.postgresql.org/) installed on your machine.

### 2. Installation
Clone the repository and install dependencies for both the client and server:

```bash
# Clone the repository
git clone https://github.com/paras005004-sys/society-maintenance.git
cd society-maintenance

# Install server dependencies
cd server
npm install

# Install client dependencies
cd ../client
npm install
```

### 3. Environment Variables
Reference the `.env.example` file in the root directory.
Create a `.env` file inside the `server/` directory and populate it with your database credentials and API keys:

```env
PORT=6000
DATABASE_URL="postgresql://username:password@localhost:5432/society_db"
JWT_SECRET="your_secure_jwt_secret"
JWT_EXPIRES_IN=7d
CLIENT_URL="http://localhost:5173"
CLOUDINARY_CLOUD_NAME="your_cloudinary_name"
CLOUDINARY_API_KEY="your_cloudinary_api_key"
CLOUDINARY_API_SECRET="your_cloudinary_api_secret"
RESEND_API_KEY="your_resend_api_key"
FROM_EMAIL="onboarding@resend.dev"
```

Create a `.env` file inside the `client/` directory:
```env
VITE_API_URL="http://localhost:6000/api"
```

### 4. Database Setup (Prisma)
From the `server/` directory, push the schema to your local database and seed the default roles/users:

```bash
npx prisma db push
npm run db:seed
```

*(This creates a default admin: `admin@society.com` / `admin@123`)*

### 5. Start the Application
Open two terminal windows to run the frontend and backend concurrently:

```bash
# Terminal 1: Start Backend Server
cd server
npm run dev

# Terminal 2: Start Frontend Client
cd client
npm run dev
```

The application will now be running at `http://localhost:5173`.
