import 'package:simple_store/simple_store.dart';

// Zustand-like API - clean and simple!
class BearStore {
  final int bears;
  final bool isLoading;
  final List<String> bearNames;
  final SetState<BearStore> _setState;

  BearStore(this.bears, this.isLoading, this.bearNames, this._setState);

  BearStore copyWith({
    int? bears,
    bool? isLoading,
    List<String>? bearNames,
  }) {
    return BearStore(
      bears ?? this.bears,
      isLoading ?? this.isLoading,
      bearNames ?? this.bearNames,
      _setState,
    );
  }

  // Actions that use the injected setState
  void increasePopulation([int by = 1]) {
    _setState((state) => state.copyWith(bears: state.bears + by));
  }

  void decreasePopulation([int by = 1]) {
    _setState((state) => state.copyWith(bears: state.bears - by));
  }

  void setLoading(bool isLoading) {
    _setState((state) => state.copyWith(isLoading: isLoading));
  }

  void addBearName(String name) {
    _setState((state) => state.copyWith(
          bearNames: [...state.bearNames, name],
        ));
  }

  void updateBearNames(List<String> names) {
    _setState((state) => state.copyWith(bearNames: names));
  }

  Future<void> increaseBearPopulationAsync() async {
    setLoading(true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    increasePopulation(5);
    setLoading(false);
  }
}

// Create simplified store - much less verbose!
final simpleBearStore =
    create<BearStore>((set) => BearStore(0, false, [], set));

// Create a store with deep equality for better performance
final deepEqualityBearStore = create<BearStore>(
  (set) => BearStore(0, false, [], set),
  equality: const DeepEquality<BearStore>(),
);
