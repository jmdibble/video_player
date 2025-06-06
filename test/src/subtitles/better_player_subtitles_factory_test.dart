import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/src/subtitles/better_player_subtitles_factory.dart';
import 'package:video_player/video_player.dart';

void main() {
  group('BetterPlayerSubtitlesFactory', () {
    test('Parses subtitles from memory source', () async {
      final memorySource = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.memory,
        content: '''
WEBVTT

1
00:00:01.000 --> 00:00:02.000
Hello World
''',
      );

      final subtitles =
          await BetterPlayerSubtitlesFactory.parseSubtitles(memorySource);
      expect(subtitles, isNotEmpty);
      expect(subtitles.first.index, equals(1));
      expect(subtitles.first.start, equals(Duration(seconds: 1)));
      expect(subtitles.first.end, equals(Duration(seconds: 2)));
      expect(subtitles.first.texts, equals(["Hello World"]));
    });

    test('Handles empty memory source gracefully', () async {
      final memorySource = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.memory,
        content: '',
      );

      final subtitles =
          await BetterPlayerSubtitlesFactory.parseSubtitles(memorySource);
      expect(subtitles, isEmpty);
    });

    test('Parses vtt1File correctly', () async {
      final memorySource = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.memory,
        content: vtt1File,
      );

      final subtitles =
          await BetterPlayerSubtitlesFactory.parseSubtitles(memorySource);
      expect(subtitles.length, equals(10));
      expect(subtitles.first.index, equals(1));
      expect(subtitles.first.start,
          equals(Duration(seconds: 1, milliseconds: 981)));
      expect(
          subtitles.first.end, equals(Duration(seconds: 4, milliseconds: 682)));
      expect(subtitles.first.texts,
          equals(["We're quite content to be the odd", "browser out."]));

      // Check last element
      expect(subtitles.last.index, equals(10));
      expect(subtitles.last.start,
          equals(Duration(seconds: 29, milliseconds: 810)));
      expect(
          subtitles.last.end, equals(Duration(seconds: 31, milliseconds: 810)));
      expect(subtitles.last.texts,
          equals(["Where another company may value", "the bottom line..."]));
    });

    test('Parses vtt2File correctly', () async {
      final memorySource = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.memory,
        content: vtt2File,
      );

      final subtitles =
          await BetterPlayerSubtitlesFactory.parseSubtitles(memorySource);
      expect(subtitles.length, equals(16));
      expect(subtitles.first.start,
          equals(Duration(seconds: 1, milliseconds: 981)));
      expect(
          subtitles.first.end, equals(Duration(seconds: 4, milliseconds: 682)));
      expect(subtitles.first.texts,
          equals(["We're quite content to be the odd", "browser out."]));

      // Check last element
      expect(subtitles.last.start,
          equals(Duration(seconds: 46, milliseconds: 651)));
      expect(
          subtitles.last.end, equals(Duration(seconds: 48, milliseconds: 525)));
      expect(subtitles.last.texts, equals(["For everyone to see."]));
    });

    test('Parses subtitles with offset from WEBVTT header', () async {
      const vttWithOffset = '''
WEBVTT
X-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000

1
00:00:01.981 --> 00:00:04.682
Hello World
''';

      final memorySource = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.memory,
        content: vttWithOffset,
      );

      final subtitles =
          await BetterPlayerSubtitlesFactory.parseSubtitles(memorySource);
      expect(subtitles, isNotEmpty);
      expect(subtitles.first.index, equals(1));
      expect(
          subtitles.first.start,
          equals(Duration(
              seconds: 1, milliseconds: 981))); // Correct offset applied
      expect(
          subtitles.first.end,
          equals(Duration(
              seconds: 4, milliseconds: 682))); // Correct offset applied
      expect(subtitles.first.texts, equals(["Hello World"]));
    });

    test('Handles subtitles with invalid offset gracefully', () async {
      const vttWithInvalidOffset = '''
WEBVTT
X-TIMESTAMP-MAP=INVALID

1
00:00:01.000 --> 00:00:02.000
Hello World
''';

      final memorySource = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.memory,
        content: vttWithInvalidOffset,
      );

      final subtitles =
          await BetterPlayerSubtitlesFactory.parseSubtitles(memorySource);
      expect(subtitles, isNotEmpty);
      expect(subtitles.first.index, equals(1));
      expect(subtitles.first.start,
          equals(Duration(seconds: 1))); // No offset applied
      expect(subtitles.first.end,
          equals(Duration(seconds: 2))); // No offset applied
      expect(subtitles.first.texts, equals(["Hello World"]));
    });

    test('Handles subtitles with missing offset gracefully', () async {
      const vttWithoutOffset = '''
WEBVTT

1
00:00:01.000 --> 00:00:02.000
Hello World
''';

      final memorySource = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.memory,
        content: vttWithoutOffset,
      );

      final subtitles =
          await BetterPlayerSubtitlesFactory.parseSubtitles(memorySource);
      expect(subtitles, isNotEmpty);
      expect(subtitles.first.index, equals(1));
      expect(subtitles.first.start,
          equals(Duration(seconds: 1))); // No offset applied
      expect(subtitles.first.end,
          equals(Duration(seconds: 2))); // No offset applied
      expect(subtitles.first.texts, equals(["Hello World"]));
    });
  });
}

const vtt1File = '''
WEBVTT FILE

1
00:01.981 --> 00:04.682
We're quite content to be the odd
browser out.

2
00:05.302 --> 00:08.958
We don't have a fancy stock abbreviation 
to go alongside our name in the press.

3
00:09.526 --> 00:11.324
We don't have a profit margin.

4
00:11.413 --> 00:13.979
We don't have sacred rock stars
that we put above others.

5
00:14.509 --> 00:16.913
We don't make the same deals,
sign the same contracts.

6
00:17.227 --> 00:19.789
Or shake the same hands,
as everyone else.

7
00:20.568 --> 00:22.568
And all this... is fine by us.

8
00:23.437 --> 00:27.065
Were are a pack of independently, spirited, 
fiercely unconventional people,

9
00:27.145 --> 00:29.145
who do things a little differently.

10
00:29.810 --> 00:31.810
Where another company may value
the bottom line...
''';

const vtt2File = '''
WEBVTT
X-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000

00:00:01.981 --> 00:00:04.682
We're quite content to be the odd
browser out.

00:00:05.302 --> 00:00:08.958
We don't have a fancy stock abbreviation 
to go alongside our name in the press.

00:00:09.526 --> 00:00:11.324
We don't have a profit margin.

00:00:11.413 --> 00:00:13.979
We don't have sacred rock stars
that we put above others.

00:00:14.509 --> 00:00:16.913
We don't make the same deals,
sign the same contracts.

00:00:17.227 --> 00:00:19.789
Or shake the same hands,
as everyone else.

00:00:20.568 --> 00:00:22.568
And all this... is fine by us.

00:00:23.437 --> 00:00:27.065
Were are a pack of independently, spirited, 
fiercely unconventional people,

00:00:27.145 --> 00:00:29.145
who do things a little differently.

00:00:29.810 --> 00:00:31.810
Where another company may value
the bottom line...

00:00:32.283 --> 00:00:34.583
We value... well, values.

00:00:35.644 --> 00:00:38.012
When a competitor considers 
to make something propriertary.

00:00:38.642 --> 00:00:40.642
We strive to set it free.

00:00:40.929 --> 00:00:44.556
And while most products and technologies 
are developed behind closed doors.

00:00:44.886 --> 00:00:46.606
Ours are cultivated out in the open.

00:00:46.651 --> 00:00:48.525
For everyone to see.
''';
