import 'package:flutter/foundation.dart';

typedef StoreListener<T> = void Function(T state, T previousState);
typedef StateGetter<T> = T Function();
typedef Selector<T, U> = U Function(T state);

/// The core store API that exposes state management methods
abstract class SimpleStore<T> {
  /// Get the current state
  T get state;

  /// Set state using a function that receives the current state
  void setState(T Function(T currentState) updater);

  /// Add a listener that will be called when the state changes
  VoidCallback subscribe(StoreListener<T> listener);

  /// Destroy the store and clean up resources
  void destroy();

  /// Synchronously reads and transforms the current state using [selector].
  /// This is a one-shot read — it does NOT create a reactive subscription.
  /// For reactive selection, use [useStoreSelector] in a widget.
  U select<U>(Selector<T, U> selector);

  /// Get a state getter function
  StateGetter<T> getState();

  /// Returns the underlying [ChangeNotifier] for advanced framework integration.
  /// WARNING: Do NOT call [dispose], [addListener], or [removeListener] directly
  /// on this object — doing so bypasses the store's lifecycle management and
  /// will corrupt internal state. Use [subscribe]/[destroy] instead.
  ChangeNotifier get api;

  /// Returns the current number of active listeners
  int get listenerCount;

  /// Checks if a specific listener is currently subscribed
  bool hasListener(StoreListener<T> listener);

  /// Removes a specific store listener from the store
  /// Returns true if the listener was found and removed, false otherwise
  bool removeStoreListener(StoreListener<T> listener);
}
