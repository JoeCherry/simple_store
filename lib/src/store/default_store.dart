import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/simple_store.dart';

typedef SetState<T> = void Function(T Function(T currentState) updater);

typedef ValueListener<T> = void Function(T value);

/// A simplified store that provides Zustand-like API
/// Combines state and actions in a single object
class SimpleStoreWithActions<T> {
  final SimpleStore<T> _store;
  final T? _reactiveState;
  final T _stateWithActions;
  final SetState<T> _setState;

  SimpleStoreWithActions(
    this._store,
    this._stateWithActions,
    this._setState, [
    this._reactiveState,
  ]);

  T get state => _reactiveState ?? _store.state;

  /// Access the state with actions
  T get actions => _stateWithActions;

  /// Set state function (Zustand-like)
  void setState(T Function(T currentState) updater) => _setState(updater);

  Function subscribe(StoreListener<T> listener) => _store.subscribe(listener);

  void destroy() => _store.destroy();

  U select<U>(Selector<T, U> selector) => _store.select(selector);

  StateGetter<T> getState() => _store.getState();

  ChangeNotifier get api => _store.api;
}

/// Simplified store creation - Zustand-like API
/// Combines state and actions in a single function
SimpleStoreWithActions<T> create<T>(
  T Function(SetState<T> set) creator, {
  SimpleStore<T>? store,
}) {
  // Create a mutable state holder
  final internalStore = store ?? DefaultStore<T>();

  // Create the setState function
  void setState(T Function(T currentState) updater) {
    internalStore.setState(updater);
  }

  // Use the creator function to create the initial state with actions
  final stateWithActions = creator(setState);

  // Initialize the store with the state
  internalStore.initialize(stateWithActions);

  return SimpleStoreWithActions<T>(internalStore, stateWithActions, setState);
}

class DefaultStore<T> extends ChangeNotifier implements SimpleStore<T> {
  late final ValueNotifier<T> _notifier;
  final List<StoreListener<T>> _listeners = [];
  bool _initialized = false;
  bool _isNotifying = false;
  bool _destroyed = false;

  @override
  T get state => _notifier.value;

  @override
  void initialize(T initialState) {
    if (_initialized) {
      throw StateError('Store has already been initialized.');
    }
    _notifier = ValueNotifier<T>(initialState);
    _initialized = true;
  }

  @override
  int get listenerCount => _listeners.length;

  /// Checks if a specific listener is currently subscribed
  @override
  bool hasListener(StoreListener<T> listener) => _listeners.contains(listener);

  /// Removes a specific store listener from the store
  /// Returns true if the listener was found and removed, false otherwise
  @override
  bool removeStoreListener(StoreListener<T> listener) {
    return _listeners.remove(listener);
  }

  @override
  void setState(T Function(T currentState) updater) {
    final previousState = _notifier.value;
    final nextState = updater(previousState);
    if (nextState == previousState) return;
    _notifier.value = nextState;
    if (_isNotifying) return;
    _isNotifying = true;
    try {
      notifyListeners();
      // Create a copy to avoid concurrent modification
      final listenersCopy = List<StoreListener<T>>.from(_listeners);
      for (final listener in listenersCopy) {
        listener(nextState, previousState);
      }
    } finally {
      _isNotifying = false;
    }
  }

  @override
  Function subscribe(StoreListener<T> listener) {
    _listeners.add(listener);
    return () {
      _listeners.remove(listener);
    };
  }

  @override
  void destroy() {
    if (!_initialized || _destroyed) return;

    _listeners.clear();
    _notifier.dispose();
    dispose();
    _destroyed = true;
    _initialized = false;
  }

  @override
  U select<U>(Selector<T, U> selector) {
    return selector(_notifier.value);
  }

  @override
  StateGetter<T> getState() {
    return () => _notifier.value;
  }

  @override
  ChangeNotifier get api => this;
}
