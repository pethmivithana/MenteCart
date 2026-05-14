import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/service.dart';
import '../../domain/usecases/get_service_by_id_usecase.dart';

abstract class ServiceDetailEvent extends Equatable {
  const ServiceDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadServiceDetailEvent extends ServiceDetailEvent {
  final String serviceId;
  const LoadServiceDetailEvent(this.serviceId);
  @override
  List<Object?> get props => [serviceId];
}

abstract class ServiceDetailState extends Equatable {
  const ServiceDetailState();
  @override
  List<Object?> get props => [];
}

class ServiceDetailInitial extends ServiceDetailState {
  const ServiceDetailInitial();
}

class ServiceDetailLoading extends ServiceDetailState {
  const ServiceDetailLoading();
}

class ServiceDetailLoaded extends ServiceDetailState {
  final Service service;
  const ServiceDetailLoaded(this.service);
  @override
  List<Object?> get props => [service];
}

class ServiceDetailFailure extends ServiceDetailState {
  final String message;
  final String? errorCode;
  const ServiceDetailFailure({required this.message, this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}

class ServiceDetailBloc extends Bloc<ServiceDetailEvent, ServiceDetailState> {
  final GetServiceByIdUseCase _getServiceById;

  ServiceDetailBloc(this._getServiceById) : super(const ServiceDetailInitial()) {
    on<LoadServiceDetailEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadServiceDetailEvent event,
    Emitter<ServiceDetailState> emit,
  ) async {
    emit(const ServiceDetailLoading());
    final result = await _getServiceById(event.serviceId);
    result.fold(
      (failure) => emit(
        ServiceDetailFailure(
          message: failure.message,
          errorCode: failure.errorCode,
        ),
      ),
      (service) => emit(ServiceDetailLoaded(service)),
    );
  }
}
