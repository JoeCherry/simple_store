import 'package:collection/collection.dart' as coll;

/// Interface for defining equality between objects
abstract class Equality<T> {
  /// Returns true if a and b are considered equal
  bool equals(T a, T b);

  /// Returns a hash code for the object
  int computeHashCode(T obj);
}

/// Shallow equality - uses reference equality (identical)
class ShallowEquality<T> implements Equality<T> {
  const ShallowEquality();

  @override
  bool equals(T a, T b) => identical(a, b);

  @override
  int computeHashCode(T obj) => obj.hashCode;
}

/// Deep equality - uses the collection package's DeepCollectionEquality
class DeepEquality<T> implements Equality<T> {
  static final coll.DeepCollectionEquality _equality =
      const coll.DeepCollectionEquality();
  const DeepEquality();

  @override
  bool equals(T a, T b) => _equality.equals(a, b);

  @override
  int computeHashCode(T obj) => _equality.hash(obj);
}

/// Collection-specific equalities for better performance
class ListEquality<T> implements Equality<List<T>> {
  final Equality<T> elementEquality;
  final coll.ListEquality<T> _delegate;

  ListEquality({Equality<T>? elementEquality})
    : elementEquality = elementEquality ?? ShallowEquality<T>(),
      _delegate = coll.ListEquality<T>(
        _EqualityAdapter(elementEquality ?? ShallowEquality<T>()),
      );

  @override
  bool equals(List<T> a, List<T> b) => _delegate.equals(a, b);

  @override
  int computeHashCode(List<T> list) => _delegate.hash(list);
}

class MapEquality<K, V> implements Equality<Map<K, V>> {
  final Equality<K> keyEquality;
  final Equality<V> valueEquality;
  final coll.MapEquality<K, V> _delegate;

  MapEquality({Equality<K>? keyEquality, Equality<V>? valueEquality})
    : keyEquality = keyEquality ?? ShallowEquality<K>(),
      valueEquality = valueEquality ?? ShallowEquality<V>(),
      _delegate = coll.MapEquality<K, V>(
        keys: _EqualityAdapter(keyEquality ?? ShallowEquality<K>()),
        values: _EqualityAdapter(valueEquality ?? ShallowEquality<V>()),
      );

  @override
  bool equals(Map<K, V> a, Map<K, V> b) => _delegate.equals(a, b);

  @override
  int computeHashCode(Map<K, V> map) => _delegate.hash(map);
}

class SetEquality<T> implements Equality<Set<T>> {
  final Equality<T> elementEquality;
  final coll.SetEquality<T> _delegate;

  SetEquality({Equality<T>? elementEquality})
    : elementEquality = elementEquality ?? ShallowEquality<T>(),
      _delegate = coll.SetEquality<T>(
        _EqualityAdapter(elementEquality ?? ShallowEquality<T>()),
      );

  @override
  bool equals(Set<T> a, Set<T> b) => _delegate.equals(a, b);

  @override
  int computeHashCode(Set<T> set) => _delegate.hash(set);
}

/// Adapter to bridge our Equality to the collection package's Equality
class _EqualityAdapter<T> implements coll.Equality<T> {
  final Equality<T> _equality;
  const _EqualityAdapter(this._equality);
  @override
  bool equals(T e1, T e2) => _equality.equals(e1, e2);
  @override
  int hash(T e) => _equality.computeHashCode(e);
  @override
  bool isValidKey(Object? o) => o is T;
}

/// Utility function to create appropriate equality for a type
Equality<T> createEquality<T>() {
  // For now, return deep equality as default
  // In the future, this could be enhanced to auto-detect based on type
  return DeepEquality<T>();
}
