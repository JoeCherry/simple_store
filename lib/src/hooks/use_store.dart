import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/src/store_provider.dart';
import 'package:simple_store/src/store/store_actions.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/default_store.dart'; // Only for StoreWithActions

/// Hook to use a store - returns the entire store (state + actions) like Zustand
/// Can be used with a selector to get specific parts of state
StoreWithActions<T, A> useStore<T, A extends StoreActions<T>>([
  Selector<T, dynamic>? selector,
]) {
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

  // If no selector provided, return a proxy with the reactive state
  if (selector == null) {
    return _ReactiveStoreProxy(store, state.value);
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
  return _StoreProxy(store, selectedValue.value);
}

/// Proxy class that provides reactive state access
class _ReactiveStoreProxy<T, A extends StoreActions<T>>
    implements StoreWithActions<T, A> {
  final StoreWithActions<T, A> _store;
  final T _reactiveState;

  _ReactiveStoreProxy(this._store, this._reactiveState);

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
class _StoreProxy<T, A extends StoreActions<T>>
    implements StoreWithActions<T, A> {
  final StoreWithActions<T, A> _store;
  final dynamic _selectedValue;

  _StoreProxy(this._store, this._selectedValue);

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
