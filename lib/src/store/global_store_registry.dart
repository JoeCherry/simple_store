// import 'package:flutter/foundation.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/store_actions.dart';
import 'package:simple_store/src/store/default_store.dart';

/// A global registry for storing and accessing stores without providers
/// This enables Zustand-like direct store usage
class GlobalStoreRegistry {
  static final GlobalStoreRegistry _instance = GlobalStoreRegistry._internal();
  factory GlobalStoreRegistry() => _instance;
  GlobalStoreRegistry._internal();

  final Map<String, StoreWithActions> _stores = {};
  final Map<String, Function> _storeCreators = {};

  /// Register a store with a unique key
  void register<T, A extends StoreActions<T>>(
    String key,
    StoreWithActions<T, A> store,
  ) {
    _stores[key] = store;
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
      return _stores[key] as StoreWithActions<T, A>;
    }

    if (_storeCreators.containsKey(key)) {
      final creator = _storeCreators[key]!;
      final store = creator() as StoreWithActions<T, A>;
      _stores[key] = store;
      return store;
    }

    throw StateError('No store found for key: $key');
  }

  /// Check if a store exists
  bool has(String key) {
    return _stores.containsKey(key) || _storeCreators.containsKey(key);
  }

  /// Remove a store from the registry
  void remove(String key) {
    final store = _stores[key];
    if (store != null) {
      store.destroy();
    }
    _stores.remove(key);
    _storeCreators.remove(key);
  }

  /// Clear all stores
  void clear() {
    for (final store in _stores.values) {
      store.destroy();
    }
    _stores.clear();
    _storeCreators.clear();
  }

  /// Get all registered store keys
  List<String> get keys => [..._stores.keys, ..._storeCreators.keys];

  /// Get the number of registered stores
  int get length => _stores.length + _storeCreators.length;
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
