import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CheckoutResponse {
  final Booking booking;
  final Map<String, dynamic>? paymentDetails;

  CheckoutResponse({required this.booking, this.paymentDetails});
}

class CheckoutUseCase extends UseCase<CheckoutResponse, CheckoutParams> {
  final BookingRepository repository;

  CheckoutUseCase(this.repository);

  @override
  Future<Either<Failure, CheckoutResponse>> call(CheckoutParams params) async {
    return await repository.checkout(
      returnUrl: params.returnUrl,
      notifyUrl: params.notifyUrl,
    );
  }
}

class CheckoutParams {
  final String returnUrl;
  final String notifyUrl;

  CheckoutParams({required this.returnUrl, required this.notifyUrl});
}
