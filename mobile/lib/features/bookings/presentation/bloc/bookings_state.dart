import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

abstract class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object?> get props => [];
}

class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

class BookingsSuccess extends BookingsState {
  final List<Booking> bookings;
  final int total;
  final int page;
  final int totalPages;
  final bool isLastPage;

  const BookingsSuccess({
    required this.bookings,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.isLastPage,
  });

  @override
  List<Object?> get props => [bookings, total, page, totalPages, isLastPage];
}

class BookingDetailSuccess extends BookingsState {
  final Booking booking;

  const BookingDetailSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class CheckoutSuccess extends BookingsState {
  final Booking booking;

  const CheckoutSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingsFailure extends BookingsState {
  final String message;
  final String? errorCode;

  const BookingsFailure({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}
