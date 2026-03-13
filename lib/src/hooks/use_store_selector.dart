import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/equality/equality.dart';
import 'package:simple_store/src/store/simple_store_instance.dart';

/// Hook to select a value from a store
U useStoreSelector<T, U>(
  SimpleStoreInstance<T> store,
  U Function(T state) selector, {
  Equality<U>? equality,
}) {
  // Memoize so a new Equality instance on every rebuild doesn't cause the
  // effect to re-run (equality implementations don't override ==).
  final equalityChecker = useMemoized(
    () => equality ?? createEquality<U>(),
    [equality],
  );

  // Hold the latest selector in a ref so the subscription callback always
  // calls the current closure without causing effect re-runs when the selector
  // identity changes (inline lambdas are always new instances on each rebuild).
  final selectorRef = useRef(selector);
  selectorRef.value = selector;

  final initialValue = selector(store.state);
  final lastValueRef = useRef<U>(initialValue);
  final selectedValue = useState<U>(initialValue);

  useEffect(() {
    void handleChange(T newState, T _) {
      try {
        final newValue = selectorRef.value(newState);
        if (!equalityChecker.equals(lastValueRef.value, newValue)) {
          lastValueRef.value = newValue;
          selectedValue.value = newValue;
        }
      } catch (e) {
        debugPrint('Error in store selector: $e');
      }
    }

    final unsubscribe = store.subscribe(handleChange);
    return () {
      try {
        unsubscribe();
      } catch (_) {
        // Store might be destroyed, which is expected during cleanup
      }
    };
  }, [store, equalityChecker]);

  return selectedValue.value;
}
