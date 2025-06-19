import 'package:simple_store/simple_store.dart';
import 'bear_state.dart';
import 'bear_stores.dart';

// Custom hook for the provider-based store
({
  BearState state,
  void Function() increase,
  void Function() decrease,
  Future<void> Function() increaseAsync,
}) useBearStore() {
  final state = useStore<BearState, BearActions>();

  return (
    state: state,
    increase: () => bearStore.actions.increasePopulation(),
    decrease: () => bearStore.actions.decreasePopulation(),
    increaseAsync: () => bearStore.actions.increaseBearPopulationAsync(),
  );
}

// Custom hook for the global store
({
  BearState state,
  void Function() increase,
  void Function() decrease,
  Future<void> Function() increaseAsync,
}) useGlobalBearStore() {
  final state = useGlobalStore<BearState, BearActions>('bearStore');
  final actions = useGlobalStoreActions<BearState, BearActions>('bearStore');

  return (
    state: state,
    increase: () => actions.increasePopulation(),
    decrease: () => actions.decreasePopulation(),
    increaseAsync: () => actions.increaseBearPopulationAsync(),
  );
}
