import 'package:flutter/widgets.dart';
import 'package:simple_store/src/equality/equality.dart';
import 'package:simple_store/src/store/default_store.dart';
import 'package:simple_store/src/store/simple_store.dart';

typedef SetState<T> = void Function(T Function(T currentState) updater);
typedef ValueListener<T> = void Function(T value);

class SimpleStoreInstance<T> {
  final SimpleStore<T> _store;
  final T? _reactiveState;
  final T _stateWithActions;
  final SetState<T> _setState;

  SimpleStoreInstance(
    this._store,
    this._stateWithActions,
    this._setState, [
    this._reactiveState,
  ]);

  T get state => _reactiveState ?? _store.state;

  /// Access the state with actions
  T get actions => _stateWithActions;

  /// Set state function (Zustand-like) - now accessible directly on the store
  SetState<T> get setState => _setState;

  Function subscribe(StoreListener<T> listener) => _store.subscribe(listener);

  void destroy() => _store.destroy();

  U select<U>(Selector<T, U> selector) => _store.select(selector);

  StateGetter<T> getState() => _store.getState();

  ChangeNotifier get api => _store.api;
}

/// Simplified store creation - Zustand-like API
/// Combines state and actions in a single function
SimpleStoreInstance<T> create<T>(
  T Function(SetState<T> set) creator, {
  SimpleStore<T>? store,
  Equality<T>? equality,
}) {
  // Create a temporary state first (without actions)
  T tempState;
  try {
    tempState = creator(
      (_) =>
          throw UnsupportedError(
            'setState not available during initialization',
          ),
    );
  } catch (e) {
    throw ArgumentError('Failed to create initial state: $e');
  }

  // Create the store with the temporary state
  final internalStore =
      store ?? DefaultStore<T>(equality: equality, initialState: tempState);

  // Create the setState function
  void setState(T Function(T currentState) updater) {
    internalStore.setState(updater);
  }

  // Create the final state with actions
  T stateWithActions;
  try {
    stateWithActions = creator(setState);
  } catch (e) {
    internalStore.destroy();
    throw ArgumentError('Failed to create state with actions: $e');
  }

  // Update the store with the final state (if different)
  if (!identical(tempState, stateWithActions)) {
    internalStore.setState((_) => stateWithActions);
  }

  return SimpleStoreInstance<T>(internalStore, stateWithActions, setState);
}
