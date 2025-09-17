import 'package:flutter/material.dart';
import 'package:noviindus_round_two_task/domain/entities/feed_entity.dart';
import 'package:noviindus_round_two_task/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class FeedCardWidget extends StatefulWidget {
  final FeedEntity feed;

  const FeedCardWidget({Key? key, required this.feed}) : super(key: key);

  @override
  State<FeedCardWidget> createState() {
    return _FeedCardWidgetState();
  }
}

class _FeedCardWidgetState extends State<FeedCardWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.feed.video);
    _controller.setLooping(true);
    _controller.initialize().then((void value) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
    _controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    if (!mounted) {
      return;
    }
    setState(() {
      _position = _controller.value.position;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  void _syncWithProvider(HomeProvider home) {
    bool shouldPlay = false;
    if (home.playingFeedId == widget.feed.id) {
      shouldPlay = true;
    } else {
      shouldPlay = false;
    }

    if (_initialized == false) {
      return;
    }

    if (shouldPlay == true) {
      if (_controller.value.isPlaying == false) {
        _controller.play();
      }
    } else {
      if (_controller.value.isPlaying == true) {
        _controller.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeProvider home = Provider.of<HomeProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncWithProvider(home);
      }
    });

    bool isPlaying = false;
    if (home.playingFeedId == widget.feed.id &&
        _initialized == true &&
        _controller.value.isPlaying == true) {
      isPlaying = true;
    } else {
      isPlaying = false;
    }

    String userInitial = 'U';
    String? userImageUrl = widget.feed.userImage;
    ImageProvider? avatarImage;
    if (userImageUrl != null && userImageUrl.isNotEmpty) {
      avatarImage = NetworkImage(userImageUrl);
    } else {
      avatarImage = null;
    }
    if (widget.feed.userName != null && widget.feed.userName!.isNotEmpty) {
      userInitial = widget.feed.userName!.substring(0, 1);
    }

    bool hasThumbnail = false;
    if (widget.feed.thumbnail.isNotEmpty) {
      hasThumbnail = true;
    } else {
      hasThumbnail = false;
    }

    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundImage: avatarImage,
                  child: avatarImage == null ? Text(userInitial) : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.feed.userName ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '5 days ago',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              if (home.playingFeedId == widget.feed.id) {
                if (_showControls == true) {
                  setState(() {
                    _showControls = false;
                  });
                } else {
                  setState(() {
                    _showControls = true;
                  });
                }
              } else {
                home.setPlayingFeed(widget.feed.id);
              }
            },
            child: _buildVideoArea(isPlaying, hasThumbnail),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.feed.description,
              style: TextStyle(color: const Color(0xFFD5D5D5), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea(bool isPlaying, bool hasThumbnail) {
    if (isPlaying == false || _initialized == false) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            hasThumbnail == true
                ? Positioned.fill(
                    child: Image.network(
                      widget.feed.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(color: Colors.grey.shade800),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.black,
                size: 36,
              ),
            ),
          ],
        ),
      );
    }

    final double aspect = _controller.value.aspectRatio;
    return AspectRatio(
      aspectRatio: aspect,
      child: Stack(
        children: <Widget>[
          VideoPlayer(_controller),
          if (_showControls == true)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                child: Center(
                  child: Builder(
                    builder: (BuildContext innerContext) {
                      return IconButton(
                        iconSize: 56,
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          HomeProvider homeLocal = Provider.of<HomeProvider>(
                            innerContext,
                            listen: false,
                          );
                          if (_controller.value.isPlaying == true) {
                            _controller.pause();
                            homeLocal.setPlayingFeed(null);
                            setState(() {
                              _showControls = true;
                            });
                          } else {
                            _controller.play();
                            homeLocal.setPlayingFeed(widget.feed.id);
                            setState(() {
                              _showControls = true;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: _SimpleProgress(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class _SimpleProgress extends StatefulWidget {
  final VideoPlayerController controller;

  const _SimpleProgress({Key? key, required this.controller}) : super(key: key);

  @override
  State<_SimpleProgress> createState() {
    return __SimpleProgressState();
  }
}

class __SimpleProgressState extends State<_SimpleProgress> {
  Duration _position = Duration.zero;

  void _listener() {
    if (!mounted) {
      return;
    }
    setState(() {
      _position = widget.controller.value.position;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration total = Duration.zero;
    if (widget.controller.value.duration != null) {
      total = widget.controller.value.duration;
    }

    double sliderValue = 0.0;
    if (total.inMilliseconds > 0) {
      sliderValue = _position.inMilliseconds / total.inMilliseconds;
    } else {
      sliderValue = 0.0;
    }

    return Slider(
      value: sliderValue.clamp(0.0, 1.0),
      onChanged: (double v) {
        if (total.inMilliseconds > 0) {
          final int ms = (v * total.inMilliseconds).round();
          final Duration newPos = Duration(milliseconds: ms);
          widget.controller.seekTo(newPos);
        }
      },
    );
  }
}
