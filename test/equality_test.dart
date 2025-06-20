import 'package:flutter_test/flutter_test.dart';
import 'package:simple_store/src/equality/equality.dart';

void main() {
  group('Equality System', () {
    group('ShallowEquality', () {
      test('should use reference equality', () {
        const equality = ShallowEquality<_RefClass>();
        final a = _RefClass('hello');
        final b = _RefClass('hello');
        final c = a; // Same reference

        expect(equality.equals(a, c), isTrue); // Same reference
        expect(
          equality.equals(a, b),
          isFalse,
        ); // Different references, same content
      });
    });

    group('DeepEquality', () {
      test('should handle null values', () {
        const equality = DeepEquality<String?>();
        expect(equality.equals(null, null), isTrue);
        expect(equality.equals('hello', null), isFalse);
        expect(equality.equals(null, 'hello'), isFalse);
      });

      test('should handle lists', () {
        const equality = DeepEquality<List<int>>();
        final a = [1, 2, 3];
        final b = [1, 2, 3];
        final c = [1, 2, 4];

        expect(equality.equals(a, b), isTrue);
        expect(equality.equals(a, c), isFalse);
        expect(equality.equals(a, [1, 2]), isFalse);
      });

      test('should handle maps', () {
        const equality = DeepEquality<Map<String, int>>();
        final a = {'a': 1, 'b': 2};
        final b = {'a': 1, 'b': 2};
        final c = {'a': 1, 'b': 3};

        expect(equality.equals(a, b), isTrue);
        expect(equality.equals(a, c), isFalse);
        expect(equality.equals(a, {'a': 1}), isFalse);
      });

      test('should handle sets', () {
        const equality = DeepEquality<Set<int>>();
        final a = {1, 2, 3};
        final b = {1, 2, 3};
        final c = {1, 2, 4};

        expect(equality.equals(a, b), isTrue);
        expect(equality.equals(a, c), isFalse);
        expect(equality.equals(a, {1, 2}), isFalse);
      });

      test('should handle nested structures', () {
        const equality = DeepEquality<List<Map<String, List<int>>>>();
        final a = [
          {
            'a': [1, 2],
            'b': [3, 4],
          },
          {
            'c': [5, 6],
          },
        ];
        final b = [
          {
            'a': [1, 2],
            'b': [3, 4],
          },
          {
            'c': [5, 6],
          },
        ];
        final c = [
          {
            'a': [1, 2],
            'b': [3, 5],
          }, // Different value
          {
            'c': [5, 6],
          },
        ];

        expect(equality.equals(a, b), isTrue);
        expect(equality.equals(a, c), isFalse);
      });
    });

    group('ListEquality', () {
      test('should use element equality', () {
        final equality = ListEquality<_RefClass>(
          elementEquality: ShallowEquality(),
        );
        final a = [_RefClass('a'), _RefClass('b')];
        final b = [_RefClass('a'), _RefClass('b')];
        final c = [a[0], a[1]];

        expect(equality.equals(a, b), isFalse); // Different references
        expect(equality.equals(a, c), isTrue); // Same references
      });
    });

    group('MapEquality', () {
      test('should use key and value equality', () {
        final equality = MapEquality<String, int>();
        final a = <String, int>{'a': 1, 'b': 2};
        final b = <String, int>{'a': 1, 'b': 2};
        final c = <String, int>{'a': 1, 'b': 3};

        expect(equality.equals(a, b), isTrue);
        expect(equality.equals(a, c), isFalse);
      });

      test('should work with custom types', () {
        final equality = MapEquality<_RefClass, _RefClass>(
          keyEquality: ShallowEquality<_RefClass>(),
          valueEquality: ShallowEquality<_RefClass>(),
        );
        final key1 = _RefClass('key1');
        final key2 = _RefClass('key2');
        final value1 = _RefClass('value1');
        final value2 = _RefClass('value2');

        final a = {key1: value1, key2: value2};
        final b = {key1: value1, key2: value2};
        final c = {
          _RefClass('key1'): _RefClass('value1'),
          _RefClass('key2'): _RefClass('value2'),
        };

        expect(equality.equals(a, b), isTrue); // Same references
        expect(equality.equals(a, c), isFalse); // Different references
      });
    });

    group('SetEquality', () {
      test('should use element equality', () {
        final equality = SetEquality<_RefClass>(
          elementEquality: ShallowEquality(),
        );
        final a = {_RefClass('a'), _RefClass('b')};
        final b = {_RefClass('a'), _RefClass('b')};
        final c = {a.first, a.last};

        expect(equality.equals(a, b), isFalse); // Different references
        expect(equality.equals(a, c), isTrue); // Same references
      });
    });
  });
}

// Helper class for testing reference equality
class _RefClass {
  final String value;
  _RefClass(this.value);
}
