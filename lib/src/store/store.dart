import 'package:flutter/foundation.dart';

typedef StoreListener<T> = void Function(T state, T previousState);
typedef StateGetter<T> = T Function();
typedef Selector<T, U> = U Function(T state);

/// The core store API that exposes state management methods
abstract class Store<T> {
  /// Get the current state
  T get state;

  /// Set state using a function that receives the current state
  void setState(T Function(T currentState) updater);

  /// Replace the entire state
  void setStateRaw(T nextState);

  /// Add a listener that will be called when the state changes
  Function subscribe(StoreListener<T> listener);

  /// Destroy the store and clean up resources
  void destroy();

  /// Select a slice of state using a selector function
  U select<U>(Selector<T, U> selector);

  /// Get a state getter function
  StateGetter<T> getState();

  /// Get the raw store implementation (for advanced usage)
  ChangeNotifier get api;
}
