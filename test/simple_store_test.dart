import 'global_store_registry_test.dart' as global_store_tests;
import 'default_store_test.dart' as default_store_tests;
import 'equality_test.dart' as equality_tests;

void main() {
  // Run all tests
  global_store_tests.main();
  default_store_tests.main();
  equality_tests.main();
}
