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
  // Create a temporary state first (without actions)
  T tempState;
  try {
    tempState = creator(
      (_) => throw UnsupportedError(
        'setState not available during initialization',
      ),
    );
  } catch (e, stackTrace) {
    // L8: preserve the original stack trace.
    Error.throwWithStackTrace(
      ArgumentError('Failed to create initial state: $e'),
      stackTrace,
    );
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
  } catch (e, stackTrace) {
    internalStore.destroy();
    // L8: preserve the original stack trace.
    Error.throwWithStackTrace(
      ArgumentError('Failed to create state with actions: $e'),
      stackTrace,
    );
  }

  // H5: use the same Equality instance as the store so the guard here is
  // consistent with setState's equality check. Previously, identical() was
  // used here but Equality.equals() was used inside setState — if two objects
  // were structurally equal but not identical, identical() would trigger a
  // setState that the store then silently rejected, leaving the store holding
  // tempState while _stateWithActions held stateWithActions.
  final eq = equality ?? createEquality<T>();
  if (!eq.equals(tempState, stateWithActions)) {
    internalStore.setState((_) => stateWithActions);
  }

  return SimpleStoreInstance<T>(internalStore, stateWithActions, setState);
}
