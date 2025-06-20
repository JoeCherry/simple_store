/// Generates a key for global store access
/// If no key is provided, generates a type-based key
String useKey<T>(String? key) {
  if (key != null && key.isNotEmpty) {
    return key;
  }

  return T.runtimeType.toString();
}
