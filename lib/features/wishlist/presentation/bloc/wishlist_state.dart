part of 'wishlist_cubit.dart';

@immutable
sealed class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

final class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

final class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

final class WishlistLoaded extends WishlistState {
  const WishlistLoaded({
    required this.items,
  });

  final List<WishlistItem> items;

  @override
  List<Object?> get props => [items];

  WishlistLoaded copyWith({
    List<WishlistItem>? items,
  }) {
    return WishlistLoaded(
      items: items ?? this.items,
    );
  }
}

final class WishlistError extends WishlistState {
  const WishlistError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class WishlistStressTestRunning extends WishlistState {
  const WishlistStressTestRunning();
}

final class WishlistStressTestCompleted extends WishlistState {
  const WishlistStressTestCompleted({
    required this.items,
    required this.duration,
  });

  final List<WishlistItem> items;
  final Duration duration;

  @override
  List<Object?> get props => [items, duration];
}
