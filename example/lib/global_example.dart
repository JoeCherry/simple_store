import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/simple_store.dart';
import 'components/bear_ui_components.dart';
import 'store/bear_state.dart';

class GlobalStorePage extends HookWidget {
  const GlobalStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = useGlobalStore<BearState, BearActions>('bearStore');

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
            state: store.state,
            accentColor: Colors.green,
          ),
          const SizedBox(height: 24),
          BearControls(
            onDecrease: () => store.actions.decreasePopulation(),
            onIncrease: () => store.actions.increasePopulation(),
            onIncreaseAsync: () => store.actions.increaseBearPopulationAsync(),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Direct Access Example',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bears (selector): ${store.state.bears}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            getGlobalStore<BearState, BearActions>(
                              'bearStore',
                            ).actions.decreasePopulation();
                          },
                          child: const Text('Decrease'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            getGlobalStore<BearState, BearActions>(
                              'bearStore',
                            ).actions.increasePopulation();
                          },
                          child: const Text('Increase'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
