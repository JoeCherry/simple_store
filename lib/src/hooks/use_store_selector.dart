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
  final equalityChecker = equality ?? createEquality<U>();

  // Memoize the selector to prevent unnecessary re-subscriptions
  final memoizedSelector = useCallback(selector, []);

  // Calculate initial value
  final initialValue = memoizedSelector(store.state);

  // Cache the last selected value to avoid unnecessary updates
  final lastValueRef = useRef<U>(initialValue);

  final selectedValue = useState<U>(initialValue);
  lastValueRef.value = initialValue;

  useEffect(() {
    void handleChange(T newState, T _) {
      try {
        final newValue = memoizedSelector(newState);
        // Only update if the value has actually changed (using deep equality)
        if (!equalityChecker.equals(lastValueRef.value, newValue)) {
          lastValueRef.value = newValue;
          selectedValue.value = newValue;
        }
      } catch (e) {
        // Log error but don't break the hook
        debugPrint('Error in store selector: $e');
      }
    }

    final unsubscribe = store.subscribe(handleChange);
    return () {
      try {
        unsubscribe();
      } catch (e) {
        // Store might be destroyed, which is expected during cleanup
        // No need to log or handle this error
      }
    };
  }, [store, memoizedSelector, equalityChecker]);

  return selectedValue.value;
}
