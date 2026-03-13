import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/equality/equality.dart';

class DefaultStore<T> extends ChangeNotifier implements SimpleStore<T> {
  T _state;
  final List<StoreListener<T>> _listeners = [];
  final Equality<T> _equality;
  bool _isNotifying = false;
  bool _dirtyDuringNotify = false;
  bool _destroyed = false;
  final List<StoreListener<T>> _pendingAdditions = [];
  final Set<StoreListener<T>> _pendingRemovals = {};

  DefaultStore({Equality<T>? equality, required T initialState})
    : _equality = equality ?? createEquality<T>(),
      _state = initialState;

  void _cleanup() {
    if (_destroyed) return;
    _destroyed = true;
    _listeners.clear();
    _pendingAdditions.clear();
    _pendingRemovals.clear();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

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
    if (_destroyed) return false;
    if (_isNotifying) {
      if (!_listeners.contains(listener)) return false;
      _pendingRemovals.add(listener);
      return true;
    }
    return _listeners.remove(listener);
  }

  @override
  void setState(T Function(T currentState) updater) {
    if (_destroyed) return;

    final previousState = _state;
    final nextState = updater(previousState);

    if (_equality.equals(nextState, previousState)) return;

    _state = nextState;

    // If already notifying, mark dirty so the outer loop reruns after the
    // current pass completes. State is already written above.
    if (_isNotifying) {
      _dirtyDuringNotify = true;
      return;
    }

    _isNotifying = true;
    try {
      // do-while re-notifies if setState was called from within a listener.
      // iterationPrevious is advanced each pass so listeners always receive
      // the correct (currentState, previousState) pair.
      T iterationPrevious = previousState;
      do {
        _dirtyDuringNotify = false;
        final T iterationCurrent = _state;

        notifyListeners();

        // Iterate a snapshot to handle concurrent modifications safely.
        // Listeners in _pendingRemovals were unsubscribed during this pass.
        final listenersCopy = List<StoreListener<T>>.from(_listeners);
        for (final listener in listenersCopy) {
          if (!_pendingRemovals.contains(listener)) {
            listener(iterationCurrent, iterationPrevious);
          }
        }

        iterationPrevious = iterationCurrent;
      } while (_dirtyDuringNotify);
    } finally {
      _isNotifying = false;

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
  VoidCallback subscribe(StoreListener<T> listener) {
    if (_destroyed) return () {};

    if (_isNotifying) {
      // Queue for addition after notification is complete.
      _pendingAdditions.add(listener);
      return () => removeStoreListener(listener);
    }

    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
    return () => removeStoreListener(listener);
  }

  @override
  void destroy() {
    dispose();
  }

  /// Synchronously reads and transforms the current state using [selector].
  /// This is a one-shot read — it does NOT create a reactive subscription.
  /// For reactive selection, use [useStoreSelector] in a widget.
  @override
  U select<U>(Selector<T, U> selector) {
    return selector(_state);
  }

  @override
  StateGetter<T> getState() {
    return () => _state;
  }

  /// Returns the underlying [ChangeNotifier] for advanced framework integration.
  /// WARNING: Do NOT call [dispose], [addListener], or [removeListener] directly
  /// on this object — doing so bypasses the store's lifecycle management and
  /// will corrupt internal state. Use [subscribe]/[destroy] instead.
  @override
  ChangeNotifier get api => this;
}
