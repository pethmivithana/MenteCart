# 🛒 MenteCart – Service Booking Platform

MenteCart is a full-stack service booking system where users can browse services, add them to a cart, select time slots, and complete bookings with secure payment handling.

Unlike traditional e-commerce systems, MenteCart focuses on **time-based service reservations**, slot capacity management, and real-world booking constraints.

---

## 🚀 Live System Overview

* 🧑 User Authentication (JWT-based)
* 🛎️ Service browsing with categories & search
* 🕒 Slot-based booking system with capacity control
* 🛒 Cart system with expiration handling
* 💳 Payment integration (PayHere sandbox)
* 📊 Booking lifecycle management (pending → confirmed → completed / cancelled)
* 🔐 Audit logging for all booking state transitions

---

## 🧱 Tech Stack

### Backend

* Node.js + Express
* TypeScript
* MongoDB + Mongoose
* JWT Authentication
* Docker + Docker Compose

### Mobile App

* Flutter (latest stable)
* Dart 3.x
* BLoC State Management
* Dio HTTP client

### Infrastructure

* Dockerized backend + MongoDB
* Environment-based configuration

---

## 🏗️ Architecture

```
Flutter App
   ↓
REST API (Node.js + Express)
   ↓
MongoDB (Docker container)
```

---

## ⚙️ Key Features

### 🔐 Authentication

* Secure signup/login with bcrypt hashing
* JWT token-based authentication
* Protected routes

---

### 🛎️ Services Module

* Browse services with pagination
* Category filtering & search
* Service details with available slots

---

### 🕒 Slot Booking System

* Time-slot based reservations
* Capacity tracking per slot
* Prevention of overbooking (atomic DB operations)

---

### 🛒 Cart System

* Multi-service cart support
* Slot-based item selection
* Auto-expiry after 15 minutes
* Cart cleanup background job

---

### 💳 Payment Flow

* PayHere sandbox integration
* Webhook-based payment verification
* Booking confirmed only after backend validation

---

### 📦 Booking System

* Full lifecycle:

  * pending → confirmed → completed
  * cancelled / failed states
* Cancellation rules with cutoff validation
* Booking history per user

---

### 📊 Audit Logging

* Every booking state change is logged
* Tracks:

  * previous status
  * new status
  * timestamp
  * actor

---

## 🐳 Docker Setup

### Run Backend + MongoDB

```bash
docker compose up --build
```

### Services included:

* Backend API → `http://localhost:5000`
* MongoDB → `mongodb://mongo:27017/mentecart`

---

## 📦 Environment Variables

Create `.env` inside backend:

```
MONGODB_URI=mongodb://mongo:27017/mentecart
JWT_SECRET=your_secret
JWT_EXPIRES_IN=1d
PORT=5000

PAYHERE_MERCHANT_ID=xxxx
PAYHERE_SECRET=xxxx
PAYHERE_API_URL=https://sandbox.payhere.lk/pay/checkout
```

---

## 📱 Flutter Setup

Run app with:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:5000

```

---

## 📁 Project Structure

```
backend/
  src/
    controllers/
    services/
    repositories/
    models/
    routes/

mobile/
  lib/
    presentation/
    bloc/
    data/
    core/
```

---

## ⚠️ Known Limitations

* Payment gateway runs only in sandbox mode
* No admin dashboard implemented
* Email notifications not integrated
* Redis caching not included (optional enhancement)

---

## 🎯 What Makes This Project Stand Out

* Real-world booking constraints (slot capacity + expiry)
* Atomic database operations to prevent overbooking
* Webhook-based payment verification
* Clean layered architecture
* Dockerized backend environment
* Production-style error handling and audit logging

---

## 🎥 Demo Video

A walkthrough video demonstrating:

* User signup/login
* Browsing services
* Adding services to cart
* Slot selection
* Checkout flow
* Booking confirmation
* Cancellation flow
* Payment simulation (sandbox)

---

## 👨‍💻 Author

Built as a full-stack engineering project demonstrating production-level architecture, clean code practices, and real-world system design thinking.
