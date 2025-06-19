import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/default_store.dart';

/// A wrapper for simplified stores
class SimpleStoreReference<T> {
  final SimpleStoreWithActions<T> store;
  final String key;
  int _referenceCount = 0;
  bool _isDestroyed = false;

  SimpleStoreReference(this.store, this.key);

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

  final Map<String, SimpleStoreReference> _simpleStores = {};
  final Map<String, int> _usageCount = {};

  /// Set up Flutter lifecycle listener for automatic cleanup
  void _setupLifecycleListener() {
    try {
      if (WidgetsBinding.instance.isRootWidgetAttached) {
        SystemChannels.lifecycle.setMessageHandler((String? message) async {
          if (message == AppLifecycleState.paused.toString() ||
              message == AppLifecycleState.detached.toString()) {
            cleanupUnused();
          }
          return null;
        });
      }
    } catch (e) {
      // Silently fail if Flutter is not initialized (e.g., in tests)
    }
  }

  /// Register a simplified store with a unique key
  void registerSimple<T>(String key, SimpleStoreWithActions<T> store) {
    if (_simpleStores.containsKey(key)) {
      _simpleStores[key]!.store.destroy();
    }
    final storeRef = SimpleStoreReference<T>(store, key);
    storeRef.incrementRef();
    _simpleStores[key] = storeRef;
    _usageCount[key] = 1;
  }

  /// Get a simplified store by key
  SimpleStoreWithActions<T> getSimple<T>(String key) {
    if (_simpleStores.containsKey(key)) {
      final storeRef = _simpleStores[key]!;
      if (!storeRef.isDestroyed) {
        storeRef.incrementRef();
        _usageCount[key] = (_usageCount[key] ?? 0) + 1;
        return storeRef.store as SimpleStoreWithActions<T>;
      } else {
        _simpleStores.remove(key);
        _usageCount.remove(key);
      }
    }
    throw StateError('No simple store found for key: $key');
  }

  /// Release a reference to a simplified store
  void releaseSimple<T>(String key) {
    final storeRef = _simpleStores[key];
    if (storeRef != null) {
      storeRef.decrementRef();
      _usageCount[key] = (_usageCount[key] ?? 1) - 1;
      if (storeRef.isDestroyed) {
        _simpleStores.remove(key);
        _usageCount.remove(key);
      }
    }
  }

  /// Check if a store exists
  bool has(String key) {
    return _simpleStores.containsKey(key);
  }

  /// Remove a store from the registry (force cleanup)
  void remove(String key) {
    final simpleStoreRef = _simpleStores[key];
    if (simpleStoreRef != null) {
      simpleStoreRef.store.destroy();
      _simpleStores.remove(key);
      _usageCount.remove(key);
    }
  }

  /// Clear all stores
  void clear() {
    for (final storeRef in _simpleStores.values) {
      storeRef.store.destroy();
    }
    _simpleStores.clear();
    _usageCount.clear();
  }

  /// Get all registered store keys
  List<String> get keys => [..._simpleStores.keys];

  /// Get the number of registered stores
  int get length => _simpleStores.length;

  /// Get usage statistics for debugging
  Map<String, int> get usageStats => Map.from(_usageCount);

  /// Clean up stores that have no references
  void cleanupUnused() {
    final keysToRemove = <String>[];
    for (final entry in _simpleStores.entries) {
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

final globalStoreRegistry = GlobalStoreRegistry();

/// Simplified global store creation - Zustand-like API
SimpleStoreWithActions<T> createGlobalStoreSimple<T>({
  required String key,
  required T Function(SetState<T> set) creator,
  SimpleStore<T>? store,
}) {
  final storeWithActions = create<T>(creator, store: store);
  globalStoreRegistry.registerSimple(key, storeWithActions);
  return storeWithActions;
}

Function createGlobalStoreCreatorSimple<T>({
  required String key,
  required T Function(SetState<T> set) creator,
}) {
  return () => createGlobalStoreSimple<T>(key: key, creator: creator);
}

SimpleStoreWithActions<T> getGlobalStoreSimple<T>(String key) {
  return globalStoreRegistry.getSimple<T>(key);
}

void releaseGlobalStoreSimple<T>(String key) {
  globalStoreRegistry.releaseSimple<T>(key);
}

bool hasGlobalStore(String key) {
  return globalStoreRegistry.has(key);
}

void removeGlobalStore(String key) {
  globalStoreRegistry.remove(key);
}

void clearGlobalStores() {
  globalStoreRegistry.clear();
}

void cleanupUnusedGlobalStores() {
  globalStoreRegistry.cleanupUnused();
}
