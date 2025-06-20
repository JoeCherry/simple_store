import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/simple_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

    test('should auto-dispose on AppLifecycleState.detached', () async {
      // Register a store
      createGlobalStoreSimple<TestState>(
        key: 'test',
        creator: (set) => const TestState(count: 0),
      );
      expect(hasGlobalStore('test'), isTrue);
      expect(globalStoreRegistry.length, equals(1));

      // Simulate lifecycle detach event using the recommended approach
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            SystemChannels.lifecycle.name,
            SystemChannels.lifecycle.codec.encodeMessage(
              'AppLifecycleState.detached',
            ),
            (_) {},
          );

      // The registry should now be disposed and all stores cleared
      expect(globalStoreRegistry.length, equals(0));
      expect(() => getGlobalStoreSimple<TestState>('test'), throwsStateError);
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
