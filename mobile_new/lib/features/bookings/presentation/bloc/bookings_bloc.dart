import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/get_booking_by_id_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';
import 'bookings_event.dart';
import 'bookings_state.dart';

/// Base API URL - update to match your backend
const _backendBaseUrl = 'http://10.0.2.2:5000';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final CheckoutUseCase checkoutUseCase;
  final GetBookingsUseCase getBookingsUseCase;
  final GetBookingByIdUseCase getBookingByIdUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  BookingsBloc(
    this.checkoutUseCase,
    this.getBookingsUseCase,
    this.getBookingByIdUseCase,
    this.cancelBookingUseCase,
  ) : super(const BookingsInitial()) {
    on<CheckoutEvent>(_onCheckoutEvent);
    on<GetBookingsEvent>(_onGetBookingsEvent);
    on<GetBookingByIdEvent>(_onGetBookingByIdEvent);
    on<CancelBookingEvent>(_onCancelBookingEvent);
  }

  Future<void> _onCheckoutEvent(
    CheckoutEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(const BookingsLoading());

    // returnUrl: where PayHere redirects the user after payment
    // notifyUrl: PayHere calls this backend endpoint with payment status
    const returnUrl = 'mentecart://payment-result';
    const notifyUrl = '$_backendBaseUrl/api/bookings/webhook/payhere';

    final result = await checkoutUseCase(
      CheckoutParams(returnUrl: returnUrl, notifyUrl: notifyUrl),
    );

    result.fold(
      (failure) => emit(
        BookingsFailure(message: failure.message, errorCode: failure.errorCode),
      ),
      (checkoutResponse) {
        emit(
          CheckoutSuccess(
            checkoutResponse.booking,
            paymentResponse: checkoutResponse.paymentDetails,
          ),
        );
      },
    );
  }

  Future<void> _onGetBookingsEvent(
    GetBookingsEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(const BookingsLoading());
    final result = await getBookingsUseCase(
      GetBookingsParams(
        page: event.page,
        limit: event.limit,
        status: event.status,
      ),
    );
    result.fold(
      (failure) => emit(
        BookingsFailure(message: failure.message, errorCode: failure.errorCode),
      ),
      (response) => emit(
        BookingsSuccess(
          bookings: response.bookings,
          total: response.total,
          page: response.page,
          totalPages: response.totalPages,
          isLastPage: response.page >= response.totalPages,
        ),
      ),
    );
  }

  Future<void> _onGetBookingByIdEvent(
    GetBookingByIdEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(const BookingsLoading());
    final result = await getBookingByIdUseCase(event.id);
    result.fold(
      (failure) => emit(
        BookingsFailure(message: failure.message, errorCode: failure.errorCode),
      ),
      (booking) => emit(BookingDetailSuccess(booking)),
    );
  }

  Future<void> _onCancelBookingEvent(
    CancelBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(const CancellationLoading());
    final result = await cancelBookingUseCase(event.id);
    result.fold(
      (failure) => emit(
        BookingsFailure(message: failure.message, errorCode: failure.errorCode),
      ),
      (booking) => emit(CancellationSuccess(booking)),
    );
  }
}
