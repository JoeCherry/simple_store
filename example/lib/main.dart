import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/simple_store.dart';

// 1. Define your store state
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

// Define the actions class
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

// 2. Create the store using the type-safe API
final bearStore = createStore<BearState, BearActions>(
  state: (store) => const BearState(bears: 0, isLoading: false),
  createActions: (store) => BearActions(store),
);

// 3. Create a custom hook for this specific store
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

// 5. Usage in a Flutter app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Zustand Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Wrap the app with the StoreProvider
      home: StoreProvider<BearState, BearActions>(
        store: bearStore,
        child: const HomePage(),
      ),
    );
  }
}

// 6. Using the hooks in a component
class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use our custom bear store hook
    final store = useBearStore();

    return Scaffold(
      appBar: AppBar(title: const Text('Bear Store')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Number of bears: ${store.state.bears}',
                style: Theme.of(context).textTheme.headlineMedium),
            if (store.state.bears >= 5)
              const Text('That\'s a lot of bears!',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (store.state.isLoading)
              const CircularProgressIndicator()
            else
              const SizedBox.shrink(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: store.decrease, child: const Text('Decrease')),
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: store.increase, child: const Text('Increase')),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: store.increaseAsync,
                child: const Text('Add bears async')),
          ],
        ),
      ),
    );
  }
}
