import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/store_actions.dart';
import 'package:simple_store/src/store/default_store.dart';

/// A wrapper that tracks store usage and automatically cleans up when no longer needed
class StoreReference<T, A extends StoreActions<T>> {
  final StoreWithActions<T, A> store;
  final String key;
  int _referenceCount = 0;
  bool _isDestroyed = false;

  StoreReference(this.store, this.key);

  void incrementRef() {
    if (!_isDestroyed) {
      _referenceCount++;
    }
  }

  void decrementRef() {
    if (!_isDestroyed) {
      _referenceCount--;
      if (_referenceCount <= 0) {
        _destroy();
      }
    }
  }

  void _destroy() {
    if (!_isDestroyed) {
      _isDestroyed = true;
      store.destroy();
    }
  }

  bool get isDestroyed => _isDestroyed;
  int get referenceCount => _referenceCount;
}

/// A global registry for storing and accessing stores without providers
/// This enables Zustand-like direct store usage with automatic memory management
class GlobalStoreRegistry {
  static final GlobalStoreRegistry _instance = GlobalStoreRegistry._internal();
  factory GlobalStoreRegistry() => _instance;
  GlobalStoreRegistry._internal() {
    _setupLifecycleListener();
  }

  final Map<String, StoreReference> _stores = {};
  final Map<String, Function> _storeCreators = {};
  final Map<String, int> _usageCount = {};

  /// Set up Flutter lifecycle listener for automatic cleanup
  void _setupLifecycleListener() {
    try {
      // Only set up lifecycle listener if Flutter is properly initialized
      if (WidgetsBinding.instance.isRootWidgetAttached) {
        SystemChannels.lifecycle.setMessageHandler((String? message) async {
          if (message == AppLifecycleState.paused.toString() ||
              message == AppLifecycleState.detached.toString()) {
            // Clean up unused stores when app is paused or detached
            cleanupUnused();
          }
          return null;
        });
      }
    } catch (e) {
      // Silently fail if Flutter is not initialized (e.g., in tests)
      // The registry will still work, just without automatic lifecycle cleanup
    }
  }

  /// Register a store with a unique key
  void register<T, A extends StoreActions<T>>(
    String key,
    StoreWithActions<T, A> store,
  ) {
    if (_stores.containsKey(key)) {
      // If store already exists, destroy the old one
      _stores[key]!.store.destroy();
    }

    final storeRef = StoreReference<T, A>(store, key);
    storeRef.incrementRef(); // Initial reference
    _stores[key] = storeRef;
    _usageCount[key] = 1;
  }

  /// Register a store creator function for lazy initialization
  void registerCreator<T, A extends StoreActions<T>>(
    String key,
    StoreWithActions<T, A> Function() creator,
  ) {
    _storeCreators[key] = creator;
  }

  /// Get a store by key, creating it if it doesn't exist
  StoreWithActions<T, A> get<T, A extends StoreActions<T>>(String key) {
    if (_stores.containsKey(key)) {
      final storeRef = _stores[key]!;
      if (!storeRef.isDestroyed) {
        storeRef.incrementRef();
        _usageCount[key] = (_usageCount[key] ?? 0) + 1;
        return storeRef.store as StoreWithActions<T, A>;
      } else {
        // Store was destroyed, remove it
        _stores.remove(key);
        _usageCount.remove(key);
      }
    }

    if (_storeCreators.containsKey(key)) {
      final creator = _storeCreators[key]!;
      final store = creator() as StoreWithActions<T, A>;
      register(key, store);
      return store;
    }

    throw StateError('No store found for key: $key');
  }

  /// Release a reference to a store
  void release<T, A extends StoreActions<T>>(String key) {
    final storeRef = _stores[key];
    if (storeRef != null) {
      storeRef.decrementRef();
      _usageCount[key] = (_usageCount[key] ?? 1) - 1;

      if (storeRef.isDestroyed) {
        _stores.remove(key);
        _usageCount.remove(key);
      }
    }
  }

  /// Check if a store exists
  bool has(String key) {
    return _stores.containsKey(key) || _storeCreators.containsKey(key);
  }

  /// Remove a store from the registry (force cleanup)
  void remove(String key) {
    final storeRef = _stores[key];
    if (storeRef != null) {
      storeRef.store.destroy();
      _stores.remove(key);
      _usageCount.remove(key);
    }
    _storeCreators.remove(key);
  }

  /// Clear all stores
  void clear() {
    for (final storeRef in _stores.values) {
      storeRef.store.destroy();
    }
    _stores.clear();
    _storeCreators.clear();
    _usageCount.clear();
  }

  /// Get all registered store keys
  List<String> get keys => [..._stores.keys, ..._storeCreators.keys];

  /// Get the number of registered stores
  int get length => _stores.length + _storeCreators.length;

  /// Get usage statistics for debugging
  Map<String, int> get usageStats => Map.from(_usageCount);

  /// Clean up stores that have no references
  void cleanupUnused() {
    final keysToRemove = <String>[];

    for (final entry in _stores.entries) {
      final storeRef = entry.value;
      if (storeRef.referenceCount <= 0) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      remove(key);
    }
  }
}

/// Global instance of the store registry
final globalStoreRegistry = GlobalStoreRegistry();

/// Create a store and register it globally
/// This is the main entry point for creating global stores, similar to Zustand's create
StoreWithActions<T, A> createGlobalStore<T, A extends StoreActions<T>>({
  required String key,
  required StateCreator<T, SimpleStore<T>> state,
  required A Function(SimpleStore<T>) createActions,
  SimpleStore<T>? store,
}) {
  final storeWithActions = createStore<T, A>(
    state: state,
    createActions: createActions,
    store: store,
  );

  globalStoreRegistry.register(key, storeWithActions);
  return storeWithActions;
}

/// Create a store creator function for lazy initialization
Function createGlobalStoreCreator<T, A extends StoreActions<T>>({
  required String key,
  required StateCreator<T, SimpleStore<T>> state,
  required A Function(SimpleStore<T>) createActions,
}) {
  return () => createGlobalStore<T, A>(
    key: key,
    state: state,
    createActions: createActions,
  );
}

/// Get a global store by key
StoreWithActions<T, A> getGlobalStore<T, A extends StoreActions<T>>(
  String key,
) {
  return globalStoreRegistry.get<T, A>(key);
}

/// Release a reference to a global store
void releaseGlobalStore<T, A extends StoreActions<T>>(String key) {
  globalStoreRegistry.release<T, A>(key);
}

/// Check if a global store exists
bool hasGlobalStore(String key) {
  return globalStoreRegistry.has(key);
}

/// Remove a global store
void removeGlobalStore(String key) {
  globalStoreRegistry.remove(key);
}

/// Clear all global stores
void clearGlobalStores() {
  globalStoreRegistry.clear();
}

/// Clean up unused global stores
void cleanupUnusedGlobalStores() {
  globalStoreRegistry.cleanupUnused();
}
