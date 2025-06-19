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
  CounterStore(this.count);

  CounterStore copyWith({int? count}) => CounterStore(count ?? this.count);

  void increment(SetState<CounterStore> set) {
    set((state) => state.copyWith(count: state.count + 1));
  }
  void decrement(SetState<CounterStore> set) {
    set((state) => state.copyWith(count: state.count - 1));
  }
}
```

### 2. Choose your approach

#### Global Store (app-wide state)
```dart
// Create a global store
final globalCounterStore = createGlobalStoreSimple<CounterStore>(
  key: 'counter',
  creator: (set) => CounterStore(0),
);

// Use anywhere in your app
class CounterWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = useSimpleStore(globalCounterStore);
    final setStore = useSimpleStoreSetState(globalCounterStore);

    return Column(
      children: [
        Text('Count: ${store.count}'),
        ElevatedButton(
          onPressed: () => store.increment(setStore),
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
final accountFlowStore = create<AccountStore>((set) => AccountStore());

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
    final store = useStore<AccountStore>();
    final setStore = useStoreSetState<AccountStore>();

    return Column(
      children: [
        Text('Account: ${store.name}'),
        ElevatedButton(
          onPressed: () => store.updateName(setStore, 'New Name'),
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

### Global Stores
- `create<T>(T Function(SetState<T> set))` — Create a local store
- `createGlobalStoreSimple<T>({required String key, required T Function(SetState<T> set) creator})` — Create a global store
- `useSimpleStore(store)` — Hook to get the current state
- `useSimpleStoreSetState(store)` — Hook to get the setState function
- `useSimpleStoreSelector(store, selector)` — Hook to select a value
- `getGlobalStoreSimple<T>(key)` — Access a global store by key

### Feature-scoped Stores
- `StoreProvider<T>` — Widget to scope a store to a feature
- `useStore<T>()` — Hook to get state from provider
- `useStoreSetState<T>()` — Hook to get setState from provider
- `useStoreSelector<T, U>(selector)` — Hook to select from provider

## Why?
- Less boilerplate
- Inspired by Zustand, but fully type-safe and Dart/Flutter idiomatic
- Automatic cleanup of unused global stores
- Flexible scoping for different use cases

## License
MIT
