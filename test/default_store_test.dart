import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/src/store/default_store.dart';
import 'package:simple_store/src/store/simple_store.dart';
import 'package:simple_store/src/store/store_actions.dart';

void main() {
  group('DefaultStore', () {
    late DefaultStore<TestState> store;

    setUp(() {
      store = DefaultStore<TestState>();
    });

    tearDown(() {
      store.destroy();
    });

    group('Initialization', () {
      test('should initialize with initial state', () {
        const initialState = TestState(count: 42, name: 'test');
        store.initialize(initialState);

        expect(store.state, equals(initialState));
      });

      test('should throw error when initialized twice', () {
        const initialState = TestState(count: 0, name: 'test');
        store.initialize(initialState);

        expect(
          () => store.initialize(TestState(count: 1, name: 'another')),
          throwsStateError,
        );
      });

      test('should have correct listener count after initialization', () {
        const initialState = TestState(count: 0, name: 'test');
        store.initialize(initialState);

        expect(store.listenerCount, equals(0));
      });
    });

    group('State Management', () {
      setUp(() {
        store.initialize(const TestState(count: 0, name: 'initial'));
      });

      test('should update state correctly', () {
        store.setState((state) => state.copyWith(count: 5));

        expect(store.state.count, equals(5));
        expect(store.state.name, equals('initial'));
      });

      test('should not notify listeners when state is unchanged', () {
        bool listenerCalled = false;
        store.subscribe((state, previousState) {
          listenerCalled = true;
        });

        // Set state to the same value
        store.setState((state) => state);

        expect(listenerCalled, isFalse);
      });

      test('should update state with complex objects', () {
        store.setState((state) => state.copyWith(count: 100, name: 'updated'));

        expect(store.state.count, equals(100));
        expect(store.state.name, equals('updated'));
      });

      test('should handle multiple state updates', () {
        store.setState((state) => state.copyWith(count: 1));
        store.setState((state) => state.copyWith(count: 2));
        store.setState((state) => state.copyWith(count: 3));

        expect(store.state.count, equals(3));
      });
    });

    group('Listeners', () {
      setUp(() {
        store.initialize(const TestState(count: 0, name: 'initial'));
      });

      test('should add and notify listeners', () {
        TestState? capturedState;
        TestState? capturedPreviousState;

        final unsubscribe = store.subscribe((state, previousState) {
          capturedState = state;
          capturedPreviousState = previousState;
        });

        store.setState((state) => state.copyWith(count: 5));

        expect(capturedState?.count, equals(5));
        expect(capturedPreviousState?.count, equals(0));
        expect(capturedState?.name, equals('initial'));
        expect(capturedPreviousState?.name, equals('initial'));

        unsubscribe();
      });

      test('should remove listeners when unsubscribe is called', () {
        bool listenerCalled = false;
        final unsubscribe = store.subscribe((state, previousState) {
          listenerCalled = true;
        });

        unsubscribe();

        store.setState((state) => state.copyWith(count: 5));

        expect(listenerCalled, isFalse);
        expect(store.listenerCount, equals(0));
      });

      test('should handle multiple listeners', () {
        int listener1Calls = 0;
        int listener2Calls = 0;

        final unsubscribe1 = store.subscribe((state, previousState) {
          listener1Calls++;
        });

        final unsubscribe2 = store.subscribe((state, previousState) {
          listener2Calls++;
        });

        store.setState((state) => state.copyWith(count: 1));
        store.setState((state) => state.copyWith(count: 2));

        expect(listener1Calls, equals(2));
        expect(listener2Calls, equals(2));
        expect(store.listenerCount, equals(2));

        unsubscribe1();
        unsubscribe2();
      });

      test('should check if listener exists', () {
        void testListener(TestState state, TestState previousState) {}

        expect(store.hasListener(testListener), isFalse);

        store.subscribe(testListener);
        expect(store.hasListener(testListener), isTrue);

        store.removeStoreListener(testListener);
        expect(store.hasListener(testListener), isFalse);
      });

      test('should remove specific listener', () {
        void listener1(TestState state, TestState previousState) {}
        void listener2(TestState state, TestState previousState) {}

        store.subscribe(listener1);
        store.subscribe(listener2);

        expect(store.listenerCount, equals(2));

        final removed = store.removeStoreListener(listener1);
        expect(removed, isTrue);
        expect(store.listenerCount, equals(1));
        expect(store.hasListener(listener1), isFalse);
        expect(store.hasListener(listener2), isTrue);
      });

      test('should return false when removing non-existent listener', () {
        void testListener(TestState state, TestState previousState) {}

        final removed = store.removeStoreListener(testListener);
        expect(removed, isFalse);
      });

      test('should handle listener removal during notification', () {
        StoreListener<TestState>? listenerToRemove;
        bool listenerRemoved = false;

        // ignore: prefer_function_declarations_over_variables
        final listener = (TestState state, TestState previousState) {
          if (listenerToRemove != null && !listenerRemoved) {
            store.removeStoreListener(listenerToRemove);
            listenerRemoved = true;
          }
        };

        listenerToRemove = listener;
        store.subscribe(listener);

        store.setState((state) => state.copyWith(count: 1));

        expect(listenerRemoved, isTrue);
      });
    });

    group('Selectors', () {
      setUp(() {
        store.initialize(const TestState(count: 42, name: 'test'));
      });

      test('should select state using selector function', () {
        final count = store.select((state) => state.count);
        final name = store.select((state) => state.name);
        final isEven = store.select((state) => state.count % 2 == 0);

        expect(count, equals(42));
        expect(name, equals('test'));
        expect(isEven, isTrue);
      });

      test('should select derived state', () {
        final doubleCount = store.select((state) => state.count * 2);
        final upperName = store.select((state) => state.name.toUpperCase());

        expect(doubleCount, equals(84));
        expect(upperName, equals('TEST'));
      });
    });

    group('State Getter', () {
      setUp(() {
        store.initialize(const TestState(count: 10, name: 'getter'));
      });

      test('should return current state via getter function', () {
        final getState = store.getState();
        final currentState = getState();

        expect(currentState, equals(store.state));
        expect(currentState.count, equals(10));
        expect(currentState.name, equals('getter'));
      });

      test('should return updated state after state changes', () {
        final getState = store.getState();

        store.setState((state) => state.copyWith(count: 20));

        final currentState = getState();
        expect(currentState.count, equals(20));
      });
    });

    group('API Access', () {
      setUp(() {
        store.initialize(const TestState(count: 0, name: 'api'));
      });

      test('should provide ChangeNotifier API', () {
        final api = store.api;
        expect(api, isA<ChangeNotifier>());
        expect(api, equals(store));
      });

      test('should notify ChangeNotifier listeners', () {
        bool apiListenerCalled = false;
        store.api.addListener(() {
          apiListenerCalled = true;
        });

        store.setState((state) => state.copyWith(count: 1));

        expect(apiListenerCalled, isTrue);
      });
    });

    group('StoreWithActions', () {
      test('should create store with actions', () {
        final storeWithActions = createStore<TestState, TestActions>(
          state: (store) => const TestState(count: 0, name: 'actions'),
          createActions: (store) => TestActions(store),
        );

        expect(storeWithActions.state.count, equals(0));
        expect(storeWithActions.state.name, equals('actions'));
        expect(storeWithActions.actions, isA<TestActions>());

        storeWithActions.destroy();
      });

      test('should allow state updates through actions', () {
        final storeWithActions = createStore<TestState, TestActions>(
          state: (store) => const TestState(count: 0, name: 'actions'),
          createActions: (store) => TestActions(store),
        );

        storeWithActions.actions.increment();
        expect(storeWithActions.state.count, equals(1));

        storeWithActions.actions.decrement();
        expect(storeWithActions.state.count, equals(0));

        storeWithActions.destroy();
      });

      test('should allow direct state updates', () {
        final storeWithActions = createStore<TestState, TestActions>(
          state: (store) => const TestState(count: 0, name: 'actions'),
          createActions: (store) => TestActions(store),
        );

        storeWithActions.setState((state) => state.copyWith(count: 5));
        expect(storeWithActions.state.count, equals(5));

        storeWithActions.destroy();
      });

      test('should support listeners', () {
        final storeWithActions = createStore<TestState, TestActions>(
          state: (store) => const TestState(count: 0, name: 'actions'),
          createActions: (store) => TestActions(store),
        );

        bool listenerCalled = false;
        final unsubscribe = storeWithActions.subscribe((state, previousState) {
          listenerCalled = true;
        });

        storeWithActions.actions.increment();
        expect(listenerCalled, isTrue);

        unsubscribe();
        storeWithActions.destroy();
      });

      test('should support selectors', () {
        final storeWithActions = createStore<TestState, TestActions>(
          state: (store) => const TestState(count: 10, name: 'actions'),
          createActions: (store) => TestActions(store),
        );

        final count = storeWithActions.select((state) => state.count);
        expect(count, equals(10));

        storeWithActions.destroy();
      });

      test('should provide state getter', () {
        final storeWithActions = createStore<TestState, TestActions>(
          state: (store) => const TestState(count: 15, name: 'actions'),
          createActions: (store) => TestActions(store),
        );

        final getState = storeWithActions.getState();
        final state = getState();
        expect(state.count, equals(15));

        storeWithActions.destroy();
      });

      test('should provide API access', () {
        final storeWithActions = createStore<TestState, TestActions>(
          state: (store) => const TestState(count: 0, name: 'actions'),
          createActions: (store) => TestActions(store),
        );

        final api = storeWithActions.api;
        expect(api, isA<ChangeNotifier>());

        storeWithActions.destroy();
      });
    });

    group('Error Handling', () {
      test('should handle concurrent state updates', () {
        store.initialize(const TestState(count: 0, name: 'concurrent'));

        // Simulate concurrent updates
        store.setState((state) => state.copyWith(count: 1));
        store.setState((state) => state.copyWith(count: 2));
        store.setState((state) => state.copyWith(count: 3));

        expect(store.state.count, equals(3));
      });

      test('should handle listener exceptions gracefully', () {
        store.initialize(const TestState(count: 0, name: 'exceptions'));

        store.subscribe((state, previousState) {
          throw Exception('Listener error');
        });

        // Should throw an exception when listener throws
        expect(() {
          store.setState((state) => state.copyWith(count: 1));
        }, throwsException);
      });
    });

    group('Memory Management', () {
      test('should clean up resources on destroy', () {
        store.initialize(const TestState(count: 0, name: 'cleanup'));

        bool listenerCalled = false;
        store.subscribe((state, previousState) {
          listenerCalled = true;
        });

        store.destroy();

        // Should not call listeners after destroy
        expect(listenerCalled, isFalse);
      });

      test('should handle multiple destroy calls', () {
        store.initialize(const TestState(count: 0, name: 'multiple-destroy'));

        store.destroy();
        // Second destroy should not throw
        expect(() => store.destroy(), returnsNormally);
      });
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

class TestActions extends StoreActions<TestState> {
  TestActions(super.store);

  void increment() {
    setState((state) => state.copyWith(count: state.count + 1));
  }

  void decrement() {
    setState((state) => state.copyWith(count: state.count - 1));
  }

  void setName(String name) {
    setState((state) => state.copyWith(name: name));
  }
}
