import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store/simple_store_instance.dart';
import 'package:simple_store/src/store_provider.dart';
import 'package:simple_store/src/store/global_store_registry.dart';

/// Hook to use a simplified store with actions
/// Returns only the state since setState is accessible via store.setState
T useSimpleStore<T>(SimpleStoreInstance<T> store) {
  final state = useState<T>(store.state);
  useEffect(() {
    final unsubscribe = store.subscribe((newState, _) {
      state.value = newState;
    });
    return () => unsubscribe();
  }, [store]);
  return state.value;
}

/// Hook to get the setState function from a simplified store
SetState<T> useSimpleStoreSetState<T>(SimpleStoreInstance<T> store) {
  return store.setState;
}

/// Hook to select a value from a simplified store
U useSimpleStoreSelector<T, U>(
  SimpleStoreInstance<T> store,
  U Function(T state) selector,
) {
  final value = useState<U>(selector(store.state));
  useEffect(() {
    final unsubscribe = store.subscribe((newState, _) {
      final newValue = selector(newState);
      if (value.value != newValue) {
        value.value = newValue;
      }
    });
    return () => unsubscribe();
  }, [store]);
  return value.value;
}

/// Hook to use a global store by key
/// Returns only the state since setState is accessible via store.setState
T useGlobalStore<T>(String key) {
  final store = useMemoized(() => getGlobalStoreSimple<T>(key), [key]);
  return useSimpleStore<T>(store);
}

/// Hook to use a global store by type (convention-based key)
/// Returns only the state since setState is accessible via store.setState
/// Uses the type name as the key (e.g., BearStore -> 'BearStore')
T useGlobalStoreByType<T>() {
  final key = T.toString();
  return useGlobalStore<T>(key);
}

/// Hook to get setState from a global store by key
SetState<T> useGlobalStoreSetState<T>(String key) {
  final store = useMemoized(() => getGlobalStoreSimple<T>(key), [key]);
  return useSimpleStoreSetState<T>(store);
}

/// Hook to get setState from a global store by type
SetState<T> useGlobalStoreSetStateByType<T>() {
  final key = T.toString();
  return useGlobalStoreSetState<T>(key);
}

/// Hook to select from a global store by key
U useGlobalStoreSelector<T, U>(String key, U Function(T state) selector) {
  final store = useMemoized(() => getGlobalStoreSimple<T>(key), [key]);
  return useSimpleStoreSelector<T, U>(store, selector);
}

/// Hook to select from a global store by type
U useGlobalStoreSelectorByType<T, U>(U Function(T state) selector) {
  final key = T.toString();
  return useGlobalStoreSelector<T, U>(key, selector);
}

/// Hook to use a provider-based store (for feature-scoped stores)
/// Returns only the state since setState is accessible via store.setState
T useStore<T>() {
  final context = useContext();
  final store = StoreProvider.of<T>(context);
  return useSimpleStore<T>(store);
}

/// Hook to get setState from a provider-based store
SetState<T> useStoreSetState<T>() {
  final context = useContext();
  final store = StoreProvider.of<T>(context);
  return useSimpleStoreSetState<T>(store);
}

/// Hook to select from a provider-based store
U useStoreSelector<T, U>(U Function(T state) selector) {
  final context = useContext();
  final store = StoreProvider.of<T>(context);
  return useSimpleStoreSelector<T, U>(store, selector);
}
