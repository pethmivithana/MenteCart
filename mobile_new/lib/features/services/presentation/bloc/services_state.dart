import 'package:equatable/equatable.dart';
import '../../domain/entities/service.dart';

abstract class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object?> get props => [];
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

class ServicesSuccess extends ServicesState {
  final List<Service> services;
  final int total;
  final int page;
  final int totalPages;
  final bool isLastPage;

  const ServicesSuccess({
    required this.services,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.isLastPage,
  });

  @override
  List<Object?> get props => [services, total, page, totalPages, isLastPage];
}

class ServiceDetailSuccess extends ServicesState {
  final Service service;
  final ServiceSlot? selectedSlot;

  const ServiceDetailSuccess(this.service, {this.selectedSlot});

  @override
  List<Object?> get props => [service, selectedSlot];
}

/// Slot has been selected - could navigate to add to cart
class SlotSelectedState extends ServicesState {
  final String serviceId;
  final ServiceSlot selectedSlot;

  const SlotSelectedState({
    required this.serviceId,
    required this.selectedSlot,
  });

  @override
  List<Object?> get props => [serviceId, selectedSlot];
}

/// Slot selection was invalid (e.g., fully booked)
class SlotSelectionFailure extends ServicesState {
  final String message;

  const SlotSelectionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServicesFailure extends ServicesState {
  final String message;
  final String? errorCode;

  const ServicesFailure({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}
