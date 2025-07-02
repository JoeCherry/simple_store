import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/simple_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlobalStoreRegistry - Initialization', () {
    test('should throw error when registry is not initialized', () {
      // Reset to simulate uninitialized state
      GlobalStoreRegistry.reset();

      expect(
        () => createGlobalStore<TestState>(
          key: 'test',
          creator: (set) => const TestState(count: 0),
        ),
        throwsArgumentError,
      );
    });

    test('should create instance lazily', () {
      // Reset to ensure no instance exists
      GlobalStoreRegistry.reset();

      // Accessing instance should create it
      final instance = GlobalStoreRegistry.instance;
      expect(instance, isNotNull);

      // Subsequent accesses should return the same instance
      final instance2 = GlobalStoreRegistry.instance;
      expect(identical(instance, instance2), isTrue);
    });

    test(
      'should throw StateError when accessing registry methods before initialization',
      () {
        // Reset to simulate uninitialized state
        GlobalStoreRegistry.reset();

        // Direct registry access should throw StateError
        expect(
          () => GlobalStoreRegistry.instance.getStore<TestState>('test'),
          throwsStateError,
        );
      },
    );
  });

  group('GlobalStoreRegistry', () {
    setUp(() {
      // Initialize the registry for each test
      GlobalStoreRegistry.instance.initialize();
    });

    tearDown(() {
      clearGlobalStores();
      disposeGlobalStoreRegistry();
    });

    test('should register and retrieve a store', () {
      final store = createGlobalStore<TestState>(
        key: 'test',
        creator: (set) => const TestState(count: 0),
      );

      expect(hasGlobalStore('test'), isTrue);
      expect(getGlobalStore<TestState>('test'), equals(store));
    });

    test('should throw error when accessing non-existent store', () {
      expect(() => getGlobalStore<TestState>('non-existent'), throwsStateError);
    });

    test('should remove store correctly', () {
      createGlobalStore<TestState>(
        key: 'test',
        creator: (set) => const TestState(count: 0),
      );

      expect(hasGlobalStore('test'), isTrue);

      removeGlobalStore('test');
      expect(hasGlobalStore('test'), isFalse);
    });

    test('should clear all stores', () {
      createGlobalStore<TestState>(
        key: 'test1',
        creator: (set) => const TestState(count: 0),
      );

      createGlobalStore<TestState>(
        key: 'test2',
        creator: (set) => const TestState(count: 0),
      );

      expect(GlobalStoreRegistry.instance.length, equals(2));

      clearGlobalStores();
      expect(GlobalStoreRegistry.instance.length, equals(0));
    });

    test('should auto-dispose on AppLifecycleState.detached', () async {
      // Register a store
      createGlobalStore<TestState>(
        key: 'test',
        creator: (set) => const TestState(count: 0),
      );
      expect(hasGlobalStore('test'), isTrue);
      expect(GlobalStoreRegistry.instance.length, equals(1));

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
      expect(GlobalStoreRegistry.instance.length, equals(0));
      expect(() => getGlobalStore<TestState>('test'), throwsStateError);
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
