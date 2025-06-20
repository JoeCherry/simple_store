import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/simple_store.dart';
import 'components/bear_ui_components.dart';
import 'store/bear_stores.dart';

class GlobalStorePage extends HookWidget {
  const GlobalStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the global store directly by key - much cleaner!
    final bearStore = useGlobalStore<BearStore>('BearStore');

    // Alternative: Access by type (convention-based)
    // final bearStore = useGlobalStoreByType<BearStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Store (No Provider!)'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Header
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.public, size: 48, color: Colors.green),
                  SizedBox(height: 8),
                  Text(
                    'Global Store',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No StoreProvider needed! Access stores directly from anywhere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          BearStateDisplay(
            state: bearStore,
            accentColor: Colors.green,
          ),
          const SizedBox(height: 24),
          BearControls(
            onDecrease: () => bearStore.decreasePopulation(),
            onIncrease: () => bearStore.increasePopulation(),
            onIncreaseAsync: () => bearStore.increaseBearPopulationAsync(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
