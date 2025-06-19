import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/store_actions.dart';

typedef StateCreator<T, StoreApi> = T Function(StoreApi store);

typedef ValueListener<T> = void Function(T value);

/// A wrapper class that provides type-safe access to store actions
class StoreWithActions<T, A extends StoreActions<T>> {
  final SimpleStore<T> _store;
  final A actions;

  StoreWithActions(this._store, this.actions);

  T get state => _store.state;
  void setState(T Function(T currentState) updater) => _store.setState(updater);
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
  SimpleStore<T>? store,
}) {
  // Create a mutable state holder
  final internalStore = store ?? DefaultStore<T>();

  // Use the creator function to initialize the store
  final initialState = state(internalStore);
  internalStore.initialize(initialState);

  // Create the strongly-typed actions object
  final typedActions = createActions(internalStore);

  return StoreWithActions(internalStore, typedActions);
}

class DefaultStore<T> extends ChangeNotifier implements SimpleStore<T> {
  late final ValueNotifier<T> _notifier;
  final List<StoreListener<T>> _listeners = [];
  bool _initialized = false;
  bool _isNotifying = false;

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
      for (final listener in _listeners) {
        listener(nextState, previousState);
      }
    } finally {
      _isNotifying = false;
    }
  }

  @override
  Function subscribe(StoreListener<T> listener) {
    _listeners.add(listener);
    // Also listen to ValueNotifier for Flutter widget rebuilds
    void valueListener() => listener(_notifier.value, _notifier.value);
    _notifier.addListener(valueListener);
    return () {
      _listeners.remove(listener);
      _notifier.removeListener(valueListener);
    };
  }

  @override
  void destroy() {
    _listeners.clear();
    _notifier.dispose();
    dispose();
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
