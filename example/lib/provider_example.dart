import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/simple_store.dart';
import 'store/bear_stores.dart';
import 'components/bear_ui_components.dart';
import 'store/bear_state.dart';

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

class ProviderBasedPage extends HookWidget {
  const ProviderBasedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = useStore<BearState, BearActions>();

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
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.settings, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Provider-based Store',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
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
              onDecrease: () => store.actions.decreasePopulation(),
              onIncrease: () => store.actions.increasePopulation(),
              onIncreaseAsync: () =>
                  store.actions.increaseBearPopulationAsync(),
            ),
          ],
        ),
      ),
    );
  }
}
