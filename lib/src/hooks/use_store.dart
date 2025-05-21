import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store_provider.dart';

T useStore<T, A>() {
  final context = useContext();
  final store = StoreProvider.of<T, A>(context);

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
