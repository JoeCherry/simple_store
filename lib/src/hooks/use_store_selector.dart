import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store_provider.dart';

/// Hook to subscribe to part of the store using a selector
U useStoreSelector<T, A, U>(Selector<T, U> selector, {List<Object?>? dependencies}) {
  final context = useContext();
  final store = StoreProvider.of<T, A>(context);

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
