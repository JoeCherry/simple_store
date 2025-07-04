import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store/simple_store_instance.dart';

/// Hook to use a simplified store
T useStore<T>(SimpleStoreInstance<T> store) {
  final state = useState<T>(store.state);

  useEffect(() {
    final unsubscribe = store.subscribe((newState, _) {
      state.value = newState;
    });

    return () {
      try {
        unsubscribe();
      } catch (e) {
        // Store might be destroyed, which is expected during cleanup
        // No need to log or handle this error
      }
    };
  }, [store]);

  return state.value;
}

/// Hook to get the setState function from a simplified store
SetState<T> useSimpleStoreSetState<T>(SimpleStoreInstance<T> store) {
  return store.setState;
}
