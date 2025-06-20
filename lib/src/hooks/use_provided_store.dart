import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/equality/equality.dart';
import 'package:simple_store/src/hooks/use_store.dart';
import 'package:simple_store/src/hooks/use_store_selector.dart';
import 'package:simple_store/src/store/simple_store_instance.dart';
import 'package:simple_store/src/store_provider.dart';

/// Hook to use a provider-based store (for feature-scoped stores)
/// Returns only the state since setState is accessible via store.setState
T useProvidedStore<T>() {
  final context = useContext();
  final store = StoreProvider.of<T>(context);
  return useStore<T>(store);
}

/// Hook to get setState from a provider-based store
SetState<T> useProvidedStoreSetState<T>() {
  final context = useContext();
  final store = StoreProvider.of<T>(context);
  return useSimpleStoreSetState<T>(store);
}

/// Hook to select from a provider-based store
U useProvidedStoreSelector<T, U>(
  U Function(T state) selector, {
  Equality<U>? equality,
}) {
  final context = useContext();
  final store = StoreProvider.of<T>(context);
  return useStoreSelector<T, U>(store, selector, equality: equality);
}
