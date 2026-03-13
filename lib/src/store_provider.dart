import 'package:flutter/widgets.dart';
import 'package:simple_store/src/store/simple_store_instance.dart';

class StoreProvider<T> extends InheritedWidget {
  final SimpleStoreInstance<T> store;

  const StoreProvider({super.key, required this.store, required super.child});

  /// Looks up the store without registering an [InheritedWidget] dependency.
  ///
  /// Use this from hooks — they manage their own subscriptions and don't need
  /// the InheritedWidget rebuild path, which would cause double-rebuilds.
  static SimpleStoreInstance<T> of<T>(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<StoreProvider<T>>();
    if (provider == null) {
      throw StateError('No StoreProvider<$T> found in context');
    }
    return provider.store;
  }

  /// Looks up the store and registers an [InheritedWidget] dependency so the
  /// calling widget rebuilds when the store instance is replaced.
  ///
  /// Use this from non-hook widgets that need InheritedWidget-style reactivity.
  static SimpleStoreInstance<T> ofInherit<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<StoreProvider<T>>();
    if (provider == null) {
      throw StateError('No StoreProvider<$T> found in context');
    }
    return provider.store;
  }

  @override
  bool updateShouldNotify(covariant StoreProvider<T> oldWidget) {
    return store != oldWidget.store;
  }
}
