# Simple Store Example

This example demonstrates how to use the `simple_store` package to manage state in a Flutter application.

## Features

- Counter app using `simple_store` for state management
- Demonstrates basic store creation and usage
- Shows how to use hooks with the store

## Getting Started

1. Make sure you have Flutter installed and set up
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the example app

## How it works

The example shows a simple counter app that uses `simple_store` for state management. The main components are:

1. `CounterStore`: A store class that manages the counter state
2. `StoreProvider`: Wraps the app to provide the store to all widgets
3. `useStore` hook: Used to access the store in the widget

The app demonstrates:
- Creating a store using `createStore`
- Using the `StoreProvider` to provide the store
- Accessing the store using the `useStore` hook
- Updating state using `setState` 