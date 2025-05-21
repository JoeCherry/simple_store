import 'package:simple_store/src/store/simple_store.dart';

/// Base class for all store actions
/// This provides type safety and structure for store actions
abstract class StoreActions<T> {
  final SimpleStore<T> store;

  const StoreActions(this.store);

  /// Helper method to update state
  void setState(T Function(T currentState) updater) => store.setState(updater);

  /// Helper method to replace state
  void setStateRaw(T nextState) => store.setStateRaw(nextState);

  /// Helper method to get current state
  T get state => store.state;
}
