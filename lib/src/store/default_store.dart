import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/store.dart';

typedef StateCreator<T, StoreApi> = T Function(StoreApi store);

/// A function that creates a store from a state creator function
/// This is the main entry point for creating a store, inspired by Zustand's API
Store<T> createStore<T>(StateCreator<T, Store<T>> creator) {
  // Create a mutable state holder
  final store = DefaultStore<T>();

  // Use the creator function to initialize the store
  final initialState = creator(store);
  store._state = initialState;

  return store;
}

class DefaultStore<T> extends ChangeNotifier implements Store<T> {
  late T _state;
  final List<StoreListener<T>> _listeners = [];
  bool _isNotifying = false;

  @override
  T get state => _state;

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
