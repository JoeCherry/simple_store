import 'package:flutter/material.dart';
import '../store/bear_state.dart';

// Shared UI component for displaying bear state
class BearStateDisplay extends StatelessWidget {
  final BearState state;
  final Color accentColor;

  const BearStateDisplay({
    super.key,
    required this.state,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Number of bears: ${state.bears}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (state.bears >= 5)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'That\'s a lot of bears!',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 8),
                    Text('Loading...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Shared UI component for bear controls
class BearControls extends StatelessWidget {
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onIncreaseAsync;

  const BearControls({
    super.key,
    required this.onDecrease,
    required this.onIncrease,
    required this.onIncreaseAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDecrease,
                    child: const Text('Decrease'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onIncrease,
                    child: const Text('Increase'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onIncreaseAsync,
                child: const Text('Add bears async'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
