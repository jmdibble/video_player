import 'package:collection/collection.dart';
import 'package:video_player/src/core/better_player_utils.dart';

class BetterPlayerSubtitle {
  static const String timerSeparator = ' --> ';
  final int? index;
  final Duration? start;
  final Duration? end;
  final List<String>? texts;

  BetterPlayerSubtitle._({
    this.index,
    this.start,
    this.end,
    this.texts,
  });

  factory BetterPlayerSubtitle(
    String value,
    bool isWebVTT, [
    Duration? offset,
  ]) {
    try {
      final scanner = value.split('\n');
      if (scanner.isNotEmpty && scanner[0] == 'WEBVTT') {
        return BetterPlayerSubtitle._();
      }
      if (scanner.length == 2) {
        return _handle2LinesSubtitles(scanner, offset);
      }
      if (scanner.length > 2) {
        return _handle3LinesAndMoreSubtitles(scanner, isWebVTT, offset);
      }
      return BetterPlayerSubtitle._();
    } on Exception catch (_) {
      BetterPlayerUtils.log("Failed to parse subtitle line: $value");
      return BetterPlayerSubtitle._();
    }
  }

  static BetterPlayerSubtitle _handle2LinesSubtitles(
    List<String> scanner, [
    Duration? offset,
  ]) {
    try {
      final timeSplit = scanner[0].split(timerSeparator);
      final start = _stringToDuration(timeSplit[0]) - (offset ?? Duration.zero);
      final end = _stringToDuration(timeSplit[1]) - (offset ?? Duration.zero);
      final texts = scanner
          .sublist(1, scanner.length)
          .where((text) => text.trim().isNotEmpty)
          .toList();

      return BetterPlayerSubtitle._(
        index: -1,
        start: start,
        end: end,
        texts: texts,
      );
    } on Exception catch (_) {
      BetterPlayerUtils.log("Failed to parse subtitle line: $scanner");
      return BetterPlayerSubtitle._();
    }
  }

  static BetterPlayerSubtitle _handle3LinesAndMoreSubtitles(
    List<String> scanner,
    bool isWebVTT, [
    Duration? offset,
  ]) {
    try {
      int? index = -1;
      List<String> timeSplit = [];
      int firstLineOfText = 0;
      if (scanner[0].contains(timerSeparator)) {
        timeSplit = scanner[0].split(timerSeparator);
        firstLineOfText = 1;
      } else {
        index = int.tryParse(scanner[0]);
        timeSplit = scanner[1].split(timerSeparator);
        firstLineOfText = 2;
      }

      final start = _stringToDuration(timeSplit[0]) - (offset ?? Duration.zero);
      final end = _stringToDuration(timeSplit[1]) - (offset ?? Duration.zero);
      final texts = scanner
          .sublist(firstLineOfText, scanner.length)
          .where((text) => text.trim().isNotEmpty)
          .toList();
      return BetterPlayerSubtitle._(
        index: index,
        start: start,
        end: end,
        texts: texts,
      );
    } on Exception catch (_) {
      BetterPlayerUtils.log("Failed to parse subtitle line: $scanner");
      return BetterPlayerSubtitle._();
    }
  }

  static Duration? parseOffset(String header) {
    try {
      if (header.contains("X-TIMESTAMP-MAP=")) {
        final parts = header.split("X-TIMESTAMP-MAP=")[1].split(',');
        final mpegTsPart =
            parts.firstWhereOrNull((part) => part.startsWith("MPEGTS:"));
        final localPart =
            parts.firstWhereOrNull((part) => part.startsWith("LOCAL:"));

        if (mpegTsPart == null || localPart == null) {
          return null; // Invalid format, return null
        }

        final mpegTsValue = int.tryParse(mpegTsPart.split(":")[1]) ?? 0;
        final localValue = _stringToDuration(localPart.split(":")[1]);

        // Calculate offset: MPEGTS in seconds minus LOCAL time
        final mpegTsInSeconds =
            Duration(milliseconds: (mpegTsValue / 90).round());
        return mpegTsInSeconds - localValue;
      }
    } on Exception catch (_) {
      BetterPlayerUtils.log("Failed to parse offset from header: $header");
    }
    return null;
  }

  static Duration _stringToDuration(String value) {
    try {
      final valueSplit = value.split(" ");
      String componentValue;

      if (valueSplit.length > 1) {
        componentValue = valueSplit[0];
      } else {
        componentValue = value;
      }

      final component = componentValue.split(':');
      // Interpret a missing hour component to mean 00 hours
      if (component.length == 2) {
        component.insert(0, "00");
      } else if (component.length != 3) {
        return const Duration();
      }

      final secsAndMillisSplitChar = component[2].contains(',') ? ',' : '.';
      final secsAndMillsSplit = component[2].split(secsAndMillisSplitChar);
      if (secsAndMillsSplit.length != 2) {
        return const Duration();
      }

      final result = Duration(
        hours: int.tryParse(component[0])!,
        minutes: int.tryParse(component[1])!,
        seconds: int.tryParse(secsAndMillsSplit[0])!,
        milliseconds: int.tryParse(secsAndMillsSplit[1])!,
      );
      return result;
    } on Exception catch (_) {
      BetterPlayerUtils.log("Failed to process value: $value");
      return const Duration();
    }
  }

  @override
  String toString() {
    return 'BetterPlayerSubtitle{index: $index, start: $start, end: $end, texts: $texts}';
  }
}
