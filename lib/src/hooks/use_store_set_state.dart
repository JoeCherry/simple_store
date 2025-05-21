import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store_provider.dart';

Function useStoreSetState<T, A>() {
  final context = useContext();
  final store = StoreProvider.of<T, A>(context);

  return useCallback((T Function(T) updater) {
    store.setState(updater);
  }, [store]);
}
