import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/equality/equality.dart';

class DefaultStore<T> extends ChangeNotifier implements SimpleStore<T> {
  final ValueNotifier<T> _notifier;
  final List<StoreListener<T>> _listeners = [];
  final Equality<T> _equality;
  bool _isNotifying = false;
  bool _destroyed = false;
  final List<StoreListener<T>> _pendingAdditions = [];
  final List<StoreListener<T>> _pendingRemovals = [];

  DefaultStore({Equality<T>? equality, required T initialState})
    : _equality = equality ?? createEquality<T>(),
      _notifier = ValueNotifier<T>(initialState);

  void _cleanup() {
    if (!_destroyed) {
      _destroyed = true;
      _listeners.clear();
      _pendingAdditions.clear();
      _pendingRemovals.clear();
      _notifier.dispose();
    }
  }

  @override
  T get state => _notifier.value;

  @override
  int get listenerCount => _listeners.length;

  /// Checks if a specific listener is currently subscribed
  @override
  bool hasListener(StoreListener<T> listener) => _listeners.contains(listener);

  /// Removes a specific store listener from the store
  /// Returns true if the listener was found and removed, false otherwise
  @override
  bool removeStoreListener(StoreListener<T> listener) {
    if (_destroyed) return false;
    if (_isNotifying) {
      // Queue for removal after notification is complete
      _pendingRemovals.add(listener);
      return true;
    }
    return _listeners.remove(listener);
  }

  @override
  void setState(T Function(T currentState) updater) {
    if (_destroyed) return;

    final previousState = _notifier.value;
    final nextState = updater(previousState);

    // Use equality check to prevent unnecessary updates
    if (_equality.equals(nextState, previousState)) return;

    // Update the ValueNotifier first
    _notifier.value = nextState;

    // Don't notify if already notifying (prevents recursive notifications)
    if (_isNotifying) return;

    _isNotifying = true;
    try {
      // Notify ChangeNotifier listeners
      notifyListeners();

      // Process store listeners with proper concurrent modification handling
      final listenersCopy = List<StoreListener<T>>.from(_listeners);
      for (final listener in listenersCopy) {
        // Check if listener is still in the list (not removed during notification)
        if (_listeners.contains(listener) &&
            !_pendingRemovals.contains(listener)) {
          listener(nextState, previousState);
        }
      }
    } finally {
      _isNotifying = false;

      // Process pending additions and removals
      for (final l in _pendingRemovals) {
        _listeners.remove(l);
      }
      _pendingRemovals.clear();

      for (final l in _pendingAdditions) {
        if (!_listeners.contains(l)) {
          _listeners.add(l);
        }
      }
      _pendingAdditions.clear();
    }
  }

  @override
  Function subscribe(StoreListener<T> listener) {
    if (_destroyed) return () {};

    if (_isNotifying) {
      // Queue for addition after notification is complete
      _pendingAdditions.add(listener);
      return () => removeStoreListener(listener);
    }

    _listeners.add(listener);
    return () => removeStoreListener(listener);
  }

  @override
  void destroy() {
    if (_destroyed) return;

    _cleanup();
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
