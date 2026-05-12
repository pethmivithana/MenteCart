# MenteCart Backend API

Production-style Node.js + Express + TypeScript + MongoDB REST API for the MenteCart service booking platform.

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js 18+ |
| Framework | Express.js |
| Language | TypeScript 5.x |
| Database | MongoDB via Mongoose |
| Auth | JWT + bcrypt |
| Validation | Zod |
| Logging | Pino + pino-pretty |
| HTTP Logging | Morgan |

## Project Structure

```
backend/
├── src/
│   ├── config/           # DB connection, env validation
│   ├── controllers/      # Request handlers (thin layer)
│   ├── services/         # Business logic
│   ├── repositories/     # Data access layer
│   ├── models/           # Mongoose schemas
│   ├── routes/           # Express routers
│   ├── middlewares/      # Auth, validation, error handling
│   ├── validators/       # Zod schemas
│   ├── utils/            # ApiError, ApiResponse, asyncHandler, logger
│   ├── types/            # TypeScript interfaces
│   ├── app.ts            # Express app factory
│   └── server.ts         # Entry point
├── .env.example
├── package.json
└── tsconfig.json
```

## Setup & Run

### 1. Install dependencies
```bash
cd backend
npm install
```

### 2. Configure environment
```bash
cp .env.example .env
# Edit .env with your real MongoDB URI and JWT secret
```

### 3. Run in development
```bash
npm run dev
```

### 4. Build for production
```bash
npm run build
npm start
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `MONGODB_URI` | MongoDB connection string | — |
| `JWT_SECRET` | Secret for signing JWTs | — |
| `JWT_EXPIRES_IN` | JWT expiry duration | `1d` |
| `PORT` | HTTP port | `5000` |
| `NODE_ENV` | Environment | `development` |
| `BCRYPT_SALT_ROUNDS` | bcrypt cost factor | `10` |
| `CART_EXPIRY_HOURS` | Cart TTL in hours | `24` |
| `MAX_BOOKINGS_PER_DAY` | Max bookings per user per day | `5` |
| `CORS_ORIGIN` | Allowed CORS origin | `*` |

## API Endpoints

### Auth
| Method | Endpoint | Access | Description |
|---|---|---|---|
| POST | `/api/auth/signup` | Public | Register new user |
| POST | `/api/auth/login` | Public | Login and get JWT |
| GET | `/api/auth/me` | Private | Get current user |

### Services
| Method | Endpoint | Access | Description |
|---|---|---|---|
| GET | `/api/services` | Public | List services (paginated, filterable) |
| GET | `/api/services/:id` | Public | Get service by ID |

**Query params for GET /api/services:**
- `page`, `limit` — pagination
- `category` — filter by category
- `search` — full-text search
- `minPrice`, `maxPrice` — price range

### Cart
| Method | Endpoint | Access | Description |
|---|---|---|---|
| GET | `/api/cart` | Private | Get current user's cart |
| POST | `/api/cart/items` | Private | Add item to cart |
| PATCH | `/api/cart/items/:itemId` | Private | Update cart item |
| DELETE | `/api/cart/items/:itemId` | Private | Remove cart item |

### Bookings
| Method | Endpoint | Access | Description |
|---|---|---|---|
| POST | `/api/bookings/checkout` | Private | Convert cart to booking |
| GET | `/api/bookings` | Private | List user bookings |
| GET | `/api/bookings/:id` | Private | Get booking detail |
| POST | `/api/bookings/:id/cancel` | Private | Cancel a booking |

## Response Format

### Success
```json
{
  "success": true,
  "message": "Success",
  "data": { ... }
}
```

### Paginated
```json
{
  "success": true,
  "message": "Services fetched successfully",
  "data": [...],
  "pagination": {
    "total": 50,
    "page": 1,
    "limit": 10,
    "totalPages": 5
  }
}
```

### Error
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Human-readable error message",
  "errorCode": "MACHINE_READABLE_CODE"
}
```

## Business Rules

- Passwords hashed with bcrypt (10+ salt rounds)
- Slot capacity is checked and reserved atomically to prevent overbooking
- If checkout fails mid-way, all reserved slots are rolled back
- Carts expire after 24 hours (MongoDB TTL index)
- Maximum 5 bookings per user per day
- Only `pending` or `confirmed` bookings can be cancelled
- Cancellation releases the slot capacity back atomically
