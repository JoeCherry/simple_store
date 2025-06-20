import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/src/store/default_store.dart';

void main() {
  group('Concurrent Modification Tests', () {
    test('should handle listener removal during notification', () {
      final store = DefaultStore<TestState>(
        initialState: const TestState(count: 0, name: 'test'),
      );

      bool listener1Called = false;
      bool listener2Called = false;
      bool listener3Called = false;

      // Declare functions first
      void thirdListener(TestState state, TestState previousState) {
        listener3Called = true;
      }

      // Listener that removes itself during notification
      void selfRemovingListener(TestState state, TestState previousState) {
        listener1Called = true;
        store.removeStoreListener(selfRemovingListener);
      }

      // Listener that removes another listener during notification
      void removingListener(TestState state, TestState previousState) {
        listener2Called = true;
        store.removeStoreListener(thirdListener);
      }

      // Subscribe all listeners
      store.subscribe(selfRemovingListener);
      store.subscribe(removingListener);
      store.subscribe(thirdListener);

      // Trigger state change
      store.setState((state) => state.copyWith(count: 1));

      // Verify listeners were called
      expect(listener1Called, isTrue);
      expect(listener2Called, isTrue);
      expect(
        listener3Called,
        isFalse,
      ); // Should not be called as it was removed

      // Verify listener counts
      expect(
        store.listenerCount,
        equals(1),
      ); // Only removingListener should remain

      store.destroy();
    });

    test('should handle listener addition during notification', () {
      final store = DefaultStore<TestState>(
        initialState: const TestState(count: 0, name: 'test'),
      );

      bool originalListenerCalled = false;
      bool addedListenerCalled = false;

      // Declare function first
      void addedListener(TestState state, TestState previousState) {
        addedListenerCalled = true;
      }

      // Listener that adds another listener during notification
      void addingListener(TestState state, TestState previousState) {
        originalListenerCalled = true;
        store.subscribe(addedListener);
      }

      // Subscribe the original listener
      store.subscribe(addingListener);

      // Trigger state change
      store.setState((state) => state.copyWith(count: 1));

      // Verify original listener was called
      expect(originalListenerCalled, isTrue);
      expect(
        addedListenerCalled,
        isFalse,
      ); // Should not be called in this notification

      // Trigger another state change
      store.setState((state) => state.copyWith(count: 2));

      // Now both listeners should be called
      expect(addedListenerCalled, isTrue);

      // Verify listener counts
      expect(store.listenerCount, equals(2));

      store.destroy();
    });

    test('should handle multiple rapid state changes', () {
      final store = DefaultStore<TestState>(
        initialState: const TestState(count: 0, name: 'test'),
      );

      int notificationCount = 0;
      final List<int> receivedCounts = [];

      store.subscribe((state, previousState) {
        notificationCount++;
        receivedCounts.add(state.count);

        // Add a listener during notification
        if (notificationCount == 1) {
          store.subscribe((state, previousState) {
            // This listener should not cause issues
          });
        }
      });

      // Trigger multiple rapid state changes
      for (int i = 1; i <= 5; i++) {
        store.setState((state) => state.copyWith(count: i));
      }

      // Verify all notifications were received
      expect(notificationCount, equals(5));
      expect(receivedCounts, equals([1, 2, 3, 4, 5]));

      store.destroy();
    });

    test('should handle store destruction during notification', () {
      final store = DefaultStore<TestState>(
        initialState: const TestState(count: 0, name: 'test'),
      );

      bool listenerCalled = false;

      store.subscribe((state, previousState) {
        listenerCalled = true;
        // This should not cause issues
        store.destroy();
      });

      // Trigger state change
      store.setState((state) => state.copyWith(count: 1));

      // Verify listener was called
      expect(listenerCalled, isTrue);

      // Verify store is destroyed
      expect(store.listenerCount, equals(0));
    });
  });
}

class TestState {
  final int count;
  final String name;

  const TestState({required this.count, required this.name});

  TestState copyWith({int? count, String? name}) {
    return TestState(count: count ?? this.count, name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestState && other.count == count && other.name == name;
  }

  @override
  int get hashCode => Object.hash(count, name);

  @override
  String toString() => 'TestState(count: $count, name: $name)';
}
