import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store/global_store_registry.dart';
import 'package:simple_store/src/store/store_actions.dart';
import 'package:simple_store/src/store/simple_store.dart';

/// Hook to use a global store without provider context
/// Similar to Zustand's direct store usage
T useGlobalStore<T, A extends StoreActions<T>>(String key) {
  final store = getGlobalStore<T, A>(key);
  final state = useState<T>(store.state);

  // Subscribe to store changes
  useEffect(() {
    final unsubscribe = store.subscribe((newState, _) {
      state.value = newState;
    });

    return () => unsubscribe();
  }, [store]);

  return state.value;
}

/// Hook to use a global store with selector
U useGlobalStoreSelector<T, A extends StoreActions<T>, U>(
  String key,
  Selector<T, U> selector, {
  List<Object?>? dependencies,
}) {
  final store = getGlobalStore<T, A>(key);

  // Keep reference to current selector function
  final selectorRef = useRef<Selector<T, U>>(selector);
  selectorRef.value = selector;

  // Initial selection
  final selectedState = useState<U>(selector(store.state));

  // Custom equality function for comparing selected values
  final isEqual = useCallback((U a, U b) => a == b, []);

  // Subscribe to changes
  useEffect(() {
    final unsubscribe = store.subscribe((state, _) {
      final newSelectedValue = selectorRef.value(state);
      if (!isEqual(selectedState.value, newSelectedValue)) {
        selectedState.value = newSelectedValue;
      }
    });

    return () => unsubscribe();
  }, [store, ...(dependencies ?? [])]);

  return selectedState.value;
}

/// Hook to get setState function for a global store
Function useGlobalStoreSetState<T, A extends StoreActions<T>>(String key) {
  final store = getGlobalStore<T, A>(key);

  return useCallback((T Function(T) updater) {
    store.setState(updater);
  }, [store]);
}

/// Hook to get actions for a global store
A useGlobalStoreActions<T, A extends StoreActions<T>>(String key) {
  final store = getGlobalStore<T, A>(key);
  return store.actions;
}

/// Hook to get both state and setState for a global store
List<dynamic> useGlobalStoreState<T, A extends StoreActions<T>, U>(
  String key,
  Selector<T, U> selector, {
  List<Object?>? dependencies,
}) {
  final selectedState = useGlobalStoreSelector<T, A, U>(
    key,
    selector,
    dependencies: dependencies,
  );
  final setState = useGlobalStoreSetState<T, A>(key);
  return [selectedState, setState];
}
