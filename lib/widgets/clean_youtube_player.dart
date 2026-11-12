import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// YouTube iframe player wrapper that injects a document-start UserScript
/// inside all frames to strip YouTube share buttons, video suggestions,
/// channel/title headers, center play/pause chrome, and the YouTube logo.
class CleanYoutubePlayer extends StatefulWidget {
  const CleanYoutubePlayer({
    super.key,
    required this.controller,
    this.width,
    this.aspectRatio = 16 / 9,
    this.onReady,
    this.onEnded,
  });

  final YoutubePlayerController controller;
  final double? width;
  final double aspectRatio;
  final VoidCallback? onReady;
  final void Function(YoutubeMetaData metaData)? onEnded;

  /// Document-start script injected into the YouTube embed frame to hide all
  /// native YouTube overlays (share button, video suggestions, title bar,
  /// center play/pause icon, and YouTube watermark/logo) without hiding `<video>`.
  static const String youtubeHideUiUserScript = r'''
(function () {
  if (window === window.top) return;

  var css = [
    '.ytp-chrome-top,',
    '.ytp-chrome-bottom,',
    '.ytp-gradient-top,',
    '.ytp-gradient-bottom,',
    '.ytp-show-cards-title,',
    '.ytp-title,',
    '.ytp-title-text,',
    '.ytp-title-channel,',
    '.ytp-chrome-top-buttons,',
    '.ytp-share-button,',
    '.ytp-share-button-visible,',
    '.ytp-copylink-button,',
    '.ytp-watch-later-button,',
    '.ytp-watermark,',
    '.ytp-youtube-button,',
    '.ytp-impression-link,',
    '.ytp-pause-overlay,',
    '.ytp-pause-overlay-container,',
    '.ytp-modern-pause-overlay,',
    '.ytp-scroll-min,',
    '.ytp-suggestions,',
    '.ytp-suggestion-set,',
    '.ytp-related-videos,',
    '.ytp-endscreen-content,',
    '.html5-endscreen,',
    '.ytp-ce-element,',
    '.ytp-ce-video,',
    '.ytp-ce-playlist,',
    '.ytp-ce-channel,',
    '.ytp-cards-teaser,',
    '.ytp-cards-button,',
    '.ytp-suggested-action,',
    '.ytp-upnext,',
    '.ytp-fresca-container,',
    '.ytp-large-play-button,',
    '.ytp-cued-thumbnail-overlay,',
    '.ytp-bezel,',
    '.ytp-bezel-text-wrapper,',
    '.ytp-doubletap-ui,',
    '.ytp-doubletap-ui-legacy,',
    '.ytp-iv-player-content,',
    '.ytp-overlay,',
    '.ytp-overlay-bottom-left,',
    '.ytp-overlay-bottom-right,',
    '.player-controls-top,',
    '.player-controls-middle,',
    '.player-controls-bottom,',
    '.player-controls-content,',
    '#player-control-overlay,',
    '.mobile-topbar-header,',
    '.ytm-custom-control,',
    '.ytm-related-videos,',
    '.ytm-endscreen,',
    'a[href*="youtube.com"],',
    'button[aria-label*="Share" i],',
    'button[aria-label*="More videos" i],',
    'a[aria-label*="YouTube" i] {',
    '  display: none !important;',
    '  opacity: 0 !important;',
    '  visibility: hidden !important;',
    '  pointer-events: none !important;',
    '  width: 0 !important;',
    '  height: 0 !important;',
    '}',
    '.html5-video-player > *:not(.html5-video-container):not(:has(video)):not(video) {',
    '  display: none !important;',
    '  opacity: 0 !important;',
    '  visibility: hidden !important;',
    '  pointer-events: none !important;',
    '}'
  ].join('\n');

  function injectStyle() {
    var root = document.head || document.documentElement;
    if (!root) return false;
    if (document.getElementById('cn-hide-yt-ui')) return true;
    var style = document.createElement('style');
    style.id = 'cn-hide-yt-ui';
    style.type = 'text/css';
    style.appendChild(document.createTextNode(css));
    root.appendChild(style);
    return true;
  }

  function hideElement(el) {
    if (!el || !el.style) return;
    if (el.tagName === 'VIDEO') return;
    if (el.classList && el.classList.contains('html5-video-container')) return;
    if (el.querySelector && el.querySelector('video')) return;
    if (el.style.display === 'none') return;
    el.style.setProperty('display', 'none', 'important');
    el.style.setProperty('opacity', '0', 'important');
    el.style.setProperty('visibility', 'hidden', 'important');
    el.style.setProperty('pointer-events', 'none', 'important');
  }

  var scheduled = false;
  function hideDynamicOverlays() {
    scheduled = false;
    injectStyle();
    var player = document.getElementById('movie_player') ||
        document.querySelector('.html5-video-player');
    if (player && player.children) {
      for (var i = 0; i < player.children.length; i++) {
        hideElement(player.children[i]);
      }
    }
    var ctrlOverlay = document.getElementById('player-control-overlay');
    hideElement(ctrlOverlay);
    var overlays = document.querySelectorAll(
      '.player-controls-content, .ytp-chrome-top, .ytp-chrome-bottom, ' +
      '.ytp-pause-overlay, .ytp-pause-overlay-container, .ytp-watermark, ' +
      '.ytp-youtube-button, .ytp-share-button, .ytp-endscreen-content, ' +
      '.ytp-ce-element, .ytp-related-videos'
    );
    for (var j = 0; j < overlays.length; j++) {
      hideElement(overlays[j]);
    }
  }

  function scheduleHide() {
    if (scheduled) return;
    scheduled = true;
    if (typeof requestAnimationFrame === 'function') {
      requestAnimationFrame(hideDynamicOverlays);
    } else {
      setTimeout(hideDynamicOverlays, 16);
    }
  }

  injectStyle();
  document.addEventListener('DOMContentLoaded', hideDynamicOverlays);
  window.addEventListener('load', hideDynamicOverlays);
  if (typeof MutationObserver !== 'undefined') {
    var observer = new MutationObserver(scheduleHide);
    observer.observe(document, { childList: true, subtree: true });
  }
})();
''';

  /// Builds the host HTML wrapper that loads the YouTube IFrame API.
  static String buildPlayerHtml(YoutubePlayerController controller) {
    final String videoIdJson = jsonEncode(controller.initialVideoId);
    final String captionLangJson = jsonEncode(controller.flags.captionLanguage);
    final int ccLoad = controller.flags.enableCaption ? 1 : 0;
    final int autoPlay = controller.flags.autoPlay ? 1 : 0;
    final int loop = controller.flags.loop ? 1 : 0;
    final String endEntry = controller.flags.endAt != null
        ? "'end': ${controller.flags.endAt},"
        : '';

    return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    html, body {
      margin: 0;
      padding: 0;
      background-color: #000000;
      overflow: hidden;
      position: fixed;
      height: 100%;
      width: 100%;
      pointer-events: none;
    }
  </style>
  <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
</head>
<body>
  <div id="player"></div>
  <script>
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    var player;
    var timerId;
    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        height: '100%',
        width: '100%',
        videoId: $videoIdJson,
        playerVars: {
          'controls': 0,
          'playsinline': 1,
          'enablejsapi': 1,
          'fs': 0,
          'rel': 0,
          'showinfo': 0,
          'iv_load_policy': 3,
          'modestbranding': 1,
          'disablekb': 1,
          'loop': $loop,
          'cc_load_policy': $ccLoad,
          'cc_lang_pref': $captionLangJson,
          'autoplay': $autoPlay,
          'start': ${controller.flags.startAt},
          $endEntry
        },
        events: {
          onReady: function(event) {
            window.flutter_inappwebview.callHandler('Ready');
          },
          onStateChange: function(event) {
            sendPlayerStateChange(event.data);
          },
          onPlaybackQualityChange: function(event) {
            window.flutter_inappwebview.callHandler('PlaybackQualityChange', event.data);
          },
          onPlaybackRateChange: function(event) {
            window.flutter_inappwebview.callHandler('PlaybackRateChange', event.data);
          },
          onError: function(error) {
            window.flutter_inappwebview.callHandler('Errors', error.data);
          }
        }
      });
    }

    function sendPlayerStateChange(playerState) {
      clearTimeout(timerId);
      window.flutter_inappwebview.callHandler('StateChange', playerState);
      if (playerState == 1) {
        startSendCurrentTimeInterval();
        sendVideoData(player);
      }
    }

    function sendVideoData(player) {
      var data = player.getVideoData ? player.getVideoData() : {};
      var videoData = {
        'duration': player.getDuration(),
        'title': data.title || '',
        'author': data.author || '',
        'videoId': data.video_id || ''
      };
      window.flutter_inappwebview.callHandler('VideoData', videoData);
    }

    function startSendCurrentTimeInterval() {
      timerId = setInterval(function () {
        window.flutter_inappwebview.callHandler(
          'VideoTime',
          player.getCurrentTime(),
          player.getVideoLoadedFraction()
        );
      }, 100);
    }

    function play() { player.playVideo(); return ''; }
    function pause() { player.pauseVideo(); return ''; }
    function loadById(loadSettings) { player.loadVideoById(loadSettings); return ''; }
    function cueById(cueSettings) { player.cueVideoById(cueSettings); return ''; }
    function loadPlaylist(playlist, index, startAt) {
      player.loadPlaylist(playlist, 'playlist', index, startAt);
      return '';
    }
    function cuePlaylist(playlist, index, startAt) {
      player.cuePlaylist(playlist, 'playlist', index, startAt);
      return '';
    }
    function mute() { player.mute(); return ''; }
    function unMute() { player.unMute(); return ''; }
    function setVolume(volume) { player.setVolume(volume); return ''; }
    function seekTo(position, seekAhead) {
      player.seekTo(position, seekAhead);
      return '';
    }
    function setSize(width, height) { player.setSize(width, height); return ''; }
    function setPlaybackRate(rate) { player.setPlaybackRate(rate); return ''; }
  </script>
</body>
</html>
''';
  }

  @override
  State<CleanYoutubePlayer> createState() => _CleanYoutubePlayerState();
}

class _CleanYoutubePlayerState extends State<CleanYoutubePlayer>
    with WidgetsBindingObserver {
  PlayerState? _cachedPlayerState;
  bool _isPlayerReady = false;
  bool _onLoadStopCalled = false;
  bool _initialLoad = true;

  YoutubePlayerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant CleanYoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      _controller.addListener(_onControllerChanged);
      _isPlayerReady = _controller.value.isReady;
      _initialLoad = !_isPlayerReady;
    }
  }

  void _onControllerChanged() {
    if (_controller.value.isReady && _initialLoad) {
      _initialLoad = false;
      if (_controller.flags.autoPlay) _controller.play();
      if (_controller.flags.mute) _controller.mute();
      widget.onReady?.call();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_cachedPlayerState == PlayerState.playing) {
          _controller.play();
        }
        break;
      case AppLifecycleState.paused:
        _cachedPlayerState = _controller.value.playerState;
        _controller.pause();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _handleStateChange(int code) {
    switch (code) {
      case -1:
        _controller.updateValue(
          _controller.value.copyWith(
            playerState: PlayerState.unStarted,
            isLoaded: true,
          ),
        );
        break;
      case 0:
        if (_controller.flags.loop) {
          _controller.load(
            _controller.metadata.videoId.isNotEmpty
                ? _controller.metadata.videoId
                : _controller.initialVideoId,
            startAt: _controller.flags.startAt,
            endAt: _controller.flags.endAt,
          );
        }
        widget.onEnded?.call(_controller.metadata);
        _controller.updateValue(
          _controller.value.copyWith(playerState: PlayerState.ended),
        );
        break;
      case 1:
        _controller.updateValue(
          _controller.value.copyWith(
            playerState: PlayerState.playing,
            isPlaying: true,
            hasPlayed: true,
            errorCode: 0,
          ),
        );
        break;
      case 2:
        _controller.updateValue(
          _controller.value.copyWith(
            playerState: PlayerState.paused,
            isPlaying: false,
          ),
        );
        break;
      case 3:
        _controller.updateValue(
          _controller.value.copyWith(playerState: PlayerState.buffering),
        );
        break;
      case 5:
        _controller.updateValue(
          _controller.value.copyWith(playerState: PlayerState.cued),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userAgent = _controller.flags.forceHD
        ? 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/77.0.3865.90 Safari/537.36'
        : '';

    return Material(
      elevation: 0,
      color: Colors.black,
      child: InheritedYoutubePlayer(
        controller: _controller,
        child: Container(
          color: Colors.black,
          width: widget.width ?? MediaQuery.sizeOf(context).width,
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: InAppWebView(
                    initialUserScripts: UnmodifiableListView<UserScript>([
                      UserScript(
                        source: CleanYoutubePlayer.youtubeHideUiUserScript,
                        injectionTime:
                            UserScriptInjectionTime.AT_DOCUMENT_START,
                        forMainFrameOnly: false,
                        allowedOriginRules: const {'*'},
                      ),
                    ]),
                    initialData: InAppWebViewInitialData(
                      data: CleanYoutubePlayer.buildPlayerHtml(_controller),
                      encoding: 'utf-8',
                      baseUrl: WebUri.uri(Uri.https('youtube-nocookie.com')),
                      mimeType: 'text/html',
                    ),
                    initialSettings: InAppWebViewSettings(
                      userAgent: userAgent,
                      mediaPlaybackRequiresUserGesture: false,
                      transparentBackground: true,
                      disableContextMenu: true,
                      supportZoom: false,
                      disableHorizontalScroll: false,
                      disableVerticalScroll: false,
                      allowsInlineMediaPlayback: true,
                      allowsAirPlayForMediaPlayback: true,
                      allowsPictureInPictureMediaPlayback: true,
                      useWideViewPort: false,
                      useHybridComposition:
                          _controller.flags.useHybridComposition,
                    ),
                    onWebViewCreated: (webController) {
                      _controller.updateValue(
                        _controller.value.copyWith(
                          webViewController: webController,
                        ),
                      );
                      webController
                        ..addJavaScriptHandler(
                          handlerName: 'Ready',
                          callback: (_) {
                            _isPlayerReady = true;
                            if (_onLoadStopCalled) {
                              _controller.updateValue(
                                _controller.value.copyWith(isReady: true),
                              );
                            }
                          },
                        )
                        ..addJavaScriptHandler(
                          handlerName: 'StateChange',
                          callback: (args) {
                            if (args.isEmpty) return;
                            _handleStateChange((args.first as num).toInt());
                          },
                        )
                        ..addJavaScriptHandler(
                          handlerName: 'PlaybackQualityChange',
                          callback: (args) {
                            if (args.isEmpty) return;
                            _controller.updateValue(
                              _controller.value.copyWith(
                                playbackQuality: args.first as String?,
                              ),
                            );
                          },
                        )
                        ..addJavaScriptHandler(
                          handlerName: 'PlaybackRateChange',
                          callback: (args) {
                            if (args.isEmpty) return;
                            final num rate = args.first as num;
                            _controller.updateValue(
                              _controller.value.copyWith(
                                playbackRate: rate.toDouble(),
                              ),
                            );
                          },
                        )
                        ..addJavaScriptHandler(
                          handlerName: 'Errors',
                          callback: (args) {
                            if (args.isEmpty) return;
                            final int errorCode = args.first is int
                                ? args.first as int
                                : int.tryParse(args.first.toString()) ?? -1;
                            _controller.updateValue(
                              _controller.value.copyWith(errorCode: errorCode),
                            );
                          },
                        )
                        ..addJavaScriptHandler(
                          handlerName: 'VideoData',
                          callback: (args) {
                            if (args.isEmpty || args.first is! Map) return;
                            final map =
                                Map<String, dynamic>.from(args.first as Map);
                            _controller.updateValue(
                              _controller.value.copyWith(
                                metaData: YoutubeMetaData.fromRawData(map),
                              ),
                            );
                          },
                        )
                        ..addJavaScriptHandler(
                          handlerName: 'VideoTime',
                          callback: (args) {
                            if (args.length < 2) return;
                            final double posMs =
                                (args.first as num).toDouble() * 1000;
                            final num buffered = args.last as num;
                            _controller.updateValue(
                              _controller.value.copyWith(
                                position:
                                    Duration(milliseconds: posMs.floor()),
                                buffered: buffered.toDouble(),
                              ),
                            );
                          },
                        );
                    },
                    onLoadStop: (_, __) {
                      _onLoadStopCalled = true;
                      if (_isPlayerReady) {
                        _controller.updateValue(
                          _controller.value.copyWith(isReady: true),
                        );
                      }
                    },
                  ),
                ),
                if (!_controller.value.hasPlayed &&
                    !_controller.value.hasError)
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE50914),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                if (_controller.value.hasError)
                  Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Center(
                      child: Text(
                        _errorMessage(_controller.value.errorCode),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _errorMessage(int errorCode) {
    switch (errorCode) {
      case 1:
        return 'Invalid Video ID';
      case 2:
        return 'The request contains an invalid parameter value.';
      case 5:
        return 'The requested content cannot be played by the player.';
      case 100:
        return 'The video requested was not found.';
      case 101:
      case 150:
        return 'Playback on other apps has been disabled by the video owner.';
      default:
        return 'Unable to play video (Error $errorCode).';
    }
  }
}

