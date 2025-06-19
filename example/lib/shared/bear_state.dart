import 'package:simple_store/simple_store.dart';

// Shared state class for both examples
class BearState {
  final int bears;
  final bool isLoading;

  const BearState({required this.bears, required this.isLoading});

  BearState copyWith({int? bears, bool? isLoading}) {
    return BearState(
        bears: bears ?? this.bears, isLoading: isLoading ?? this.isLoading);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BearState &&
        other.bears == bears &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => bears.hashCode ^ isLoading.hashCode;
}

// Shared actions class for both examples
class BearActions extends StoreActions<BearState> {
  BearActions(super.store);

  void increasePopulation([int by = 1]) {
    setState((state) => state.copyWith(bears: state.bears + by));
  }

  void decreasePopulation([int by = 1]) {
    setState((state) => state.copyWith(bears: state.bears - by));
  }

  void setLoading(bool isLoading) {
    setState((state) => state.copyWith(isLoading: isLoading));
  }

  Future<void> increaseBearPopulationAsync() async {
    setLoading(true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    increasePopulation(5);
    setLoading(false);
  }
}
