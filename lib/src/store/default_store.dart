import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/store_actions.dart';

typedef StateCreator<T, StoreApi> = T Function(StoreApi store);

/// A wrapper class that provides type-safe access to store actions
class StoreWithActions<T, A extends StoreActions<T>> {
  final SimpleStore<T> _store;
  final A actions;

  StoreWithActions(this._store, this.actions);

  T get state => _store.state;
  void setState(T Function(T currentState) updater) => _store.setState(updater);
  void setStateRaw(T nextState) => _store.setStateRaw(nextState);
  Function subscribe(StoreListener<T> listener) => _store.subscribe(listener);
  void destroy() => _store.destroy();
  U select<U>(Selector<T, U> selector) => _store.select(selector);
  StateGetter<T> getState() => _store.getState();
  ChangeNotifier get api => _store.api;
}

/// A function that creates a store from a state creator function and actions
/// This is the main entry point for creating a store, inspired by Zustand's API
StoreWithActions<T, A> createStore<T, A extends StoreActions<T>>({
  required StateCreator<T, SimpleStore<T>> state,
  required A Function(SimpleStore<T>) createActions,
}) {
  // Create a mutable state holder
  final store = DefaultStore<T>();

  // Use the creator function to initialize the store
  final initialState = state(store);
  store._state = initialState;

  // Create the strongly-typed actions object
  final typedActions = createActions(store);

  return StoreWithActions(store, typedActions);
}

class DefaultStore<T> extends ChangeNotifier implements SimpleStore<T> {
  late T _state;
  final List<StoreListener<T>> _listeners = [];
  bool _isNotifying = false;

  @override
  T get state => _state;

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
    final nextState = updater(_state);
    if (nextState == _state) return;

    final previousState = _state;
    _state = nextState;

    if (_isNotifying) return;

    _isNotifying = true;
    try {
      // First notify Flutter's change notifier system
      notifyListeners();

      // Then notify our custom listeners
      for (final listener in _listeners) {
        listener(_state, previousState);
      }
    } finally {
      _isNotifying = false;
    }
  }

  @override
  void setStateRaw(T nextState) {
    if (nextState == _state) return;

    final previousState = _state;
    _state = nextState;

    if (_isNotifying) return;

    _isNotifying = true;
    try {
      // First notify Flutter's change notifier system
      notifyListeners();

      // Then notify our custom listeners
      for (final listener in _listeners) {
        listener(_state, previousState);
      }
    } finally {
      _isNotifying = false;
    }
  }

  @override
  Function subscribe(StoreListener<T> listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  @override
  void destroy() {
    _listeners.clear();
    dispose();
  }

  @override
  U select<U>(Selector<T, U> selector) {
    return selector(_state);
  }

  @override
  StateGetter<T> getState() {
    return () => _state;
  }

  @override
  ChangeNotifier get api => this;
}
