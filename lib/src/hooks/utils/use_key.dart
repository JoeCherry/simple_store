/// Resolves the store key for type [T].
///
/// If [key] is provided and non-empty, it is returned as-is.
/// Otherwise, the key is derived from [T.toString()].
///
/// Note: Despite the `use` prefix, this function contains no hook primitives
/// and may be called outside a hook context.
///
/// WARNING: Type-derived keys use [T.toString()], which returns only the
/// simple class name (e.g., "BearStore"). Two types with the same simple
/// name in different libraries will produce the same key and collide.
/// Always provide an explicit [key] for stores that may conflict.
String useKey<T>(String? key) {
  if (key != null && key.isNotEmpty) {
    return key;
  }

  return T.toString();
}
