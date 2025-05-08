import 'package:simple_store/src/hooks/use_store_selector.dart';
import 'package:simple_store/src/hooks/use_store_set_state.dart';
import 'package:simple_store/src/store/store.dart';

List<dynamic> useStoreState<T, U>(Selector<T, U> selector, {List<Object?>? dependencies}) {
  final selectedState = useStoreSelector<T, U>(selector, dependencies: dependencies);
  final setState = useStoreSetState<T>();
  return [selectedState, setState];
}
