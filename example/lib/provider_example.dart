import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/simple_store.dart';
import 'shared/bear_hooks.dart';
import 'shared/bear_stores.dart';
import 'shared/bear_ui_components.dart';
import 'shared/bear_state.dart';

// Provider-based store example page
class ProviderBasedPage extends HookWidget {
  const ProviderBasedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = useBearStore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider-based Store'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.settings, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    const Text(
                      'Provider-based Store',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This example uses StoreProvider to wrap the widget tree',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // State display using shared component
            BearStateDisplay(
              state: store.state,
              accentColor: Colors.red,
            ),

            const SizedBox(height: 24),

            // Controls using shared component
            BearControls(
              onDecrease: store.decrease,
              onIncrease: store.increase,
              onIncreaseAsync: store.increaseAsync,
            ),
          ],
        ),
      ),
    );
  }
}

// Provider-based example with StoreProvider wrapper
class ProviderBasedExample extends StatelessWidget {
  const ProviderBasedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<BearState, BearActions>(
      store: bearStore,
      child: const ProviderBasedPage(),
    );
  }
}
