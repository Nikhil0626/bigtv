

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../home_screen/home_provider/provider.dart';

typedef FlipBack = void Function({bool backToTop});

typedef ItemBuilder<T> = Widget Function(BuildContext, T, FlipBack?, double);

typedef GetItems = void Function({bool refresh});

enum FlipDirection { up, down, none }

enum LastFlip { none, previous, next }

const double _kFastThreshold = 800.0;

class FlipPanel<T> extends StatefulWidget {
  final ItemBuilder<T> itemBuilder;
  final Duration duration;
  final double height;
  final Stream<List<T>?> itemStream;

  const FlipPanel({
    Key? key,
    required this.itemBuilder,
    required this.itemStream,
    required this.height,
    this.duration = const Duration(milliseconds: 200),
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
  final _perspective = 0.0003;
  final _zeroAngle = 0.0001; // There's something wrong in the perspective transform, I use a very small value instead of zero to temporarily get it around.

  late double _height;
  bool isImages = false;
  FlipDirection _direction = FlipDirection.none;

  List<Widget>? widgets;

  late StreamSubscription<List<dynamic>?> _subscription;
  int _availableItems = 0;
  final _updateThreshold = 7;

  bool _waitingForRefresh = false;

  Widget? _prevChild, _currentChild, _nextChild;
  Widget? _upperChild1, _upperChild2;
  Widget? _lowerChild1, _lowerChild2;

  double _dragExtent = 0.0;
  bool _dragging = false;
  double _flipExtent = 200.0;

  LastFlip _lastFlip = LastFlip.none;

  bool _shouldShowNoMoreItemsMessage = false;

  @override
  didUpdateWidget(FlipPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _height = widget.height ;
  }
  int  newHeight=0;
  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _isReversePhase = false;
    _running = false;
    _direction = FlipDirection.none;

    newHeight = (((MediaQuery.of(mainNavigatorKey.currentContext!).padding.top + MediaQuery.of(mainNavigatorKey.currentContext!).padding.bottom).round().toInt())/2).round().toInt();
    newHeight = newHeight.round();
    print("New height   $newHeight");
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
        _waitingForRefresh = true;
        setState(() {});
        return;
      }
      _waitingForRefresh = false;
      if (_availableItems == 0) {
        widgets = [];
        widgets!.add(_buildFirstWidget(items?[0]));
        widgets!.addAll(items!.skip(1)
            .map((item) => widget.itemBuilder(context, item, flipBack, _height))
            .toList());
        print("widgets");
        print(widgets);
        _upperChild1 = makeUpperClip(widgets![0]);
        _lowerChild1 = makeLowerClip(widgets![0]);
      } else {
        widgets!.addAll(items!
            .map((item) => widget.itemBuilder(context, item, flipBack, _height))
            .toList());
      }
      _availableItems += items.length;
      setState(() {});

    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Widget _buildFirstWidget(T item) {
    return widget.itemBuilder(context, item, null, _height);
  }

  @override
  Widget build(BuildContext context) {

    if (!_waitingForRefresh) {
      if (widgets == null || _availableItems == 0) {
        return Container(
          color: Colors.transparent,
          height: 10,
          width: MediaQuery.of(context).size.width,

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

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;
    _running = true;
    _direction = FlipDirection.none;
    _dragExtent = _controller.value * _dragExtent.sign;

    double _halfFlipPanel = context.size!.height / 2;
    RenderBox referenceBox = context.findRenderObject() as RenderBox;
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    _flipExtent = (localPosition.dy - _halfFlipPanel)
        .abs()
        .clamp(_halfFlipPanel / 2, double.infinity);
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
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
      }
      if (_direction == FlipDirection.up &&
          _currentIndex == widgets!.length - 1) {
        _dragExtent = 0.0;
        _shouldShowNoMoreItemsMessage = true;
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

  void _handleDragEnd(DragEndDetails details) {
    log("indexxxxxxx ---- $_currentIndex");
    log("indexxxxxxx ---- $_updateThreshold");

    context.read<FlipProvider>().loadUserId(_currentIndex);
    _dragging = false;
    if (context.read<FlipProvider>().mainArticlesData[_currentIndex + 1].type ==
        "Gallery") {
      log("isImages changed");
      setState(() {
        isImages = true;
      });
    }

    if(_currentIndex > 0 && _direction == FlipDirection.up) {
      context.read<FlipProvider>().isShowTopBottomChange(true,);
    }else{
      context.read<FlipProvider>().isShowTopBottomChange(false,);
    }

    if(_direction == FlipDirection.up){
      context.read<FlipProvider>().flipEvent(true,isHome: true,_currentIndex + 1);
    }else{
      context.read<FlipProvider>().flipEvent(false,isHome: true,_currentIndex - 1);
    }

    if (_dragExtent == 0.0) {
      if (_shouldShowNoMoreItemsMessage) {
        // _showNoMoreItemsMessage();
        _shouldShowNoMoreItemsMessage = false;
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
            height:(_height / 2)-newHeight,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
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
            height:(_height / 2)-newHeight,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
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
            height:(_height / 2)-newHeight,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
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
            height:(_height / 2)-newHeight,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
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
    ):isImages
        ? SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: _upperChild1,
    )
        : Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _upperChild1!,
        _lowerChild1!,
      ],
    );

    return GestureDetector(
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: content,
    );
  }

  void _showNoMoreItemsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No more articles for selected sources"),
      ),
    );
  }
}
