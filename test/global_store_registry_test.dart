import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/simple_store.dart';

void main() {
  group('GlobalStoreRegistry', () {
    tearDown(() {
      clearGlobalStores();
    });

    test('should register and retrieve a store', () {
      final store = createGlobalStore<TestState, TestActions>(
        key: 'test',
        state: (store) => const TestState(count: 0),
        createActions: (store) => TestActions(store),
      );

      expect(hasGlobalStore('test'), isTrue);
      expect(getGlobalStore<TestState, TestActions>('test'), equals(store));
    });

    test('should throw error when accessing non-existent store', () {
      expect(
        () => getGlobalStore<TestState, TestActions>('non-existent'),
        throwsStateError,
      );
    });

    test('should remove store correctly', () {
      createGlobalStore<TestState, TestActions>(
        key: 'test',
        state: (store) => const TestState(count: 0),
        createActions: (store) => TestActions(store),
      );

      expect(hasGlobalStore('test'), isTrue);

      removeGlobalStore('test');
      expect(hasGlobalStore('test'), isFalse);
    });

    test('should clear all stores', () {
      createGlobalStore<TestState, TestActions>(
        key: 'test1',
        state: (store) => const TestState(count: 0),
        createActions: (store) => TestActions(store),
      );

      createGlobalStore<TestState, TestActions>(
        key: 'test2',
        state: (store) => const TestState(count: 0),
        createActions: (store) => TestActions(store),
      );

      expect(globalStoreRegistry.length, equals(2));

      clearGlobalStores();
      expect(globalStoreRegistry.length, equals(0));
    });
  });
}

class TestState {
  final int count;
  const TestState({required this.count});

  TestState copyWith({int? count}) {
    return TestState(count: count ?? this.count);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestState && other.count == count;
  }

  @override
  int get hashCode => count.hashCode;
}

class TestActions extends StoreActions<TestState> {
  TestActions(super.store);

  void increment() {
    setState((state) => state.copyWith(count: state.count + 1));
  }

  void decrement() {
    setState((state) => state.copyWith(count: state.count - 1));
  }
}
