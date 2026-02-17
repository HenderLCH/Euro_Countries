import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wishlist_state.dart';

// Cubit para manejar el estado de la wishlist

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit({
    required GetWishlistItems getWishlistItems,
    required RemoveFromWishlist removeFromWishlist,
    required ClearWishlist clearWishlist,
    required PerformWishlistStressTest performStressTest,
    required WishlistRepository wishlistRepository,
  })  : _getWishlistItems = getWishlistItems,
        _removeFromWishlist = removeFromWishlist,
        _clearWishlist = clearWishlist,
        _performStressTest = performStressTest,
        _wishlistRepository = wishlistRepository,
        super(const WishlistInitial()) {
    _wishlistSubscription =
        _wishlistRepository.wishlistChanges.listen(_onWishlistChanged);
  }

  final GetWishlistItems _getWishlistItems;
  final RemoveFromWishlist _removeFromWishlist;
  final ClearWishlist _clearWishlist;
  final PerformWishlistStressTest _performStressTest;
  final WishlistRepository _wishlistRepository;

  StreamSubscription<WishlistChangeEvent>? _wishlistSubscription;

  //Cargar los paises de la wishlist
  Future<void> loadWishlist() async {
    emit(const WishlistLoading());

    try {
      final items = await _getWishlistItems();
      emit(WishlistLoaded(items: items));
    } catch (e) {
      emit(WishlistError(message: e.toString()));
    }
  }

  Future<void> removeItem(String countryId) async {
    final currentState = state;

    List<WishlistItem>? currentItems;
    if (currentState is WishlistLoaded) {
      currentItems = currentState.items;
    } else if (currentState is WishlistStressTestCompleted) {
      currentItems = currentState.items;
    } else {
      return;
    }

    try {
      await _removeFromWishlist(countryId);

      final updatedItems =
          currentItems.where((item) => item.id != countryId).toList();

      emit(WishlistLoaded(items: updatedItems));
    } catch (e) {
      emit(WishlistError(message: 'Failed to remove item: $e'));
      emit(currentState);
    }
  }

// Stress Test para todos los paises europeos
  Future<void> runStressTest() async {
    emit(const WishlistStressTestRunning());

    try {
      final stopwatch = Stopwatch()..start();
      await _performStressTest();
      stopwatch.stop();

      final items = await _getWishlistItems();
      emit(
        WishlistStressTestCompleted(
          items: items,
          duration: stopwatch.elapsed,
        ),
      );
    } catch (e) {
      emit(WishlistError(message: 'Stress test failed: $e'));
    }
  }

  Future<void> clearWishlist() async {
    try {
      await _clearWishlist();
      emit(const WishlistLoaded(items: []));
    } catch (e) {
      emit(WishlistError(message: 'Failed to clear wishlist: $e'));
    }
  }

  Future<void> refresh() async {
    await loadWishlist();
  }

  void _onWishlistChanged(WishlistChangeEvent event) {
    final currentState = state;

    List<WishlistItem>? currentItems;
    if (currentState is WishlistLoaded) {
      currentItems = currentState.items;
    } else if (currentState is WishlistStressTestCompleted) {
      currentItems = currentState.items;
    } else {
      return;
    }

    switch (event.type) {
      case WishlistChangeType.added:
        if (event.countryId == '*BATCH*') {
          loadWishlist();
          return;
        }
        loadWishlist();
      case WishlistChangeType.removed:
        final updatedItems =
            currentItems.where((item) => item.id != event.countryId).toList();

        emit(WishlistLoaded(items: updatedItems));
      case WishlistChangeType.cleared:
        emit(const WishlistLoaded(items: []));
    }
  }

  @override
  Future<void> close() {
    _wishlistSubscription?.cancel();
    return super.close();
  }
}
