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

  VoidCallback subscribe(StoreListener<T> listener) =>
      _store.subscribe(listener);

  void destroy() => _store.destroy();

  U select<U>(Selector<T, U> selector) => _store.select(selector);

  StateGetter<T> getState() => _store.getState();

  ChangeNotifier get api => _store.api;
}

/// Creates a [SimpleStoreInstance] using a Zustand-style creator function.
///
/// IMPORTANT: [creator] is called **twice** during initialization:
/// 1. Once with a no-op `setState` to capture the initial state.
/// 2. Once with the real `setState` to bind actions to the store.
///
/// Any side effects in [creator] (timers, callbacks, logging) will run twice.
/// Keep [creator] pure — move side effects to actions that are called later.
SimpleStoreInstance<T> create<T>(
  T Function(SetState<T> set) creator, {
  SimpleStore<T>? store,
  Equality<T>? equality,
}) {
  T tempState;
  try {
    tempState = creator(
      (_) => throw UnsupportedError(
        'setState not available during initialization',
      ),
    );
  } catch (e, stackTrace) {
    Error.throwWithStackTrace(
      ArgumentError('Failed to create initial state: $e'),
      stackTrace,
    );
  }

  final internalStore =
      store ?? DefaultStore<T>(equality: equality, initialState: tempState);

  void setState(T Function(T currentState) updater) {
    internalStore.setState(updater);
  }

  T stateWithActions;
  try {
    stateWithActions = creator(setState);
  } catch (e, stackTrace) {
    internalStore.destroy();
    Error.throwWithStackTrace(
      ArgumentError('Failed to create state with actions: $e'),
      stackTrace,
    );
  }

  // Use the same Equality the store uses so this guard is consistent with
  // setState's own equality check.
  final eq = equality ?? createEquality<T>();
  if (!eq.equals(tempState, stateWithActions)) {
    internalStore.setState((_) => stateWithActions);
  }

  return SimpleStoreInstance<T>(internalStore, stateWithActions, setState);
}
