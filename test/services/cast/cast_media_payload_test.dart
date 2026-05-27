import 'package:PiliPlus/services/cast/cast_media_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CastMediaPayload', () {
    test('uses the media URL as content id and infers HLS content type', () {
      final payload = CastMediaPayload(
        url: Uri.parse('https://example.com/video/master.m3u8?token=abc'),
        title: 'Episode 1',
        cover: Uri.parse('https://example.com/cover.jpg'),
        position: const Duration(seconds: 42),
        duration: const Duration(minutes: 24),
        qualityCode: 80,
      );

      expect(
        payload.contentId,
        'https://example.com/video/master.m3u8?token=abc',
      );
      expect(payload.contentType, 'application/x-mpegURL');
      expect(payload.customData, containsPair('qualityCode', 80));
      expect(payload.customData, containsPair('title', 'Episode 1'));
    });

    test('infers common video content types from URL paths', () {
      expect(
        CastMediaPayload(
          url: Uri.parse('https://example.com/video.mp4'),
          title: 'MP4',
        ).contentType,
        'video/mp4',
      );
      expect(
        CastMediaPayload(
          url: Uri.parse('https://example.com/video.webm'),
          title: 'WebM',
        ).contentType,
        'video/webm',
      );
      expect(
        CastMediaPayload(
          url: Uri.parse('https://example.com/video.flv'),
          title: 'FLV',
        ).contentType,
        'video/x-flv',
      );
    });

    test('keeps playback position when replacing URL for quality reload', () {
      final current = CastMediaPayload(
        url: Uri.parse('https://example.com/video-720.mp4'),
        title: 'Episode 1',
        cover: Uri.parse('https://example.com/cover.jpg'),
        position: const Duration(minutes: 3, seconds: 15),
        duration: const Duration(minutes: 24),
        qualityCode: 64,
      );

      final reloaded = current.copyWith(
        url: Uri.parse('https://example.com/video-1080.mp4'),
        qualityCode: 80,
      );

      expect(reloaded.position, const Duration(minutes: 3, seconds: 15));
      expect(reloaded.title, 'Episode 1');
      expect(reloaded.cover, Uri.parse('https://example.com/cover.jpg'));
      expect(reloaded.duration, const Duration(minutes: 24));
      expect(reloaded.qualityCode, 80);
      expect(reloaded.contentId, 'https://example.com/video-1080.mp4');
    });

    test('uses contentTypeOverride over inferred content type', () {
      final payload = CastMediaPayload(
        url: Uri.parse('https://example.com/video.mp4'),
        title: 'DASH',
        contentTypeOverride: 'application/dash+xml',
      );

      expect(payload.contentType, 'application/dash+xml');
    });

    test('merges receiverData into customData', () {
      final payload = CastMediaPayload(
        url: Uri.parse('https://example.com/video.mp4'),
        title: 'Test',
        receiverData: {'key': 'value', 'other': 42},
      );

      expect(payload.customData, containsPair('key', 'value'));
      expect(payload.customData, containsPair('other', 42));
      expect(payload.customData, containsPair('title', 'Test'));
    });

    test('receiverData does not override title in customData', () {
      final payload = CastMediaPayload(
        url: Uri.parse('https://example.com/video.mp4'),
        title: 'Original',
        receiverData: {'title': 'Overridden'},
      );

      expect(payload.customData['title'], 'Original');
    });

    test('clears contentTypeOverride and receiverData via copyWith', () {
      final current = CastMediaPayload(
        url: Uri.parse('https://example.com/video.mp4'),
        title: 'Test',
        contentTypeOverride: 'application/dash+xml',
        receiverData: {'key': 'value'},
      );

      final cleared = current.copyWith(
        clearContentTypeOverride: true,
        clearReceiverData: true,
      );

      expect(cleared.contentTypeOverride, isNull);
      expect(cleared.receiverData, isNull);
      expect(cleared.contentType, 'video/mp4');
      expect(cleared.customData, isNot(contains('key')));
    });

    test('can clear nullable metadata when media metadata changes', () {
      final current = CastMediaPayload(
        url: Uri.parse('https://example.com/video.mp4'),
        title: 'Episode 1',
        cover: Uri.parse('https://example.com/cover.jpg'),
        duration: const Duration(minutes: 24),
        qualityCode: 80,
      );

      final cleared = current.copyWith(
        clearCover: true,
        clearDuration: true,
        clearQualityCode: true,
      );

      expect(cleared.cover, isNull);
      expect(cleared.duration, isNull);
      expect(cleared.qualityCode, isNull);
      expect(cleared.customData, isNot(contains('qualityCode')));
    });
  });
}
