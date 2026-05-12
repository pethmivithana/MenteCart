import 'package:equatable/equatable.dart';

abstract class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutEvent extends BookingsEvent {
  const CheckoutEvent();
}

class GetBookingsEvent extends BookingsEvent {
  final int page;
  final int limit;
  final String? status;

  const GetBookingsEvent({
    this.page = 1,
    this.limit = 10,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

class GetBookingByIdEvent extends BookingsEvent {
  final String id;

  const GetBookingByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CancelBookingEvent extends BookingsEvent {
  final String id;

  const CancelBookingEvent(this.id);

  @override
  List<Object?> get props => [id];
}
