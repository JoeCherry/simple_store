import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store_provider.dart';

/// Hook to use the store in function components
T useStore<T>() {
  final context = useContext();
  final store = StoreProvider.of<T>(context);

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
