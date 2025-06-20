<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Simple Store

A minimal, type-safe, and memory-safe state management solution for Dart/Flutter inspired by Zustand.

## Features
- Simple, composable API
- Global stores (no providers needed)
- Feature-scoped stores (with providers)
- Automatic memory management for global stores
- Type-safe and boilerplate-free

## Quick Start

### 1. Define your state and actions in a single class

```dart
class CounterStore {
  final int count;
  final SetState<CounterStore> _setState;

  CounterStore(this.count, this._setState);

  CounterStore copyWith({int? count}) => CounterStore(count ?? this.count, _setState);

  void increment() {
    _setState((state) => state.copyWith(count: state.count + 1));
  }
  
  void decrement() {
    _setState((state) => state.copyWith(count: state.count - 1));
  }
}
```

### 2. Choose your approach

#### Global Store (app-wide state)
```dart
// Create a global store
final globalCounterStore = createGlobalStoreSimple<CounterStore>(
  key: 'CounterStore',
  creator: (set) => CounterStore(0, set),
);

// Use anywhere in your app - much cleaner!
class CounterWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = useGlobalStore<CounterStore>('CounterStore');

    return Column(
      children: [
        Text('Count: ${store.count}'),
        ElevatedButton(
          onPressed: () => store.increment(), // Call actions directly!
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

#### Feature-scoped Store (isolated to a flow)
```dart
// Create a local store for a specific feature
final accountFlowStore = create<AccountStore>((set) => AccountStore(initialState, set));

// Wrap your feature with StoreProvider
class AccountFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AccountStore>(
      store: accountFlowStore,
      child: AccountFlowWidget(),
    );
  }
}

// Use within the feature scope
class AccountFlowWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = useProvidedStore<AccountStore>();

    return Column(
      children: [
        Text('Account: ${store.name}'),
        ElevatedButton(
          onPressed: () => store.updateName('New Name'), // Call actions directly!
          child: Text('Update'),
        ),
      ],
    );
  }
}
```

## When to Use Each Approach

### Global Stores
- App-wide state (user preferences, authentication)
- State that needs to be accessed from anywhere
- Singleton-like data

### Feature-scoped Stores
- State isolated to a specific feature or flow
- Multiple instances of the same feature (e.g., multiple account creation flows)
- Temporary state that should be cleaned up when the feature is closed

## API

### General Store Hooks (for direct store instances)
- `useStore<T>(store)` — Hook to get the current state from a store instance
- `useStoreSelector<T, U>(store, selector, {equality?})` — Hook to select a value from a store instance with optional equality comparison

### Provided Store Hooks (for feature-scoped stores)
- `useProvidedStore<T>()` — Hook to get state from a provider-scoped store
- `useProvidedStoreSelector<T, U>(selector, {equality?})` — Hook to select from a provider-scoped store with optional equality comparison

### Global Store Hooks (for app-wide stores)
- `useGlobalStore<T>(key)` — Hook to get state from global store by key
- `useGlobalStoreSelector<T, U>(key, selector, {equality?})` — Hook to select from global store by key with optional equality comparison

### Store Creation
- `create<T>(T Function(SetState<T> set))` — Create a local store
- `createGlobalStoreSimple<T>({required String key, required T Function(SetState<T> set) creator})` — Create a global store

### Provider Integration
- `StoreProvider<T>` — Widget to scope a store to a feature
- `getGlobalStoreSimple<T>(key)` — Access a global store by key (low-level API)

## Why?
- Less boilerplate
- Inspired by Zustand, but fully type-safe and Dart/Flutter idiomatic
- Automatic cleanup of unused global stores
- Flexible scoping for different use cases
- Actions are built into the store - no need to manage setState separately

## License
MIT