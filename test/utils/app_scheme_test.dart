import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PiliScheme Cast join URI', () {
    test('matches the Google Cast Intent to Join URI', () {
      expect(
        PiliScheme.isCastJoinUri(Uri.parse('pilikara://cast/join')),
        isTrue,
      );
    });

    test('does not match other PiliKara deep links', () {
      expect(
        PiliScheme.isCastJoinUri(Uri.parse('pilikara://cast')),
        isFalse,
      );
      expect(
        PiliScheme.isCastJoinUri(Uri.parse('pilikara://cast/join/extra')),
        isFalse,
      );
      expect(
        PiliScheme.isCastJoinUri(Uri.parse('bilibili://cast/join')),
        isFalse,
      );
    });
  });
}
