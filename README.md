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

A Flutter state management library inspired by Zustand, providing a simple and efficient way to manage state in Flutter applications.

## Features

- **Provider-based stores**: Traditional Flutter approach with `StoreProvider`
- **Global stores**: Zustand-like direct store access without providers
- **Type-safe actions**: Strongly typed actions with `StoreActions<T>`
- **Selector support**: Efficient state selection with `useStoreSelector`
- **Hook-based API**: Built on Flutter Hooks for reactive state management
- **Immutable state updates**: Predictable state changes

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  simple_store: ^0.0.1
  flutter_hooks: ^0.21.2
```

## Quick Start

### Global Store (Recommended - Zustand-like)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_store/simple_store.dart';

// 1. Define your state
class CounterState {
  final int count;
  const CounterState({required this.count});
  
  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}

// 2. Define your actions
class CounterActions extends StoreActions<CounterState> {
  CounterActions(super.store);
  
  void increment() {
    setState((state) => state.copyWith(count: state.count + 1));
  }
  
  void decrement() {
    setState((state) => state.copyWith(count: state.count - 1));
  }
}

// 3. Create a global store initialization function
StoreWithActions<CounterState, CounterActions> initializeCounterStore() {
  return initializeGlobalStore<CounterState, CounterActions>(
    key: 'counter',
    state: (store) => const CounterState(count: 0),
    createActions: (store) => CounterActions(store),
  );
}

// 4. Initialize at app startup (in main())
void main() {
  // Initialize global stores explicitly
  initializeCounterStore();
  
  runApp(MyApp());
}

// 5. Use in your widgets (no provider needed!)
class CounterWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Get the entire store (state + actions)
    final store = useGlobalStore<CounterState, CounterActions>('counter');
    
    // Or use a selector to get specific state
    final count = useGlobalStore<CounterState, CounterActions>(
      'counter',
      (state) => state.count,
    );
    
    return Column(
      children: [
        Text('Count: ${store.state.count}'),
        Text('Count (selector): ${count.state}'),
        ElevatedButton(
          onPressed: store.actions.increment,
          child: Text('Increment'),
        ),
        ElevatedButton(
          onPressed: count.actions.decrement,
          child: Text('Decrement'),
        ),
      ],
    );
  }
}
```

### Provider-based Store (Traditional Flutter)

```dart
// 1. Create store
final counterStore = createStore<CounterState, CounterActions>(
  state: (store) => const CounterState(count: 0),
  createActions: (store) => CounterActions(store),
);

// 2. Wrap your app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoreProvider<CounterState, CounterActions>(
        store: counterStore,
        child: CounterWidget(),
      ),
    );
  }
}

// 3. Use in widgets
class CounterWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Get the entire store (state + actions)
    final store = useStore<CounterState, CounterActions>();
    
    // Or use a selector to get specific state
    final count = useStore<CounterState, CounterActions>(
      (state) => state.count,
    );
    
    return Column(
      children: [
        Text('Count: ${store.state.count}'),
        Text('Count (selector): ${count.state}'),
        ElevatedButton(
          onPressed: store.actions.increment,
          child: Text('Increment'),
        ),
        ElevatedButton(
          onPressed: count.actions.decrement,
          child: Text('Decrement'),
        ),
      ],
    );
  }
}
```

## API Reference

### Global Store API

- `initializeGlobalStore<T, A>()` - Initialize a global store (idempotent)
- `createGlobalStore<T, A>()` - Create and register a global store
- `useGlobalStore<T, A>(key, [selector])` - Hook to access global store (state + actions)
- `getGlobalStore<T, A>(key)` - Direct store access
- `hasGlobalStore(key)` - Check if store exists
- `removeGlobalStore(key)` - Remove a store
- `clearGlobalStores()` - Clear all stores

### Provider-based API

- `createStore<T, A>()` - Create a store
- `StoreProvider<T, A>` - Widget to provide store to descendants
- `useStore<T, A>([selector])` - Hook to access store (state + actions)

## Advanced Usage

### Using Selectors for Performance

```dart
// Only re-render when specific parts of state change
final bears = useGlobalStore<BearState, BearActions>(
  'bearStore',
  (state) => state.bears,
);

final isLoading = useGlobalStore<BearState, BearActions>(
  'bearStore',
  (state) => state.isLoading,
);

// Access actions from the selected store
bears.actions.increasePopulation();
isLoading.actions.setLoading(true);
```

### Direct Store Access (Zustand-like)

```dart
// Access store from anywhere without hooks
final store = getGlobalStore<BearState, BearActions>('bearStore');
store.actions.increasePopulation();

// Get current state
final currentBears = store.state.bears;
```

### Custom Hooks

```dart
// Create a custom hook for your store
({
  BearState state,
  void Function() increase,
  void Function() decrease,
}) useBearStore() {
  final store = useGlobalStore<BearState, BearActions>('bearStore');

  return (
    state: store.state,
    increase: () => store.actions.increasePopulation(),
    decrease: () => store.actions.decreasePopulation(),
  );
}
```

## Comparison with Zustand

| Feature | Zustand | Simple Store |
|---------|---------|--------------|
| Provider required | ❌ | ✅ (optional) |
| Global store access | ✅ | ✅ |
| Type-safe actions | ✅ | ✅ |
| Selector support | ✅ | ✅ |
| Hook-based API | ✅ | ✅ |
| Immutable updates | ✅ | ✅ |
| DevTools support | ✅ | 🚧 (planned) |

## Examples

See the `example/` directory for complete working examples demonstrating both global and provider-based approaches.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
