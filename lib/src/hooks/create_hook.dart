import 'package:flutter_hooks/flutter_hooks.dart' show useContext;
import 'package:simple_store/src/store/store.dart';
import 'package:simple_store/src/store_provider.dart';

Function createHook<T, HookReturnType>(HookReturnType Function(Store<T> store) hookCreator) {
  return () {
    final context = useContext();
    final store = StoreProvider.of<T>(context);
    return hookCreator(store);
  };
}
