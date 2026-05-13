import 'package:equatable/equatable.dart';

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
