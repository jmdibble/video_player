import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
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
      // If this is WebVTT content, check if it should be rejected
      if (isWebVTT && shouldRejectWebVTTBlock(value)) {
        return BetterPlayerSubtitle._();
      }

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

  /// Determines if a WebVTT block should be rejected during individual parsing
  static bool shouldRejectWebVTTBlock(String value) {
    final trimmed = value.trim();

    // Reject WEBVTT header
    if (trimmed == "WEBVTT" || trimmed.startsWith("WEBVTT")) {
      return true;
    }

    // Reject NOTE sections
    if (trimmed.startsWith("NOTE")) {
      return true;
    }

    // Check if the block contains timing information (essential for subtitles)
    if (!trimmed.contains('-->')) {
      // This block doesn't contain timing info, reject it
      return true;
    }

    // Reject metadata lines that don't contain timing information
    final lines = trimmed.split('\n');
    if (lines.length <= 2) {
      // Check if it's a metadata line (contains : but no -->)
      for (final line in lines) {
        if (line.contains(':') &&
            !line.contains('-->') &&
            !RegExp(r'^\d+$').hasMatch(line.trim())) {
          return true;
        }
      }
    }

    return false;
  }

  static BetterPlayerSubtitle _handle2LinesSubtitles(
    List<String> scanner, [
    Duration? offset,
  ]) {
    try {
      final timeSplit = scanner[0].split(timerSeparator);
      final start = stringToDuration(timeSplit[0]) - (offset ?? Duration.zero);
      final end = stringToDuration(timeSplit[1]) - (offset ?? Duration.zero);
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

      final start = stringToDuration(timeSplit[0]) - (offset ?? Duration.zero);
      final end = stringToDuration(timeSplit[1]) - (offset ?? Duration.zero);
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

  /// This is not fully compliant with the WebVTT specification,
  /// as we don't have information about presentation-time-stamp of the frame.
  /// So we're not going to offset the subtitle by MPEGTS but only by LOCAL time.
  static Duration? parseOffset(String header) {
    try {
      if (header.contains("X-TIMESTAMP-MAP=")) {
        final parts = header.split("X-TIMESTAMP-MAP=")[1].split(',');
        final mpegTsPart =
            parts.firstWhereOrNull((part) => part.startsWith("MPEGTS:"));
        final localPart =
            parts.firstWhereOrNull((part) => part.startsWith("LOCAL:"));

        if (mpegTsPart == null || localPart == null) {
          return null;
        }

        // final mpegTsValue = int.tryParse(mpegTsPart.split(":")[1]) ?? 0;
        final localValue = stringToDuration(localPart.split("LOCAL:")[1]);

        // final mpegTsInSeconds = Duration.zero;
        return localValue;
      }
    } on Exception catch (_) {
      BetterPlayerUtils.log("Failed to parse offset from header: $header");
    }
    return null;
  }

  @visibleForTesting
  static Duration stringToDuration(String value) {
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
