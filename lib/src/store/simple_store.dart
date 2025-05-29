import 'package:flutter/foundation.dart';

typedef StoreListener<T> = void Function(T state, T previousState);
typedef StateGetter<T> = T Function();
typedef Selector<T, U> = U Function(T state);

/// The core store API that exposes state management methods
abstract class SimpleStore<T> {
  /// Get the current state
  T get state;

  /// Initialize the store with an initial state
  /// This must be called before any other store operations
  void initialize(T initialState);

  /// Set state using a function that receives the current state
  void setState(T Function(T currentState) updater);

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

  /// Returns the current number of active listeners
  int get listenerCount;

  /// Checks if a specific listener is currently subscribed
  bool hasListener(StoreListener<T> listener);

  /// Removes a specific store listener from the store
  /// Returns true if the listener was found and removed, false otherwise
  bool removeStoreListener(StoreListener<T> listener);
}
