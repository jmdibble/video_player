import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/src/subtitles/better_player_subtitle.dart';

void main() {
  group('BetterPlayerSubtitle', () {
    test('Parses WEBVTT header with X-TIMESTAMP-MAP metadata', () {
      const subtitleData = '''
WEBVTT
X-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000
''';

      final subtitle = BetterPlayerSubtitle(subtitleData, true);
      expect(subtitle.index, isNull);
      expect(subtitle.start, isNull);
      expect(subtitle.end, isNull);
      expect(subtitle.texts, isNull);
    });

    test('Parses 2-line subtitle correctly', () {
      const subtitleData = '''
00:00:03.500 --> 00:00:05.000
In this video, you'll learn
''';

      final subtitle = BetterPlayerSubtitle(subtitleData, false);
      expect(subtitle.index, equals(-1));
      expect(subtitle.start, equals(Duration(seconds: 3, milliseconds: 500)));
      expect(subtitle.end, equals(Duration(seconds: 5)));
      expect(subtitle.texts, equals(["In this video, you'll learn"]));
    });

    test('Parses 3-line subtitle correctly', () {
      const subtitleData = '''
1
00:00:03.500 --> 00:00:05.000
In this video, you'll learn
about how Video Cloud Studio is
''';

      final subtitle = BetterPlayerSubtitle(subtitleData, false);
      expect(subtitle.index, equals(1));
      expect(subtitle.start, equals(Duration(seconds: 3, milliseconds: 500)));
      expect(subtitle.end, equals(Duration(seconds: 5)));
      expect(
          subtitle.texts,
          equals([
            "In this video, you'll learn",
            "about how Video Cloud Studio is"
          ]));
    });

    test('Handles invalid subtitle data gracefully', () {
      const invalidData = 'Invalid subtitle data';
      final subtitle = BetterPlayerSubtitle(invalidData, false);
      expect(subtitle.index, isNull);
      expect(subtitle.start, isNull);
      expect(subtitle.end, isNull);
      expect(subtitle.texts, isNull);
    });

    test('Handles WEBVTT header with no subtitle content', () {
      const subtitleData = '''
WEBVTT
''';

      final subtitle = BetterPlayerSubtitle(subtitleData, true);
      expect(subtitle.index, isNull);
      expect(subtitle.start, isNull);
      expect(subtitle.end, isNull);
      expect(subtitle.texts, isNull);
    });

    test('Parses offset from WEBVTT header with X-TIMESTAMP-MAP metadata', () {
      const header = '''
WEBVTT
X-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:10.000
''';

      final offset = BetterPlayerSubtitle.parseOffset(header);
      expect(
        offset,
        equals(Duration(seconds: 10)),
        reason: 'MPEGTS:900000 -> 10 seconds, LOCAL:00:00:10.000 -> offset',
      );
    });

    test('Handles missing X-TIMESTAMP-MAP gracefully', () {
      const header = '''
WEBVTT
''';

      final offset = BetterPlayerSubtitle.parseOffset(header);
      expect(offset, isNull);
    });

    test('Handles invalid X-TIMESTAMP-MAP metadata gracefully', () {
      const header = '''
WEBVTT
X-TIMESTAMP-MAP=INVALID
''';

      final offset = BetterPlayerSubtitle.parseOffset(header);
      expect(offset, isNull);
    });
  });
}
