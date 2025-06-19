import 'package:simple_store/simple_store.dart';

// Zustand-like API - clean and simple!
class BearStore {
  final int bears;
  final bool isLoading;

  BearStore(this.bears, this.isLoading);

  BearStore copyWith({int? bears, bool? isLoading}) {
    return BearStore(bears ?? this.bears, isLoading ?? this.isLoading);
  }

  // Actions are just methods that use the set function
  void increasePopulation(SetState<BearStore> set, [int by = 1]) {
    set((state) => state.copyWith(bears: state.bears + by));
  }

  void decreasePopulation(SetState<BearStore> set, [int by = 1]) {
    set((state) => state.copyWith(bears: state.bears - by));
  }

  void setLoading(SetState<BearStore> set, bool isLoading) {
    set((state) => state.copyWith(isLoading: isLoading));
  }

  Future<void> increaseBearPopulationAsync(SetState<BearStore> set) async {
    setLoading(set, true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    increasePopulation(set, 5);
    setLoading(set, false);
  }
}

// Create simplified store - much less verbose!
final simpleBearStore = create<BearStore>((set) => BearStore(0, false));
