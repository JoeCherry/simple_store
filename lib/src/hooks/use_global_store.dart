import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/equality/equality.dart';
import 'package:simple_store/src/hooks/use_store.dart';
import 'package:simple_store/src/hooks/use_store_selector.dart';
import 'package:simple_store/src/hooks/utils/use_key.dart';
import 'package:simple_store/src/store/global_store_registry.dart';
import 'package:simple_store/src/store/simple_store_instance.dart';

/// Hook to use a global store by key
T useGlobalStore<T>(String? key) {
  final k = useKey<T>(key);
  final store = useMemoized(() => getGlobalStore<T>(k), [k]);
  return useStore<T>(store);
}

/// Hook to get setState from a global store by key
SetState<T> useGlobalStoreSetState<T>(String? key) {
  final k = useKey<T>(key);
  final store = useMemoized(() => getGlobalStore<T>(k), [k]);
  return useSimpleStoreSetState<T>(store);
}

U useGlobalStoreSelector<T, U>(String? key, U Function(T state) selector, {Equality<U>? equality}) {
  final k = useKey<T>(key);
  final store = useMemoized(() => getGlobalStore<T>(k), [k]);
  return useStoreSelector<T, U>(store, selector, equality: equality);
}
