import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetBookingByIdUseCase extends UseCase<Booking, String> {
  final BookingRepository repository;

  GetBookingByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Booking>> call(String id) async {
    return await repository.getBookingById(id);
  }
}
