import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store_provider.dart';

Function createHook<T, HookReturnType>(HookReturnType Function(SimpleStore<T> store) hookCreator) {
  return () {
    final context = useContext();
    final store = StoreProvider.of<T>(context);
    return hookCreator(store);
  };
}
