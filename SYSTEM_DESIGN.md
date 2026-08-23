# System Design Document — Society Maintenance Tracker

This document outlines the architectural decisions and design models implemented to meet the core evaluation requirements of the Society Maintenance Tracker platform. 

---

## 1. Complaint Lifecycle and Status History Design

A core requirement is ensuring every status change (`OPEN` → `IN_PROGRESS` → `RESOLVED`) is immutably recorded with a timestamp, the actor's identity, and an optional note. 

**Implementation Model:**
We implemented an **append-only audit log pattern** using a dedicated `ComplaintHistory` table in PostgreSQL, linked to the main `Complaint` table via a foreign key relationship.

- **The `Complaint` Table:** Holds the current, definitive state of the ticket (e.g., status, priority, category, description).
- **The `ComplaintHistory` Table:** Acts as an immutable ledger. Whenever an admin updates the status of a complaint, the backend service uses Prisma ORM to execute a database transaction. This transaction atomically updates the `Complaint` table's status *and* inserts a new row into the `ComplaintHistory` table.

**Why this design?**
Storing the history in a separate table ensures data integrity. It prevents "split-brain" scenarios where the current status might contradict the history logs. The transactional approach guarantees that an audit log is never missed when a status changes, providing full transparency to residents tracking their tickets.

---

## 2. Overdue Detection and Priority Handling

Admins need to easily identify complaints that have been open for too long so they can be prioritized.

**Implementation Model:**
We implemented a background CRON scheduler using the `node-cron` package. 

- **Threshold Configuration:** The system relies on a configurable environment constant (`OVERDUE_THRESHOLD_DAYS`, currently set to 3 days).
- **Detection Job:** The scheduler runs a daily check against the database for any complaints that are not in the `RESOLVED` state where the `createdAt` timestamp is older than the `OVERDUE_THRESHOLD_DAYS`.
- **Flagging:** When identified, the complaint is updated with an `isOverdue: true` boolean flag. 
- **Priority Management:** Admins can manually set and update a ticket's priority (`Low`, `Medium`, `High`). On the admin dashboard, overdue complaints are automatically pulled to the top of the queue and visually highlighted in red, regardless of their standard priority, ensuring they are not ignored.

---

## 3. Photo Upload and Notice Board Design

The system must handle media assets (photos attached to complaints) and support a community announcement board.

**Photo Upload Implementation:**
Since modern backend deployments (like Render) use ephemeral, stateless containers, saving files to local disk results in data loss during restarts. 
To solve this, we implemented stateless, direct-to-cloud media storage using **Cloudinary**. When a resident uploads a photo, the Express backend receives the `multipart/form-data` stream and pipes it directly to Cloudinary. The database simply stores the returned secure URL string (`imageUrl`), keeping the application lightweight and scalable.

**Notice Board Design:**
The notice board is driven by the `Notice` database schema. Admins can create announcements with a title and content. 
To satisfy the requirement of "important" notices, the schema includes an `isPinned` boolean flag. When the frontend fetches notices, it sorts the query to ensure all `isPinned = true` notices are anchored at the top of the feed for maximum visibility.

---

## 4. Notification Flow

Residents must be proactively updated regarding their complaints and important community news without needing to constantly check the portal.

**Implementation Model:**
We integrated the **Resend API** (a robust, free-tier friendly transactional email provider) into a dedicated `EmailService` utility.

The notification flow operates on an event-driven basis within the controllers:
1. **Status Updates:** When an admin updates a ticket, after the database transaction successfully commits the new `ComplaintHistory` log, the controller invokes `EmailService.sendStatusUpdateEmail()`. The resident receives an email containing the new status and the admin's note.
2. **Pinned Notices:** When an admin creates a new notice with the `isPinned` flag checked, the controller invokes `EmailService.sendImportantNoticeEmail()`, fetching all registered resident emails and broadcasting the announcement.

**Trade-offs:** 
Email dispatching adds minor latency to the HTTP request cycle. However, by handling the dispatch asynchronously after the database commit, we prevent third-party API delays from blocking the user interface.

---

## 5. Dashboard and Reporting

The application aggregates raw complaint data into actionable insights for the administrator.

**Implementation Model:**
The `/api/dashboard` route executes complex Prisma aggregation queries (`groupBy` and `count`) to calculate:
1. Total complaints split by status (Open, In Progress, Resolved).
2. Total complaints split by category (Plumbing, Electrical, etc.).
3. Total active overdue complaints.

This raw numerical data is passed to the React frontend, which visualizes it using clean metric cards and charting libraries, providing the admin with an instant bird's-eye view of society operations.
