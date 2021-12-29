import 'package:test/test.dart';
import 'package:json_to_floor_entity/utils/extensions.dart';

void main() {
  test('to Title case', () {
    var original = 'article sort';
    var expected = 'ArticleSort';
    var result = original.toTitleCase();
    expect(result, expected);
  });
  test('to Camel case', () {
    var original = 'article_sort';
    var expected = 'articleSort';
    var result = original.toCamelCase();
    expect(result, expected);
  });
}


// usage : dart bin/json_to_floor_entity.dart -c true