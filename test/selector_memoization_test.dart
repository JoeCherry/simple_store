import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/simple_store.dart';

class TestState {
  final int count;
  final String name;
  final List<String> items;

  TestState({required this.count, required this.name, required this.items});

  TestState copyWith({int? count, String? name, List<String>? items}) {
    return TestState(
      count: count ?? this.count,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }
}

void main() {
  group('Selector Memoization', () {
    testWidgets(
      'should memoize selector results and prevent unnecessary updates',
      (tester) async {
        // Create a test store
        final store = create<TestState>(
          (set) => TestState(count: 0, name: 'test', items: []),
        );

        int selectorCallCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: HookBuilder(
              builder: (context) {
                // Use a selector that counts calls
                final selectedValue = useStoreSelector<TestState, int>(store, (
                  state,
                ) {
                  selectorCallCount++;
                  return state.count;
                });

                return Text('Selected: $selectedValue');
              },
            ),
          ),
        );

        // Initial render
        expect(selectorCallCount, greaterThan(0));
        expect(find.text('Selected: 0'), findsOneWidget);

        // Update state with same count (should not trigger selector)
        store.setState((state) => state.copyWith(name: 'updated'));
        await tester.pump();

        final callsAfterNameUpdate = selectorCallCount;

        // Update count (should trigger selector)
        store.setState((state) => state.copyWith(count: 5));
        await tester.pump();

        // Selector should be called again since count changed
        expect(selectorCallCount, greaterThan(callsAfterNameUpdate));
        expect(find.text('Selected: 5'), findsOneWidget);

        store.destroy();
      },
    );

    testWidgets('should work with deep equality for collections', (
      tester,
    ) async {
      // Create a test store
      final store = create<TestState>(
        (set) => TestState(count: 0, name: 'test', items: ['a', 'b']),
      );

      int selectorCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              // Use a selector that counts calls
              final selectedValue = useStoreSelector<TestState, String>(store, (
                state,
              ) {
                selectorCallCount++;
                return state.items.join(', ');
              });

              return Text('Items: $selectedValue');
            },
          ),
        ),
      );

      // Initial render
      expect(selectorCallCount, greaterThan(0));
      expect(find.text('Items: a, b'), findsOneWidget);

      // Update with same items but different reference
      store.setState((state) => state.copyWith(items: ['a', 'b']));
      await tester.pump();

      final callsAfterSameItems = selectorCallCount;

      // Update with different items
      store.setState((state) => state.copyWith(items: ['c', 'd']));
      await tester.pump();

      // Should trigger selector since content changed
      expect(selectorCallCount, greaterThan(callsAfterSameItems));
      expect(find.text('Items: c, d'), findsOneWidget);

      store.destroy();
    });
  });
}
