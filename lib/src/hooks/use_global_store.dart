import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store/global_store_registry.dart';
import 'package:simple_store/src/store/store_actions.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/default_store.dart';

/// Hook to use a global store - returns the entire store (state + actions) like Zustand
/// Can be used with a selector to get specific parts of state
StoreWithActions<T, A> useGlobalStore<T, A extends StoreActions<T>>(
  String key, [
  Selector<T, dynamic>? selector,
]) {
  final store = getGlobalStore<T, A>(key);

  // Always subscribe to changes to ensure the widget rebuilds
  final state = useState<T>(store.state);

  useEffect(() {
    final unsubscribe = store.subscribe((newState, _) {
      state.value = newState;
    });

    return () => unsubscribe();
  }, [store]);

  // If no selector provided, return a proxy with the reactive state
  if (selector == null) {
    return _ReactiveGlobalStoreProxy(store, state.value);
  }

  // If selector provided, subscribe to changes and return selected value
  final selectedValue = useState<dynamic>(selector(store.state));

  useEffect(() {
    final unsubscribe = store.subscribe((newState, _) {
      selectedValue.value = selector(newState);
    });

    return () => unsubscribe();
  }, [store]);

  // Return a proxy that behaves like the selected value but has access to actions
  return _GlobalStoreProxy(store, selectedValue.value);
}

/// Proxy class that provides reactive state access for global stores
class _ReactiveGlobalStoreProxy<T, A extends StoreActions<T>>
    implements StoreWithActions<T, A> {
  final StoreWithActions<T, A> _store;
  final T _reactiveState;

  _ReactiveGlobalStoreProxy(this._store, this._reactiveState);

  @override
  T get state => _reactiveState;

  @override
  A get actions => _store.actions;

  @override
  void setState(T Function(T currentState) updater) => _store.setState(updater);

  @override
  Function subscribe(StoreListener<T> listener) => _store.subscribe(listener);

  @override
  void destroy() => _store.destroy();

  @override
  U select<U>(Selector<T, U> selector) => _store.select(selector);

  @override
  StateGetter<T> getState() => _store.getState();

  @override
  ChangeNotifier get api => _store.api;
}

/// Proxy class that provides access to actions while returning selected state
class _GlobalStoreProxy<T, A extends StoreActions<T>>
    implements StoreWithActions<T, A> {
  final StoreWithActions<T, A> _store;
  final dynamic _selectedValue;

  _GlobalStoreProxy(this._store, this._selectedValue);

  @override
  T get state => _selectedValue as T;

  @override
  A get actions => _store.actions;

  @override
  void setState(T Function(T currentState) updater) => _store.setState(updater);

  @override
  Function subscribe(StoreListener<T> listener) => _store.subscribe(listener);

  @override
  void destroy() => _store.destroy();

  @override
  U select<U>(Selector<T, U> selector) => _store.select(selector);

  @override
  StateGetter<T> getState() => _store.getState();

  @override
  ChangeNotifier get api => _store.api;
}

/// Hook to use a global store with selector
U useGlobalStoreSelector<T, A extends StoreActions<T>, U>(
  String key,
  Selector<T, U> selector, {
  List<Object?>? dependencies,
}) {
  final store = getGlobalStore<T, A>(key);

  // Keep reference to current selector function
  final selectorRef = useRef<Selector<T, U>>(selector);
  selectorRef.value = selector;

  // Initial selection
  final selectedState = useState<U>(selector(store.state));

  // Custom equality function for comparing selected values
  final isEqual = useCallback((U a, U b) => a == b, []);

  // Subscribe to changes
  useEffect(() {
    final unsubscribe = store.subscribe((state, _) {
      final newSelectedValue = selectorRef.value(state);
      if (!isEqual(selectedState.value, newSelectedValue)) {
        selectedState.value = newSelectedValue;
      }
    });

    return () => unsubscribe();
  }, [store, ...(dependencies ?? [])]);

  return selectedState.value;
}

/// Hook to get setState function for a global store
Function useGlobalStoreSetState<T, A extends StoreActions<T>>(String key) {
  final store = getGlobalStore<T, A>(key);

  return useCallback((T Function(T) updater) {
    store.setState(updater);
  }, [store]);
}

/// Hook to get actions for a global store
A useGlobalStoreActions<T, A extends StoreActions<T>>(String key) {
  final store = getGlobalStore<T, A>(key);
  return store.actions;
}

/// Hook to get both state and setState for a global store
List<dynamic> useGlobalStoreState<T, A extends StoreActions<T>, U>(
  String key,
  Selector<T, U> selector, {
  List<Object?>? dependencies,
}) {
  final selectedState = useGlobalStoreSelector<T, A, U>(
    key,
    selector,
    dependencies: dependencies,
  );
  final setState = useGlobalStoreSetState<T, A>(key);
  return [selectedState, setState];
}
