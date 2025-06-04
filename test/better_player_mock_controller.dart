import 'package:video_player/video_player.dart';

class BetterPlayerMockController extends BetterPlayerController {
  BetterPlayerMockController(
    BetterPlayerConfiguration betterPlayerConfiguration, {
    BetterPlayerPlaylistConfiguration betterPlayerPlaylistConfiguration =
        const BetterPlayerPlaylistConfiguration(),
  }) : super(
         betterPlayerConfiguration,
         betterPlayerPlaylistConfiguration: betterPlayerPlaylistConfiguration,
       );
}
