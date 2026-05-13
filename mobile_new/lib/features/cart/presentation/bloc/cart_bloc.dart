import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_cart_item_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_cart_item_usecase.dart';
import '../../domain/usecases/update_cart_item_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddCartItemUseCase addItemUseCase;
  final UpdateCartItemUseCase updateItemUseCase;
  final RemoveCartItemUseCase removeItemUseCase;

  CartBloc(
    this.getCartUseCase,
    this.addItemUseCase,
    this.updateItemUseCase,
    this.removeItemUseCase,
  ) : super(const CartInitial()) {
    on<GetCartEvent>(_onGetCartEvent);
    on<AddCartItemEvent>(_onAddCartItemEvent);
    on<UpdateCartItemEvent>(_onUpdateCartItemEvent);
    on<RemoveCartItemEvent>(_onRemoveCartItemEvent);
  }

  Future<void> _onGetCartEvent(
    GetCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    final result = await getCartUseCase();
    result.fold(
      (failure) => emit(
        CartFailure(
          message: failure.message,
          errorCode: failure.errorCode,
        ),
      ),
      (cart) {
        if (cart.items.isEmpty) {
          emit(const CartEmpty());
        } else {
          emit(CartSuccess(cart));
        }
      },
    );
  }

  Future<void> _onAddCartItemEvent(
    AddCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    final result = await addItemUseCase(
      AddCartItemParams(
        serviceId: event.serviceId,
        serviceName: event.serviceName,
        price: event.price,
        quantity: event.quantity,
        selectedDate: event.selectedDate,
        selectedSlot: event.selectedSlot,
      ),
    );
    result.fold(
      (failure) => emit(
        CartFailure(
          message: failure.message,
          errorCode: failure.errorCode,
        ),
      ),
      (_) => add(const GetCartEvent()),
    );
  }

  Future<void> _onUpdateCartItemEvent(
    UpdateCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    final result = await updateItemUseCase(
      UpdateCartItemParams(
        itemId: event.itemId,
        quantity: event.quantity,
        selectedDate: event.selectedDate,
        selectedSlot: event.selectedSlot,
      ),
    );
    result.fold(
      (failure) => emit(
        CartFailure(
          message: failure.message,
          errorCode: failure.errorCode,
        ),
      ),
      (_) => add(const GetCartEvent()),
    );
  }

  Future<void> _onRemoveCartItemEvent(
    RemoveCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    final result = await removeItemUseCase(event.itemId);
    result.fold(
      (failure) => emit(
        CartFailure(
          message: failure.message,
          errorCode: failure.errorCode,
        ),
      ),
      (_) => add(const GetCartEvent()),
    );
  }
}
