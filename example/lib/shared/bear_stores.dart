import 'package:simple_store/simple_store.dart';
import 'bear_state.dart';

// Provider-based store instance
final bearStore = createStore<BearState, BearActions>(
  state: (store) => const BearState(bears: 0, isLoading: false),
  createActions: (store) => BearActions(store),
);

// Global store instance
final globalBearStore = createGlobalStore<BearState, BearActions>(
  key: 'bearStore',
  state: (store) => const BearState(bears: 0, isLoading: false),
  createActions: (store) => BearActions(store),
);
