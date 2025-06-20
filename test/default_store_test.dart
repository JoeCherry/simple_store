import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/src/store/default_store.dart';
import 'package:simple_store/src/store/simple_store_instance.dart';

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

    group('State Updates', () {
      setUp(() {
        store.initialize(const TestState(count: 0, name: 'update'));
      });

      test('should update state', () {
        store.setState((state) => state.copyWith(count: 5));
        expect(store.state.count, equals(5));
      });

      test('should not update state if unchanged', () {
        final initial = store.state;
        store.setState((state) => state);
        expect(store.state, same(initial));
      });
    });

    group('Listeners', () {
      setUp(() {
        store.initialize(const TestState(count: 0, name: 'listener'));
      });

      test('should notify listeners on state change', () {
        bool called = false;
        store.subscribe((state, prev) {
          called = true;
        });
        store.setState((state) => state.copyWith(count: 1));
        expect(called, isTrue);
      });

      test('should remove listeners', () {
        bool called = false;
        final unsubscribe = store.subscribe((state, prev) {
          called = true;
        });
        unsubscribe();
        store.setState((state) => state.copyWith(count: 1));
        expect(called, isFalse);
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
  });

  group('SimpleStoreInstance', () {
    test('should create and update state', () {
      final store = create<TestState>(
        (set) => const TestState(count: 0, name: 'zustand'),
      );
      expect(store.state.count, equals(0));
      store.setState((state) => state.copyWith(count: 5));
      expect(store.state.count, equals(5));
      store.destroy();
    });

    test('should support listeners', () {
      final store = create<TestState>(
        (set) => const TestState(count: 0, name: 'zustand'),
      );
      bool called = false;
      final unsubscribe = store.subscribe((state, prev) {
        called = true;
      });
      store.setState((state) => state.copyWith(count: 1));
      expect(called, isTrue);
      unsubscribe();
      store.destroy();
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
