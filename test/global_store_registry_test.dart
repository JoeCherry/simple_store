import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/simple_store.dart';

void main() {
  group('GlobalStoreRegistry', () {
    tearDown(() {
      clearGlobalStores();
    });

    test('should register and retrieve a store', () {
      final store = createGlobalStoreSimple<TestState>(
        key: 'test',
        creator: (set) => const TestState(count: 0),
      );

      expect(hasGlobalStore('test'), isTrue);
      expect(getGlobalStoreSimple<TestState>('test'), equals(store));
    });

    test('should throw error when accessing non-existent store', () {
      expect(
        () => getGlobalStoreSimple<TestState>('non-existent'),
        throwsStateError,
      );
    });

    test('should remove store correctly', () {
      createGlobalStoreSimple<TestState>(
        key: 'test',
        creator: (set) => const TestState(count: 0),
      );

      expect(hasGlobalStore('test'), isTrue);

      removeGlobalStore('test');
      expect(hasGlobalStore('test'), isFalse);
    });

    test('should clear all stores', () {
      createGlobalStoreSimple<TestState>(
        key: 'test1',
        creator: (set) => const TestState(count: 0),
      );

      createGlobalStoreSimple<TestState>(
        key: 'test2',
        creator: (set) => const TestState(count: 0),
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
