import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

/// Booking repository contract
abstract class BookingRepository {
  /// Create booking from cart items (checkout)
  Future<Either<Failure, Booking>> checkout();

  /// Get paginated list of bookings
  /// [page] - page number (1-indexed)
  /// [limit] - items per page
  /// [status] - optional status filter (pending, confirmed, completed, cancelled)
  Future<Either<Failure, BookingListResponse>> getBookings({
    int page = 1,
    int limit = 10,
    String? status,
  });

  /// Get booking by ID
  Future<Either<Failure, Booking>> getBookingById(String id);

  /// Cancel a booking
  Future<Either<Failure, Booking>> cancelBooking(String id);
}
