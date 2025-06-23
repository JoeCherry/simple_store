extension MapExtension<K, V> on Map<K, V> {
  V? elementFor(K key) => containsKey(key) ? this[key] : null;
}
