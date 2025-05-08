import 'package:flutter/widgets.dart';
import 'package:simple_store/src/store/store.dart';

class StoreProvider<T> extends InheritedWidget {
  final Store<T> store;

  const StoreProvider({super.key, required this.store, required super.child});

  static Store<T> of<T>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<StoreProvider<T>>();
    assert(provider != null, 'No StoreProvider<$T> found in context');
    return provider!.store;
  }

  @override
  bool updateShouldNotify(StoreProvider oldWidget) {
    return store != oldWidget.store;
  }
}
