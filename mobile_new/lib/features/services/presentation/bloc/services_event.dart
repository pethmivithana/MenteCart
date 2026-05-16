import 'package:equatable/equatable.dart';
import '../../domain/entities/service.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object?> get props => [];
}

class GetServicesEvent extends ServicesEvent {
  final int page;
  final int limit;
  final String? category;
  final String? search;

  const GetServicesEvent({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.search,
  });

  @override
  List<Object?> get props => [page, limit, category, search];
}

class GetServiceByIdEvent extends ServicesEvent {
  final String id;

  const GetServiceByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Select a slot for the service
class SelectSlotEvent extends ServicesEvent {
  final String serviceId;
  final ServiceSlot slot;

  const SelectSlotEvent({required this.serviceId, required this.slot});

  @override
  List<Object?> get props => [serviceId, slot];
}

/// Clear slot selection
class ClearSlotSelectionEvent extends ServicesEvent {
  const ClearSlotSelectionEvent();
}
