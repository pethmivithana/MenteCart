import 'dart:async';
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

  Timer? _expiryTimer;

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
    on<StartCartTimerEvent>(_onStartCartTimerEvent);
    on<StopCartTimerEvent>(_onStopCartTimerEvent);
    on<CartTimerTickEvent>(_onCartTimerTickEvent);
  }

  Future<void> _onGetCartEvent(
    GetCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    final result = await getCartUseCase();
    result.fold(
      (failure) {
        // Check if it's a cart expiry failure
        if (failure.runtimeType.toString().contains('CartExpiredFailure')) {
          emit(const CartExpired());
          _stopExpiryTimer();
        } else {
          emit(
            CartFailure(message: failure.message, errorCode: failure.errorCode),
          );
        }
      },
      (cart) {
        if (cart.items.isEmpty) {
          emit(const CartEmpty());
          _stopExpiryTimer();
        } else {
          final timeRemaining = cart.timeUntilExpiry;
          emit(CartSuccess(cart, timeRemaining: timeRemaining));

          // Auto-start timer if cart has expiry
          if (timeRemaining != null && timeRemaining.inSeconds > 0) {
            add(const StartCartTimerEvent());
          }
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
        CartFailure(message: failure.message, errorCode: failure.errorCode),
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
        CartFailure(message: failure.message, errorCode: failure.errorCode),
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
        CartFailure(message: failure.message, errorCode: failure.errorCode),
      ),
      (_) => add(const GetCartEvent()),
    );
  }

  Future<void> _onStartCartTimerEvent(
    StartCartTimerEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartSuccess) return;

    final cartState = state as CartSuccess;
    final expiresAt = cartState.cart.expiresAt;

    if (expiresAt == null) return;

    _stopExpiryTimer();

    // Check every second
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(expiresAt)) {
        // Cart has expired
        add(const StopCartTimerEvent());
        emit(const CartExpired());
      } else {
        final remaining = expiresAt.difference(now);
        add(CartTimerTickEvent(remaining));
      }
    });
  }

  Future<void> _onStopCartTimerEvent(
    StopCartTimerEvent event,
    Emitter<CartState> emit,
  ) async {
    _stopExpiryTimer();
  }

  Future<void> _onCartTimerTickEvent(
    CartTimerTickEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartSuccess) {
      final current = state as CartSuccess;
      emit(CartSuccess(current.cart, timeRemaining: event.remaining));
    }
  }

  void _stopExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
  }

  @override
  Future<void> close() {
    _stopExpiryTimer();
    return super.close();
  }
}
