import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store_provider.dart';
import 'package:simple_store/src/store/store_actions.dart';

Function useStoreSetState<T, A extends StoreActions<T>>() {
  final context = useContext();
  final store = StoreProvider.of<T, A>(context);

  return useCallback((T Function(T) updater) {
    store.setState(updater);
  }, [store]);
}
