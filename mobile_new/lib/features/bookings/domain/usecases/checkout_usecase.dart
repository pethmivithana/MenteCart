import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CheckoutUseCase extends NoParamsUseCase<Booking> {
  final BookingRepository repository;

  CheckoutUseCase(this.repository);

  @override
  Future<Either<Failure, Booking>> call() async {
    return await repository.checkout();
  }
}
