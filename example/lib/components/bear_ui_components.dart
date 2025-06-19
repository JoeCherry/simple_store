import 'package:flutter/material.dart';
import '../store/bear_stores.dart';

// Shared UI component for displaying bear state
class BearStateDisplay extends StatelessWidget {
  final BearStore state;
  final Color accentColor;

  const BearStateDisplay({
    super.key,
    required this.state,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: accentColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bears: ${state.bears}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Loading: '),
                state.isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Shared UI component for bear controls
class BearControls extends StatelessWidget {
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncreaseAsync;

  const BearControls({
    super.key,
    required this.onIncrease,
    required this.onDecrease,
    required this.onIncreaseAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: onDecrease,
          child: const Text('-'),
        ),
        ElevatedButton(
          onPressed: onIncrease,
          child: const Text('+'),
        ),
        ElevatedButton(
          onPressed: onIncreaseAsync,
          child: const Text('Async +5'),
        ),
      ],
    );
  }
}
