import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/service.dart';
import '../../domain/usecases/get_service_by_id_usecase.dart';
import '../../domain/usecases/get_services_usecase.dart';
import 'services_event.dart';
import 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetServicesUseCase getServicesUseCase;
  final GetServiceByIdUseCase getServiceByIdUseCase;

  ServicesBloc(this.getServicesUseCase, this.getServiceByIdUseCase)
    : super(const ServicesInitial()) {
    on<GetServicesEvent>(_onGetServicesEvent);
    on<GetServiceByIdEvent>(_onGetServiceByIdEvent);
    on<SelectSlotEvent>(_onSelectSlotEvent);
    on<ClearSlotSelectionEvent>(_onClearSlotSelectionEvent);
  }

  Future<void> _onGetServicesEvent(
    GetServicesEvent event,
    Emitter<ServicesState> emit,
  ) async {
    emit(const ServicesLoading());
    final result = await getServicesUseCase(
      GetServicesParams(
        page: event.page,
        limit: event.limit,
        category: event.category,
        search: event.search,
      ),
    );
    result.fold(
      (failure) => emit(
        ServicesFailure(message: failure.message, errorCode: failure.errorCode),
      ),
      (response) => emit(
        ServicesSuccess(
          services: response.services,
          total: response.total,
          page: response.page,
          totalPages: response.totalPages,
          isLastPage: response.page >= response.totalPages,
        ),
      ),
    );
  }

  Future<void> _onGetServiceByIdEvent(
    GetServiceByIdEvent event,
    Emitter<ServicesState> emit,
  ) async {
    emit(const ServicesLoading());
    final result = await getServiceByIdUseCase(event.id);
    result.fold(
      (failure) => emit(
        ServicesFailure(message: failure.message, errorCode: failure.errorCode),
      ),
      (service) => emit(ServiceDetailSuccess(service)),
    );
  }

  Future<void> _onSelectSlotEvent(
    SelectSlotEvent event,
    Emitter<ServicesState> emit,
  ) async {
    // Validate slot is available
    if (event.slot.isFullyBooked) {
      emit(const SlotSelectionFailure('This slot is fully booked'));
      return;
    }

    // Emit state indicating slot was selected
    emit(
      SlotSelectedState(serviceId: event.serviceId, selectedSlot: event.slot),
    );
  }

  Future<void> _onClearSlotSelectionEvent(
    ClearSlotSelectionEvent event,
    Emitter<ServicesState> emit,
  ) async {
    if (state is ServiceDetailSuccess) {
      final current = state as ServiceDetailSuccess;
      emit(ServiceDetailSuccess(current.service, selectedSlot: null));
    }
  }
}
