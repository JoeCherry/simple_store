import 'package:flutter/widgets.dart';
import 'package:simple_store/src/store/default_store.dart';
import 'package:simple_store/src/store/store_actions.dart';

class StoreProvider<T, A extends StoreActions<T>> extends InheritedWidget {
  final StoreWithActions<T, A> store;

  const StoreProvider({super.key, required this.store, required super.child});

  static StoreWithActions<T, A> of<T, A extends StoreActions<T>>(
    BuildContext context,
  ) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<StoreProvider<T, A>>();
    assert(provider != null, 'No StoreProvider<$T, $A> found in context');
    return provider!.store;
  }

  @override
  bool updateShouldNotify(StoreProvider oldWidget) {
    return store != oldWidget.store;
  }
}
