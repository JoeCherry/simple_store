import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/equality/equality.dart';

class DefaultStore<T> extends ChangeNotifier implements SimpleStore<T> {
  // L2: plain field replaces ValueNotifier<T> — ValueNotifier's listener
  // infrastructure was never used; it was only a mutable box.
  T _state;
  final List<StoreListener<T>> _listeners = [];
  final Equality<T> _equality;
  bool _isNotifying = false;
  // C3: tracks whether setState was called while a notification pass was
  // already running, so we can re-run the loop after the current pass ends.
  bool _dirtyDuringNotify = false;
  bool _destroyed = false;
  final List<StoreListener<T>> _pendingAdditions = [];
  // L4: Set makes _pendingRemovals.contains() O(1) instead of O(n).
  final Set<StoreListener<T>> _pendingRemovals = {};

  DefaultStore({Equality<T>? equality, required T initialState})
    : _equality = equality ?? createEquality<T>(),
      _state = initialState;

  // L1: _cleanup is idempotent — the _destroyed guard means calling it more
  // than once is safe. dispose() is the single canonical teardown entry point.
  void _cleanup() {
    if (_destroyed) return;
    _destroyed = true;
    _listeners.clear();
    _pendingAdditions.clear();
    _pendingRemovals.clear();
    // L2: no _notifier.dispose() needed — plain field has no resources.
  }

  // L1: override dispose() so the Flutter framework (or InheritedWidget scope)
  // can tear down this store through the standard ChangeNotifier path.
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
      // L6: only queue (and return true) if the listener is actually registered.
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

    // L2: write to the plain field.
    _state = nextState;

    // C3: if already notifying, mark dirty so the outer loop reruns.
    // State has already been written above — notification is deferred.
    if (_isNotifying) {
      _dirtyDuringNotify = true;
      return;
    }

    _isNotifying = true;
    try {
      // C3 + H7: do-while ensures we re-notify if setState was called from
      // within a listener. H7: previousState is re-read from _state at the
      // start of each iteration so each pass delivers the correct pair.
      T iterationPrevious = previousState;
      do {
        _dirtyDuringNotify = false;
        final T iterationCurrent = _state;

        // Notify ChangeNotifier listeners.
        notifyListeners();

        // Process store listeners with proper concurrent modification handling.
        final listenersCopy = List<StoreListener<T>>.from(_listeners);
        for (final listener in listenersCopy) {
          // L4: only _pendingRemovals check needed — listenersCopy is a
          // snapshot so any listener added after this point is not in it;
          // any listener removed after the snapshot is in _pendingRemovals.
          if (!_pendingRemovals.contains(listener)) {
            listener(iterationCurrent, iterationPrevious);
          }
        }

        // H7: advance previousState for the next iteration.
        iterationPrevious = iterationCurrent;
      } while (_dirtyDuringNotify);
    } finally {
      _isNotifying = false;

      // Process pending removals and additions accumulated during notification.
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

    // L5: prevent duplicate registration on the normal (non-notifying) path.
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
    return () => removeStoreListener(listener);
  }

  @override
  void destroy() {
    // L1: delegate entirely to dispose() — one teardown path.
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
    // L7: _state is a plain field so it retains the last known value even
    // after destroy() — returning it is safe and useful for post-destroy reads.
    return () => _state;
  }

  /// Returns the underlying [ChangeNotifier] for advanced framework integration.
  /// WARNING: Do NOT call [dispose], [addListener], or [removeListener] directly
  /// on this object — doing so bypasses the store's lifecycle management and
  /// will corrupt internal state. Use [subscribe]/[destroy] instead.
  @override
  ChangeNotifier get api => this;
}
