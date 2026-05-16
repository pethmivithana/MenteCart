# MenteCart Booking Features Implementation Summary

## Changes Overview

This document summarizes the production-ready implementation of **8 critical booking features** for MenteCart.

---

## 1. SLOT CAPACITY MANAGEMENT ✅

### Models Updated
- **Service.ts**: 
  - Slot schema now includes: `startTime`, `endTime` (optional), `capacity`, `remainingCapacity`, and `bookedCount` (backward-compat)
  - Virtual `time` property maps to `startTime` for legacy compatibility
  - Added index on `availableSlots.date` + `availableSlots.startTime` for performance

### Repositories Enhanced
- **ServiceRepository.ts**:
  - `incrementSlotBookedCount()`: Uses MongoDB conditional update (`$gte remainingCapacity`) to atomically reserve capacity
  - `decrementSlotBookedCount()`: Releases capacity on cancellation or payment failure
  - Both operations update `remainingCapacity` and `bookedCount` in sync

### Checkout Flow (BookingService.ts)
- Validates slot exists and `remainingCapacity > 0`
- Atomically reserves capacity via `incrementSlotBookedCount()`
- Returns HTTP **409 Conflict** with message "Selected slot is fully booked" if unavailable
- On checkout failure: rolls back all reserved slots (transaction-safe)

### API Response
- Service detail endpoint now returns `remainingCapacity` in slot objects
- Frontend can display: available, limited, or fully booked status

---

## 2. CART EXPIRY SYSTEM ✅

### Configuration
- **env.ts**: Changed from `CART_EXPIRY_HOURS` → `CART_EXPIRY_MINUTES` (default: 15 minutes)
- `expiresAt` is set/refreshed when cart is upserted or items added

### Background Scheduler
- **cartExpiryScheduler.ts**: Runs every 60 seconds
  - Finds carts with `expiresAt <= now` and items present
  - Deletes expired carts
  - Logs deletion events
  - Non-blocking: failures don't crash server
- Started in `server.ts` during bootstrap

### CartRepository Updates
- `upsertCart()` and `addItem()` now use `CART_EXPIRY_MINUTES`
- TTL index ensures MongoDB auto-cleanup as fallback

### Checkout Validation (BookingService.ts)
- Checks `cart.expiresAt < now` before processing
- Returns HTTP **400 Bad Request** with "Cart session expired" if expired
- Error code: `CART_EXPIRED`

---

## 3. MAX BOOKINGS PER DAY ENFORCEMENT ✅

### Configuration
- **env.ts**: `MAX_BOOKINGS_PER_DAY` (default: 5, configurable)

### Helper Function
- **BookingUtils.ts**: `canUserBookMore(userId, date, limit)` → boolean
  - Unit-testable; returns whether user can create more bookings on the date
  - Uses `countBookingsOnDate()` from repository

### Validation in Checkout
- Executed in `BookingService.checkout()` before payment init
- Counts non-failed/non-cancelled bookings for today
- Returns HTTP **409 Conflict** with "Daily booking limit reached" if exceeded
- Error code: `BOOKING_LIMIT_REACHED`

---

## 4. BOOKING CANCELLATION FLOW ✅

### Backend Endpoint
- **POST /bookings/:id/cancel** (protected)
- Request body: `{ reason?: string }`

### Validation Rules
- Only owner can cancel (verified via `req.user.userId`)
- Cannot cancel completed/failed bookings
- Optionally: cannot cancel within `CANCELLATION_CUTOFF_HOURS` (env default: 2)
- **env.ts**: New config `CANCELLATION_CUTOFF_HOURS`

### Cancellation Logic (BookingService.ts)
- Validates transition: status must be pending/confirmed
- Checks cutoff: compares `now` vs slot start time
- Releases slot capacity: decrements `remainingCapacity` for each item
- Updates status → "cancelled" with timestamp + reason
- Writes audit log entry

### Response
- Returns updated booking with `cancelledAt` and `cancellationReason`
- HTTP **200 OK** on success
- HTTP **403 Forbidden** if not allowed
- HTTP **400 Bad Request** if within cutoff window

---

## 5. AUDIT LOGGING ✅

### Model
- **BookingAuditLog.ts**: New collection
  - Fields: `bookingId`, `previousStatus`, `newStatus`, `changedBy` (userId or 'system'), `reason`, `createdAt` (auto)
  - Index on `bookingId` + `createdAt` for fast lookup

### Helper Function
- **logBookingStatusChange.ts**: `logBookingStatusChange(bookingId, prevStatus, newStatus, changedBy?, reason?)`
  - Non-fatal; failures logged but don't block main flow
  - Called from `BookingRepository.updateStatus()`

### Audit Events Logged
1. **Booking Created**: previousStatus='none' → newStatus='pending', changedBy=userId
2. **Payment Success**: previousStatus='pending' → newStatus='confirmed', changedBy='system'
3. **Payment Failed**: previousStatus='pending' → newStatus='failed', changedBy='system'
4. **Booking Cancelled**: previousStatus=(pending|confirmed) → newStatus='cancelled', changedBy=userId, reason=cancellationReason
5. **Booking Completed**: previousStatus='confirmed' → newStatus='completed', changedBy='system'

---

## 6. STATUS TRANSITION GUARDS ✅

### Valid Transitions
```
pending    → [confirmed, failed, cancelled]
confirmed  → [completed, cancelled]
failed     → [] (terminal)
cancelled  → [] (terminal)
completed  → [] (terminal)
```

### Implementation
- **BookingRepository.updateStatus()**: Enforces transitions before update
- **BookingStatusTransitionHelper.ts**: Exported rules for testing
- Invalid transition → HTTP **409 Conflict** with errorCode `INVALID_STATUS_TRANSITION`

---

## 7. DEFENSIVE CHECKS ✅

### Null/Undefined Guards
- All async flows wrapped in try/catch with specific error types
- Booking/Payment lookups validate `null` result
- Item iteration checks for array presence: `booking.items && booking.items.length > 0`

### Duplicate Prevention
- Payment webhook idempotency: `payment.webhookProcessed` flag
- State checks before releasing capacity: don't release if already cancelled/failed

### Cart Expiry Validation
- **CartService.ts**: Updated to use both `startTime` and legacy `time` field
- Falls back to `bookedCount` if `remainingCapacity` undefined (for existing data)

### Error Codes by Feature

| Feature | Status | Error Code | Message |
|---------|--------|------------|---------|
| Slot Full | 409 | `SLOT_CAPACITY_EXCEEDED` | "Selected slot is fully booked" |
| Cart Expired | 400 | `CART_EXPIRED` | "Cart session expired" |
| Daily Limit | 409 | `BOOKING_LIMIT_REACHED` | "Daily booking limit reached" |
| Invalid Transition | 409 | `INVALID_STATUS_TRANSITION` | "Invalid status transition from X to Y" |
| Cancellation Cutoff | 403 | N/A | "Cannot cancel within 2 hour(s) of slot start" |
| Invalid Payment | 400 | `INVALID_PAYMENT` | "Payment has no associated booking" |

---

## 8. FILES CREATED/MODIFIED

### New Files
- `backend/src/models/BookingAuditLog.ts` — Audit log model
- `backend/src/bootstrap/cartExpiryScheduler.ts` — Expiry job
- `backend/src/services/BookingUtils.ts` — Helper: `canUserBookMore()`
- `backend/src/utils/logBookingStatusChange.ts` — Helper: audit logging
- `backend/src/utils/BookingStatusTransitionHelper.ts` — Transition rules + validator
- `backend/src/utils/SlotCapacityHelper.ts` — Slot capacity utilities

### Modified Files
- `backend/src/config/env.ts` — Changed CART_EXPIRY_HOURS → CART_EXPIRY_MINUTES; added CANCELLATION_CUTOFF_HOURS
- `backend/src/models/Service.ts` — Updated slot schema to include startTime, endTime, remainingCapacity; added virtual time
- `backend/src/repositories/ServiceRepository.ts` — Rewrite atomic operations to use remainingCapacity with conditional filters
- `backend/src/repositories/BookingRepository.ts` — Added transition validation, audit logging; enhanced methods
- `backend/src/repositories/CartRepository.ts` — Updated expiry calculation to use CART_EXPIRY_MINUTES
- `backend/src/services/BookingService.ts` — Checkout with new slot fields, capacity checks, cancellation with cutoff, defensive payment handling
- `backend/src/services/CartService.ts` — Updated slot lookups to support both startTime and legacy time
- `backend/src/server.ts` — Added cart expiry scheduler startup
- `backend/seed_data.js` — Added normalization: `time` → `startTime`, set `remainingCapacity = capacity`

---

## API Endpoints Summary

### Existing (Unchanged)
- `GET /api/services` — Lists services with availableSlots
- `POST /api/bookings/checkout` — Initiates booking with full capacity checks
- `GET /api/bookings` — Lists user's bookings
- `GET /api/bookings/:id` — Gets booking detail
- `POST /api/bookings/webhook/payhere` — Payment webhook

### Modified (Request/Response Enhanced)
- `GET /api/bookings/:id` — Service detail now includes `remainingCapacity` per slot
- `POST /api/bookings/checkout` — Enforces daily limit before payment init
- Payment webhook — Audit logs payment success/failure

### New
- `POST /api/bookings/:id/cancel` — Cancels booking with validation

---

## Testing Checklist

- [ ] Concurrent checkout on same slot (validates atomic operation)
- [ ] Cart expiry after 15+ minutes (verify scheduler cleanup)
- [ ] Exceed daily booking limit (returns 409)
- [ ] Cancel within 2-hour cutoff (returns 403)
- [ ] Invalid status transition (returns 409)
- [ ] Idempotent payment webhook (processes once)
- [ ] Audit log entries created for each transition
- [ ] Slot capacity released on payment failure
- [ ] Legacy seed data normalizes correctly (time → startTime)

---

## Environment Variables (Updated)

```bash
# Cart expiry in minutes (default: 15)
CART_EXPIRY_MINUTES=15

# Max bookings per calendar day (default: 5)
MAX_BOOKINGS_PER_DAY=5

# Hours before slot start time when cancellation is blocked (default: 2)
CANCELLATION_CUTOFF_HOURS=2
```

---

## Next Steps (Frontend)

1. Update Flutter Booking BLoC to call `POST /bookings/:id/cancel`
2. Add cancel button + confirmation dialog in booking detail screen
3. Display remaining slot capacity in service/checkout screens
4. Show cart expiry countdown and auto-refresh on expiry
5. Handle all error codes: `SLOT_CAPACITY_EXCEEDED`, `CART_EXPIRED`, `BOOKING_LIMIT_REACHED`, etc.
6. Refresh bookings list after successful cancellation

---

## Production Readiness Notes

✅ **Atomic Operations**: Uses MongoDB conditional updates to prevent race conditions  
✅ **Non-Blocking Failures**: Audit logging and cleanup jobs fail gracefully  
✅ **Rollback on Error**: Checkout releases all reserved slots if any step fails  
✅ **Comprehensive Logging**: All transitions logged with timestamps and audit trail  
✅ **Error Codes**: Consistent, typed error responses for client handling  
✅ **Backward Compatibility**: Legacy `time` field supported via virtual property  
✅ **Configuration**: All limits/durations externalized to env variables  

---
