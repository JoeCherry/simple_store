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
  // Create a mutable state holder
  final internalStore = store ?? DefaultStore<T>(equality: equality);

  // Create the setState function
  void setState(T Function(T currentState) updater) {
    internalStore.setState(updater);
  }

  // Use the creator function to create the initial state with actions
  final stateWithActions = creator(setState);

  // Initialize the store with the state
  internalStore.initialize(stateWithActions);

  return SimpleStoreInstance<T>(internalStore, stateWithActions, setState);
}
