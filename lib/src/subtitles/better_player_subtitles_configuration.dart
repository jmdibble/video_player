// Flutter imports:
import 'package:flutter/material.dart';

///Configuration of subtitles - colors/padding/font. Used in
///BetterPlayerConfiguration.
class BetterPlayerSubtitlesConfiguration {
  ///Subtitle font size
  final double fontSize;

  ///Subtitle font color
  final Color fontColor;

  ///Enable outline (border) of the text
  final bool outlineEnabled;

  ///Color of the outline stroke
  final Color outlineColor;

  ///Outline stroke size
  final double outlineSize;

  ///Font family of the subtitle
  final String fontFamily;

  ///Font weight of the subtitle
  final FontWeight fontWeight;

  ///Left padding of the subtitle
  final double leftPadding;

  ///Right padding of the subtitle
  final double rightPadding;

  ///Bottom padding of the subtitle
  final double bottomPadding;

  ///Duration of the padding animation when the subtitle moving
  final Duration paddingAnimationDuration;

  ///Curve of the padding animation when the subtitle moving
  final Curve paddingAnimationCurve;

  ///Height of the player, used to calculate subtitle position
  final double playerHeight;

  ///Use safe area to position subtitles
  final bool useSafeArea;

  ///Text alignment of the subtitle when the subtitle spans more than one line
  final TextAlign textAlign;

  ///Alignment of the subtitle
  final Alignment alignment;

  ///Background color of the subtitle
  final Color backgroundColor;

  const BetterPlayerSubtitlesConfiguration({
    this.fontSize = 14,
    this.fontColor = Colors.white,
    this.fontWeight = FontWeight.normal,
    this.outlineEnabled = true,
    this.outlineColor = Colors.black,
    this.outlineSize = 2.0,
    this.fontFamily = "Roboto",
    this.leftPadding = 8.0,
    this.rightPadding = 8.0,
    this.bottomPadding = 20.0,
    this.textAlign = TextAlign.center,
    this.alignment = Alignment.center,
    this.backgroundColor = Colors.transparent,
    this.playerHeight = 30.0,
    this.useSafeArea = true,
    this.paddingAnimationDuration = const Duration(milliseconds: 300),
    this.paddingAnimationCurve = Curves.easeInOut,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BetterPlayerSubtitlesConfiguration) return false;
    return fontSize == other.fontSize &&
        fontColor == other.fontColor &&
        fontWeight == other.fontWeight &&
        outlineEnabled == other.outlineEnabled &&
        outlineColor == other.outlineColor &&
        outlineSize == other.outlineSize &&
        fontFamily == other.fontFamily &&
        leftPadding == other.leftPadding &&
        rightPadding == other.rightPadding &&
        bottomPadding == other.bottomPadding &&
        textAlign == other.textAlign &&
        alignment == other.alignment &&
        backgroundColor == other.backgroundColor &&
        playerHeight == other.playerHeight &&
        useSafeArea == other.useSafeArea &&
        paddingAnimationDuration == other.paddingAnimationDuration &&
        paddingAnimationCurve == other.paddingAnimationCurve;
  }

  @override
  int get hashCode => Object.hash(
        fontSize,
        fontColor,
        fontWeight,
        outlineEnabled,
        outlineColor,
        outlineSize,
        fontFamily,
        leftPadding,
        rightPadding,
        bottomPadding,
        textAlign,
        alignment,
        backgroundColor,
        playerHeight,
        useSafeArea,
        paddingAnimationDuration,
        paddingAnimationCurve,
      );
}
