import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/equality/equality.dart';

class DefaultStore<T> extends ChangeNotifier implements SimpleStore<T> {
  late final ValueNotifier<T> _notifier;
  final List<StoreListener<T>> _listeners = [];
  final Equality<T> _equality;
  bool _initialized = false;
  bool _isNotifying = false;
  bool _destroyed = false;

  DefaultStore({Equality<T>? equality})
    : _equality = equality ?? createEquality<T>();

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
    // Use equality check instead of reference equality
    if (_equality.equals(nextState, previousState)) return;
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
