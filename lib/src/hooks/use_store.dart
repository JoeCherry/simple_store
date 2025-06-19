import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store/default_store.dart';
import 'package:simple_store/src/store_provider.dart';

/// Hook to use a simplified store with actions (Zustand-like)
T useSimpleStore<T>(SimpleStoreWithActions<T> store) {
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
SetState<T> useSimpleStoreSetState<T>(SimpleStoreWithActions<T> store) {
  return store.setState;
}

/// Hook to select a value from a simplified store
U useSimpleStoreSelector<T, U>(
  SimpleStoreWithActions<T> store,
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

/// Hook to use a provider-based store (for feature-scoped stores)
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
