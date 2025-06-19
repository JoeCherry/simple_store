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

// 3. Create a global store
final counterStore = createGlobalStore<CounterState, CounterActions>(
  key: 'counter',
  state: (store) => const CounterState(count: 0),
  createActions: (store) => CounterActions(store),
);

// 4. Use in your widgets (no provider needed!)
class CounterWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useGlobalStore<CounterState, CounterActions>('counter')
        .select((state) => state.count);
    final actions = useGlobalStoreActions<CounterState, CounterActions>('counter');
    
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: actions.increment,
          child: Text('Increment'),
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
    final count = useStore<CounterState, CounterActions>()
        .select((state) => state.count);
    final setState = useStoreSetState<CounterState, CounterActions>();
    
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => setState((state) => 
            state.copyWith(count: state.count + 1)),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

## API Reference

### Global Store API

- `createGlobalStore<T, A>()` - Create and register a global store
- `useGlobalStore<T, A>(key)` - Hook to access global store state
- `useGlobalStoreSelector<T, A, U>(key, selector)` - Hook to access selected state
- `useGlobalStoreActions<T, A>(key)` - Hook to access store actions
- `useGlobalStoreSetState<T, A>(key)` - Hook to get setState function
- `getGlobalStore<T, A>(key)` - Direct store access
- `hasGlobalStore(key)` - Check if store exists
- `removeGlobalStore(key)` - Remove a store
- `clearGlobalStores()` - Clear all stores

### Provider-based API

- `createStore<T, A>()` - Create a store
- `StoreProvider<T, A>` - Widget to provide store to descendants
- `useStore<T, A>()` - Hook to access store state
- `useStoreSelector<T, A, U>(selector)` - Hook to access selected state
- `useStoreSetState<T, A>()` - Hook to get setState function

## Advanced Usage

### Using Selectors for Performance

```dart
// Only re-render when specific parts of state change
final bears = useGlobalStoreSelector<BearState, BearActions, int>(
  'bearStore',
  (state) => state.bears,
);

final isLoading = useGlobalStoreSelector<BearState, BearActions, bool>(
  'bearStore',
  (state) => state.isLoading,
);
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
  final state = useGlobalStore<BearState, BearActions>('bearStore');
  final actions = useGlobalStoreActions<BearState, BearActions>('bearStore');

  return (
    state: state,
    increase: () => actions.increasePopulation(),
    decrease: () => actions.decreasePopulation(),
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
