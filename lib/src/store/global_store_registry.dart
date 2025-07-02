import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_store/simple_store.dart';
import 'package:simple_store/src/store/utils/map_extension.dart';

/// A wrapper for simplified stores
class SimpleStoreReference<T> {
  final SimpleStoreInstance<T> store;
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
class GlobalStoreRegistry {
  static GlobalStoreRegistry? _instance;
  static GlobalStoreRegistry get instance {
    _instance ??= GlobalStoreRegistry._internal();
    return _instance!;
  }

  /// Reset the singleton instance (mainly for testing)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }

  final Map<String, SimpleStoreReference> _simpleStores = {};
  bool _isDisposed = false;
  bool _lifecycleListenerRegistered = false;
  bool _isInitialized = false;

  GlobalStoreRegistry._internal();

  /// Initialize the registry with lifecycle management
  /// Call this when your app starts to enable automatic cleanup
  void initialize() {
    if (_isDisposed || _isInitialized) return;

    _isInitialized = true;
    _setupLifecycleListener();
  }

  /// Set up Flutter lifecycle listener for automatic cleanup
  void _setupLifecycleListener() {
    if (_lifecycleListenerRegistered) return;

    try {
      SystemChannels.lifecycle.setMessageHandler(_handleLifecycleMessage);
      _lifecycleListenerRegistered = true;
    } catch (e) {
      // Silently fail if Flutter is not initialized (e.g., in tests)
    }
  }

  /// Handle lifecycle messages and cleanup
  Future<String?> _handleLifecycleMessage(String? message) async {
    if (_isDisposed) return null;

    if (message == AppLifecycleState.paused.toString()) {
      cleanupUnused();
    }

    if (message == AppLifecycleState.detached.toString()) {
      dispose();
    }
    return null;
  }

  /// Dispose the registry and clean up all resources
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    clear();

    // Remove the lifecycle listener
    if (_lifecycleListenerRegistered) {
      try {
        SystemChannels.lifecycle.setMessageHandler(null);
        _lifecycleListenerRegistered = false;
      } catch (e) {
        // Ignore errors during cleanup
      }
    }
  }

  void registerStore<T>(String key, SimpleStoreInstance<T> store) {
    if (_isDisposed) return;
    if (!_isInitialized) {
      throw StateError(
        'GlobalStoreRegistry not initialized. Call initialize() first.',
      );
    }

    _simpleStores.elementFor(key)?.store.destroy();

    final storeRef = SimpleStoreReference<T>(store, key);
    storeRef.incrementRef();
    _simpleStores[key] = storeRef;
  }

  SimpleStoreInstance<T> getStore<T>(String key) {
    if (_isDisposed) {
      throw StateError('GlobalStoreRegistry has been disposed');
    }
    if (!_isInitialized) {
      throw StateError(
        'GlobalStoreRegistry not initialized. Call initialize() first.',
      );
    }

    final storeRef = _simpleStores[key];
    if (storeRef != null && !storeRef.isDestroyed) {
      storeRef.incrementRef();

      try {
        return storeRef.store as SimpleStoreInstance<T>;
      } catch (e) {
        throw StateError(
          'Type mismatch: expected SimpleStoreInstance<$T>, got ${storeRef.store.runtimeType}',
        );
      }
    } else if (storeRef != null && storeRef.isDestroyed) {
      _simpleStores.remove(key);
    }

    throw StateError('No simple store found for key: $key');
  }

  /// Release a reference to a simplified store
  void releaseStore<T>(String key) {
    if (_isDisposed) return;

    final storeRef = _simpleStores[key];
    if (storeRef != null) {
      storeRef.decrementRef();

      if (storeRef.isDestroyed) {
        _simpleStores.remove(key);
      }
    }
  }

  /// Check if a store exists
  bool has(String key) {
    if (_isDisposed) return false;
    return !(_simpleStores.elementFor(key)?.isDestroyed ?? true);
  }

  /// Remove a store from the registry (force cleanup)
  void remove(String key) {
    if (_isDisposed) return;

    final simpleStoreRef = _simpleStores[key];
    if (simpleStoreRef != null) {
      simpleStoreRef.store.destroy();
      _simpleStores.remove(key);
    }
  }

  /// Clear all stores
  void clear() {
    if (_isDisposed) return;

    for (final storeRef in _simpleStores.values) {
      storeRef.store.destroy();
    }
    _simpleStores.clear();
  }

  /// Get all registered store keys
  List<String> get keys {
    if (_isDisposed) return [];
    return [..._simpleStores.keys];
  }

  /// Get the number of registered stores
  int get length {
    if (_isDisposed) return 0;
    return _simpleStores.length;
  }

  /// Clean up stores that have no references
  void cleanupUnused() {
    if (_isDisposed) return;

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

SimpleStoreInstance<T> createGlobalStore<T>({
  String? key,
  required T Function(SetState<T> set) creator,
  SimpleStore<T>? store,
  Equality<T>? equality,
}) {
  if (key == null || key.isEmpty) {
    key = T.runtimeType.toString();
    if (key == 'dynamic' || key.isEmpty) {
      key = 'global_store_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  try {
    final storeWithActions = create<T>(
      creator,
      store: store,
      equality: equality,
    );
    GlobalStoreRegistry.instance.registerStore(key, storeWithActions);
    return storeWithActions;
  } catch (e) {
    throw ArgumentError('Failed to create global store: $e');
  }
}

SimpleStoreInstance<T> getGlobalStore<T>(String key) {
  if (key.isEmpty) {
    throw ArgumentError('Key cannot be empty');
  }

  return GlobalStoreRegistry.instance.getStore<T>(key);
}

void releaseGlobalStore<T>(String key) {
  if (key.isEmpty) return;

  GlobalStoreRegistry.instance.releaseStore<T>(key);
}

bool hasGlobalStore(String key) {
  if (key.isEmpty) return false;

  return GlobalStoreRegistry.instance.has(key);
}

void removeGlobalStore(String key) {
  if (key.isEmpty) return;

  GlobalStoreRegistry.instance.remove(key);
}

void clearGlobalStores() {
  GlobalStoreRegistry.instance.clear();
}

void cleanupUnusedGlobalStores() {
  GlobalStoreRegistry.instance.cleanupUnused();
}

/// Dispose the global registry
void disposeGlobalStoreRegistry() {
  GlobalStoreRegistry.reset();
}
