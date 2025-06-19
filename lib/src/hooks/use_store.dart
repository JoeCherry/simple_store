import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store_provider.dart';
import 'package:simple_store/src/store/store_actions.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/default_store.dart'; // For StoreWithActions

/// Hook to use a store - returns the entire store (state + actions) like Zustand
/// For selecting specific parts of state, use useStoreSelector instead
StoreWithActions<T, A> useStore<T, A extends StoreActions<T>>() {
  final context = useContext();
  final store = StoreProvider.of<T, A>(context);

  // Always subscribe to changes to ensure the widget rebuilds
  final state = useState<T>(store.state);

  useEffect(() {
    final unsubscribe = store.subscribe((newState, _) {
      state.value = newState;
    });

    return () => unsubscribe();
  }, [store]);

  // Return a reactive store with the current state
  return StoreWithActions<T, A>(
    store.api as SimpleStore<T>,
    store.actions,
    state.value,
  );
}
