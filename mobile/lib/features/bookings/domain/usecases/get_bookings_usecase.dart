import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetBookingsUseCase extends UseCase<BookingListResponse, GetBookingsParams> {
  final BookingRepository repository;

  GetBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, BookingListResponse>> call(
    GetBookingsParams params,
  ) async {
    return await repository.getBookings(
      page: params.page,
      limit: params.limit,
      status: params.status,
    );
  }
}

class GetBookingsParams {
  final int page;
  final int limit;
  final String? status;

  GetBookingsParams({
    this.page = 1,
    this.limit = 10,
    this.status,
  });
}
