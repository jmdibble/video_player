import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:video_player/src/subtitles/better_player_subtitle.dart';
import 'package:flutter/material.dart';

class BetterPlayerSubtitlesDrawer extends StatefulWidget {
  final List<BetterPlayerSubtitle> subtitles;
  final BetterPlayerController betterPlayerController;
  final BetterPlayerSubtitlesConfiguration? betterPlayerSubtitlesConfiguration;
  final Stream<bool> playerVisibilityStream;

  const BetterPlayerSubtitlesDrawer({
    Key? key,
    required this.subtitles,
    required this.betterPlayerController,
    this.betterPlayerSubtitlesConfiguration,
    required this.playerVisibilityStream,
  }) : super(key: key);

  @override
  _BetterPlayerSubtitlesDrawerState createState() =>
      _BetterPlayerSubtitlesDrawerState();
}

class _BetterPlayerSubtitlesDrawerState
    extends State<BetterPlayerSubtitlesDrawer> {
  final RegExp htmlRegExp = RegExp(r"<[^>]*>", multiLine: true);
  late TextStyle _innerTextStyle;
  late TextStyle _outerTextStyle;

  VideoPlayerValue? _latestValue;
  BetterPlayerSubtitlesConfiguration? _configuration;
  bool _playerVisible = false;
  bool _subtilesEnabled = false;

  ///Stream used to detect if play controls are visible or not
  late StreamSubscription _visibilityStreamSubscription;

  @override
  void initState() {
    super.initState();
    _visibilityStreamSubscription = widget.playerVisibilityStream.listen((
      state,
    ) {
      setState(() {
        _playerVisible = state;
      });
    });
    widget.betterPlayerController.videoPlayerController!.addListener(
      _updateState,
    );

    _initializeConfiguration();
  }

  void _initializeConfiguration() {
    if (widget.betterPlayerSubtitlesConfiguration != null) {
      _configuration = widget.betterPlayerSubtitlesConfiguration;
    } else {
      _configuration = setupDefaultConfiguration();
    }

    _outerTextStyle = TextStyle(
      fontSize: _configuration!.fontSize,
      fontFamily: _configuration!.fontFamily,
      fontWeight: _configuration!.fontWeight,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _configuration!.outlineSize
        ..color = _configuration!.outlineColor,
    );

    _innerTextStyle = TextStyle(
      fontFamily: _configuration!.fontFamily,
      color: _configuration!.fontColor,
      fontSize: _configuration!.fontSize,
      fontWeight: _configuration!.fontWeight,
    );
  }

  @override
  void didUpdateWidget(covariant BetterPlayerSubtitlesDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.betterPlayerSubtitlesConfiguration !=
        widget.betterPlayerSubtitlesConfiguration) {
      _initializeConfiguration();
    }
    if (oldWidget.betterPlayerController != widget.betterPlayerController) {
      oldWidget.betterPlayerController.videoPlayerController!.removeListener(
        _updateState,
      );
      widget.betterPlayerController.videoPlayerController!.addListener(
        _updateState,
      );
    }
    if (oldWidget.playerVisibilityStream != widget.playerVisibilityStream) {
      _visibilityStreamSubscription.cancel();
      _visibilityStreamSubscription = widget.playerVisibilityStream.listen((
        state,
      ) {
        setState(() {
          _playerVisible = state;
        });
      });
    }
  }

  @override
  void dispose() {
    widget.betterPlayerController.videoPlayerController!.removeListener(
      _updateState,
    );
    _visibilityStreamSubscription.cancel();
    super.dispose();
  }

  ///Called when player state has changed, i.e. new player position, etc.
  void _updateState() {
    if (mounted) {
      setState(() {
        _latestValue =
            widget.betterPlayerController.videoPlayerController!.value;
        _subtilesEnabled =
            widget.betterPlayerController.betterPlayerSubtitlesSource?.type !=
                BetterPlayerSubtitlesSourceType.none;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final BetterPlayerSubtitle? subtitle = _getSubtitleAtCurrentPosition();
    widget.betterPlayerController.renderedSubtitle = subtitle;
    final List<String> subtitles = subtitle?.texts ?? [];
    final List<Widget> textWidgets =
        subtitles.map((text) => _buildSubtitleTextWidget(text)).toList();

    return SizedBox.expand(
      child: SafeArea(
        bottom: _configuration!.useSafeArea,
        left: _configuration!.useSafeArea,
        right: _configuration!.useSafeArea,
        top: _configuration!.useSafeArea,
        child: AnimatedOpacity(
          duration: _configuration!.opacityAnimationDuration,
          curve: _configuration!.opacityAnimationCurve,
          opacity: _subtilesEnabled ? _configuration!.opacity : 0.0,
          child: AnimatedPadding(
            duration: _configuration!.paddingAnimationDuration,
            curve: _configuration!.paddingAnimationCurve,
            padding: EdgeInsets.only(
              bottom: _playerVisible
                  ? _configuration!.bottomPadding + _configuration!.playerHeight
                  : _configuration!.bottomPadding,
              left: _configuration!.leftPadding,
              right: _configuration!.rightPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: textWidgets,
            ),
          ),
        ),
      ),
    );
  }

  BetterPlayerSubtitle? _getSubtitleAtCurrentPosition() {
    if (_latestValue == null) {
      return null;
    }

    final Duration position = _latestValue!.position;
    for (final BetterPlayerSubtitle subtitle
        in widget.betterPlayerController.subtitlesLines) {
      if (subtitle.start! <= position && subtitle.end! >= position) {
        return subtitle;
      }
    }
    return null;
  }

  Widget _buildSubtitleTextWidget(String subtitleText) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: _configuration!.alignment,
            child: _getTextWithStroke(subtitleText),
          ),
        ),
      ],
    );
  }

  Widget _getTextWithStroke(String subtitleText) {
    return Container(
      color: _configuration!.backgroundColor,
      child: Stack(
        children: [
          if (_configuration!.outlineEnabled)
            Text(
              subtitleText,
              style: _outerTextStyle,
              textAlign: _configuration!.textAlign,
            )
          else
            const SizedBox(),
          Text(
            subtitleText,
            style: _innerTextStyle,
            textAlign: _configuration!.textAlign,
          )
        ],
      ),
    );
  }

  BetterPlayerSubtitlesConfiguration setupDefaultConfiguration() {
    return const BetterPlayerSubtitlesConfiguration();
  }
}
