### 1.0.8

**Features**

- use safe area and player height for subtitles positioning
- use animated padding for subtitles moving

**Refactor**

- handle subtitles drawer configuration changes

### 1.0.7

**Bug Fixes**

- handle HLS subtitles that start with header WEBVTT e.g. from cloudflare, fixes #4

**Refactor**

- do not support html tags in the subtitles anymore, introduce support for text alignment using Flutter's Text widget

### 1.0.6

- forked from awesome_video_player at 1.0.5
- make android build work again (fixes #1), update Java to 17, update AGP to 8.3.1, update gradle wrapper to 8.10
- use correct foreground service type android:foregroundServiceType='mediaPlayback' and permission android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK (fixes #2)
- handle HLS and Dash video formats in example app (fixes #3)

### 1.0.5

- fix: improve DateTime validation and expose progress bar by @Mazen-Almortada in #22

### 1.0.4

- fix(ios): fixed allowedScreenSleep parameter not being respected in ios AVPlayer which caused the screen to never sleep during video playback by @nateshmbhat in #17

### 1.0.3

- Updates flutter_widget_from_html_core to latest version

### 1.0.2

- Updates Readme with relevant info

## 1.0.0

- Initial release. Forked from better_player_plus
