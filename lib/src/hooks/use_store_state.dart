import 'package:simple_store/src/hooks/use_store_selector.dart';
import 'package:simple_store/src/hooks/use_store_set_state.dart';
import 'package:simple_store/src/store/simple_store.dart';

List<dynamic> useStoreState<T, A, U>(Selector<T, U> selector, {List<Object?>? dependencies}) {
  final selectedState = useStoreSelector<T, A, U>(selector, dependencies: dependencies);
  final setState = useStoreSetState<T, A>();
  return [selectedState, setState];
}
