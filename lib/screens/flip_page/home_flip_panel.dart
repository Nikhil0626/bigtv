import 'dart:developer';

import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'dart:math' as math;

import 'package:provider/provider.dart';

typedef FlipBack = void Function({bool backToTop});

typedef ItemBuilder<T> = Widget Function(BuildContext, T, FlipBack?, double);

typedef GetItems = void Function({bool refresh});

enum FlipDirection { up, down, none, left, right }

enum LastFlip { none, previous, next }

const double _kFastThreshold = 50.0;

class FlipPanel<T> extends StatefulWidget {
  final ItemBuilder<T> itemBuilder;
  final Duration duration;
  final double height;
  bool waitingForRefresh;
  final Stream<List<T>?> itemStream;

  // final GetItems getItemsCallback;

  FlipPanel({
    Key? key,
    required this.itemBuilder,
    required this.itemStream,
    this.waitingForRefresh = false,
    required this.height,
    this.duration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  _FlipPanelState<T> createState() => _FlipPanelState<T>();
}

class _FlipPanelState<T> extends State<FlipPanel>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation _animation;
  int _currentIndex = 0;
  bool _isReversePhase = false;
  bool _running = false;
  bool isLeft = false;
  bool isLast = false;
  final _perspective = 0.0003;
  final _zeroAngle = 0.0001;
  late double _height;

  FlipDirection _direction = FlipDirection.none;

  List<Widget>? widgets;

  late StreamSubscription<List<dynamic>?> _subscription;

  int _availableItems = 0;

  final _updateThreshold = 5;

  Widget? _prevChild, _currentChild, _nextChild;
  Widget? _upperChild1, _upperChild2;
  Widget? _lowerChild1, _lowerChild2;

  double _dragExtent = 0.0;
  bool _dragging = false;
  bool isImages = false;

  double _flipExtent = 200.0;

  LastFlip _lastFlip = LastFlip.none;

  bool _shouldShowNoMoreItemsMessage = false;

  @override
  didUpdateWidget(FlipPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _height = widget.height;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _isReversePhase = false;
    _running = false;
    _direction = FlipDirection.none;
    _height = widget.height;

    WidgetsBinding.instance.addPostFrameCallback((_) {});

    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_dragging) {
          _isReversePhase = true;
          _controller.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          //_currentValue = _nextValue;
          _running = false;
          _currentIndex =
              _lastFlip == LastFlip.next && _currentIndex < widgets!.length - 1
                  ? _currentIndex + 1
                  : _lastFlip == LastFlip.previous && _currentIndex > 0
                      ? _currentIndex - 1
                      : _currentIndex;
          if (_lastFlip == LastFlip.next &&
              _currentIndex == _availableItems - _updateThreshold) {
            context.read<FlipProvider>().getArticles(index: _currentIndex);
          }
        }
      })
      ..addListener(() {
        setState(() {
          _running = true;
        });
      });
    _animation =
        Tween(begin: _zeroAngle, end: math.pi / 2).animate(_controller);

    _subscription = widget.itemStream.distinct().listen((items) {
      if (items == null || items.isEmpty) {
        widgets = null;
        _availableItems = 0;
        _currentIndex = 0;
        widget.waitingForRefresh = true;
        setState(() {});
        return;
      }
      widget.waitingForRefresh = false;
      if (_availableItems == 0) {
        widgets = [];
        widgets!.add(_buildFirstWidget(items[0]));
        widgets!.addAll(items
            .skip(1)
            .map((item) => widget.itemBuilder(context, item, flipBack, _height))
            .toList());
        print("widgets");
        print(widgets);
        _upperChild1 = makeUpperClip(widgets![0]);
        _lowerChild1 = makeLowerClip(widgets![0]);
      } else {
        print(items.last);
        widgets!.addAll(items
            .map((item) => widget.itemBuilder(context, item, flipBack, _height))
            .toList());
      }

      _availableItems += items.length;
      print("currenttttt itemm  ${_availableItems.toString()}");
      setState(() {});
    });

    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  Widget _buildFirstWidget(T item) {
    return widget.itemBuilder(context, item, null, _height);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.waitingForRefresh) {
      if (widgets == null || _availableItems == 0) {
        return Container(
          color: Colors.white,
          height: _height,
          width: MediaQuery.of(context).size.width,
          child: const Center(
            child: AppLoadingScreen(),
          ),
        );
      }
      _buildChildWidgetsIfNeed(context);
    }

    return _buildPanel();
  }

  Widget makeUpperClip(Widget widget) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.5,
        child: widget,
      ),
    );
  }

  Widget makeLowerClip(Widget widget) {
    return ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 0.5,
        child: widget,
      ),
    );
  }

  void flipBack({bool backToTop = false}) {
    if (_currentIndex == 0) return;
    _running = true;
    _currentChild = null;
    _isReversePhase = false;
    _direction = FlipDirection.down;
    _lastFlip = LastFlip.previous;
    if (backToTop) {
      _currentChild = widgets![_currentIndex];
      _prevChild = widgets![0];
      _currentIndex = 0;
      _upperChild1 = makeUpperClip(_currentChild!);
      _lowerChild1 = makeLowerClip(_currentChild!);
      _upperChild2 = makeUpperClip(_prevChild!);
      _lowerChild2 = makeLowerClip(_prevChild!);
    }
    _controller.animateTo(1.0);
  }

  void _buildChildWidgetsIfNeed(BuildContext context) {
    if (_running) {
      if (_direction == FlipDirection.up) {
        if (_currentChild == null && _currentIndex < widgets!.length - 1) {
          _currentChild = widgets![_currentIndex];
          _nextChild = widgets![_currentIndex + 1];
          _upperChild1 = makeUpperClip(_currentChild!);
          _lowerChild1 = makeLowerClip(_currentChild!);
          _upperChild2 = makeUpperClip(_nextChild!);
          _lowerChild2 = makeLowerClip(_nextChild!);
        }
      }
      if (_direction == FlipDirection.down) {
        if (_currentChild == null && _currentIndex > 0) {
          _currentChild = widgets![_currentIndex];
          _prevChild = widgets![_currentIndex - 1];
          _upperChild1 = makeUpperClip(_currentChild!);
          _lowerChild1 = makeLowerClip(_currentChild!);
          _upperChild2 = makeUpperClip(_prevChild!);
          _lowerChild2 = makeLowerClip(_prevChild!);
        }
      }
    } else {
      _currentChild = widgets![_currentIndex];
      _upperChild1 = makeUpperClip(_currentChild!);
      _lowerChild1 = makeLowerClip(_currentChild!);
    }
  }

  void _handleDragStart(
    DragStartDetails details,
  ) {
    log("Vertical Drag Start");
    _dragging = true;
    _running = true;
    _direction = FlipDirection.none;
    _dragExtent = _controller.value * _dragExtent.sign;

    double _halfFlipPanel = context.size!.width / 2;
    RenderBox referenceBox = context.findRenderObject() as RenderBox;
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    _flipExtent = (localPosition.dy - _halfFlipPanel)
        .abs()
        .clamp(_halfFlipPanel / 2, double.infinity);
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  void handleDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta!;
    _dragExtent += delta;
    setState(() {
      if (_direction == FlipDirection.none) {
        _direction = _dragExtent < 0 ? FlipDirection.up : FlipDirection.down;
        _currentChild = null;
      }
      // Need to add 0.01 to correct an artifact appearing when clamping to limit
      _dragExtent = _direction == FlipDirection.up
          ? _dragExtent.clamp(-(_flipExtent * 2 + 0.01), 0.0)
          : _dragExtent.clamp(0.0, _flipExtent * 2 - 0.01);
      if (_direction == FlipDirection.down && _currentIndex == 0) {
        _dragExtent = 0.0;
        isLast = true;
      }
      if (_direction == FlipDirection.up &&
          _currentIndex == widgets!.length - 1) {
        _dragExtent = 0.0;
        isLast = true;
        // _shouldShowNoMoreItemsMessage = true;
      }
      if (_dragExtent.abs() < _flipExtent) {
        _controller.value = (_dragExtent / _flipExtent).abs();
      } else {
        _controller.value =
            (((_flipExtent * 2) - _dragExtent.abs()) / _flipExtent).abs();
      }
      _isReversePhase = (_dragExtent / _flipExtent).abs() > 1.0 ? true : false;
    });
  }

  void handleDragEnd(DragEndDetails details, flipProvider) {
    _dragging = false;

    print(
        "last post ${context.read<FlipProvider>().lastPostIdInMain}  ooooooo Next post ${context.read<FlipProvider>().mainArticlesData[_currentIndex + 2].id}");
    // if (context.read<FlipProvider>().lastPostIdInMain ==
    //     context.read<FlipProvider>().mainArticlesData[_currentIndex + 2].id) {
    //   context.read<FlipProvider>().getArticles(index: _currentIndex);
    //   return;
    // }

    if (context.read<FlipProvider>().mainArticlesData[_currentIndex + 1].type ==
        "Gallery") {
      log("isImages changed");
      setState(() {
        isImages = true;
      });
    }

    flipProvider.setIndex(_currentIndex);
    if (_dragExtent == 0.0) {
      if (_shouldShowNoMoreItemsMessage) {
        // widget.waitingForRefresh = true;
        isLast = true;
        setState(() {});
      }
      return;
    }

    final double velocity = details.primaryVelocity!;
    final bool fast = velocity.abs() > _kFastThreshold;

    if (fast) {
      if (_dragExtent.abs() > _flipExtent) {
        _controller.animateTo(0.0);
      } else {
        _controller.animateTo(1.0);
      }
      _lastFlip =
          _direction == FlipDirection.up ? LastFlip.next : LastFlip.previous;
    } else {
      if (_dragExtent.abs() > _flipExtent) {
        _lastFlip =
            _direction == FlipDirection.up ? LastFlip.next : LastFlip.previous;
      } else {
        _lastFlip = LastFlip.none;
      }
      _controller.animateTo(0.0);
    }
  }

  Widget _buildUpperFlipPanel() => _direction == FlipDirection.up
      ? Stack(
          children: [
            Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, _perspective)
                  ..rotateX(_zeroAngle),
                child: _upperChild1),
            _isReversePhase
                ? Opacity(
                    opacity: 1 - _controller.value,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                    ))
                : Container(),
            Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_isReversePhase ? _animation.value : math.pi / 2),
              child: _upperChild2,
            ),
          ],
        )
      : Stack(
          children: [
            Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, _perspective)
                  ..rotateX(_zeroAngle),
                child: _upperChild2),
            !_isReversePhase
                ? Opacity(
                    opacity: 1 - _controller.value,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                    ))
                : Container(),
            Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_isReversePhase ? math.pi / 2 : _animation.value),
              child: _upperChild1,
            ),
          ],
        );

  Widget _buildLowerFlipPanel() => _direction == FlipDirection.up
      ? Stack(
          children: [
            Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, _perspective)
                  ..rotateX(_zeroAngle),
                child: _lowerChild2),
            !_isReversePhase
                ? Opacity(
                    opacity: 1 - _controller.value,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                    ))
                : Container(),
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_isReversePhase ? math.pi / 2 : -_animation.value),
              child: _lowerChild1,
            )
          ],
        )
      : Stack(
          children: [
            Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, _perspective)
                  ..rotateX(_zeroAngle),
                child: _lowerChild1),
            _isReversePhase
                ? Opacity(
                    opacity: 1 - _controller.value,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                    ))
                : Container(),
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_isReversePhase ? -_animation.value : math.pi / 2),
              child: _lowerChild2,
            ),
          ],
        );

  Widget _buildPanel() {
    Widget content = _running
        ? Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUpperFlipPanel(),
              _buildLowerFlipPanel(),
            ],
          )
        : isImages
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _upperChild1,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: <Widget>[
                      _upperChild1!,
                      widget.waitingForRefresh
                          ? const Padding(
                              padding: EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: AppLoadingScreen(),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  _lowerChild1!,
                ],
              );

    return Consumer<FlipProvider>(builder: (context, flipProvider, __) {
      return GestureDetector(
        onVerticalDragStart: _handleDragStart,
        onVerticalDragUpdate: handleDragUpdate,
        onVerticalDragEnd: (details) => handleDragEnd(details, flipProvider),
        onHorizontalDragStart: handelLeftDragStart,
        onHorizontalDragUpdate: handelLeftDragUpdate,
        onHorizontalDragEnd: handelLeftDragEnd,
        child: content,
      );
    });
  }

  void handelLeftDragStart(
    DragStartDetails details,
  ) {
    log("Horizontal dra start");
    setState(() {});
  }

  void handelLeftDragEnd(
    DragEndDetails details,
  ) {
    log("Horizontal dra end");
    setState(() {});
  }

  void handelLeftDragUpdate(DragUpdateDetails details) {
    log("Horizontal dra update");
    setState(() {});
  }

  void _showNoMoreItemsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No more articles for selected sources"),
      ),
    );
  }
}
