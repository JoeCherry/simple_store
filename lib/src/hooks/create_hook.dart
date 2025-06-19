import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/simple_store.dart';

Function createHook<T, A extends StoreActions<T>, HookReturnType>(
  HookReturnType Function(StoreWithActions<T, A> store) hookCreator,
) {
  return () {
    final context = useContext();
    final store = StoreProvider.of<T, A>(context);
    return hookCreator(store);
  };
}
