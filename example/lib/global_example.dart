import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/simple_store.dart';
import 'shared/bear_hooks.dart';
import 'shared/bear_stores.dart';
import 'shared/bear_ui_components.dart';
import 'shared/bear_state.dart';

// Global store example page (no provider needed!)
class GlobalStorePage extends HookWidget {
  const GlobalStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    // All hooks must be declared at the top level
    final store = useGlobalBearStore();
    final bearsFromSelector =
        useGlobalStoreSelector<BearState, BearActions, int>(
      'bearStore',
      (state) => state.bears,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Store (No Provider!)'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              onDecrease: store.decrease,
              onIncrease: store.increase,
              onIncreaseAsync: store.increaseAsync,
            ),

            const SizedBox(height: 24),

            // Direct access example (Zustand-like)
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
                    const SizedBox(height: 8),
                    const Text(
                      'Access store directly without hooks (Zustand-like)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bears (selector): $bearsFromSelector',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Use actions from the hook instead of getGlobalStore
                              store.decrease();
                            },
                            child: const Text('Direct Decrease'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Use actions from the hook instead of getGlobalStore
                              store.increase();
                            },
                            child: const Text('Direct Increase'),
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
      ),
    );
  }
}
