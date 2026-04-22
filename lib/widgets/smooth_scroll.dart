import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _kMinWheelAnimation = Duration(milliseconds: 120);
const _kMaxWheelAnimation = Duration(milliseconds: 220);
const _kWheelCurve = Curves.easeOutCubic;

Duration _wheelAnimationDuration(double distance) {
  final clampedDistance = distance.abs().clamp(0.0, 360.0);
  final t = clampedDistance / 360.0;
  final min = _kMinWheelAnimation.inMilliseconds.toDouble();
  final max = _kMaxWheelAnimation.inMilliseconds.toDouble();
  final millis = min + ((max - min) * t);
  return Duration(milliseconds: millis.round());
}

class SmoothScrollController extends ScrollController {
  SmoothScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SmoothScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _SmoothScrollPosition extends ScrollPositionWithSingleContext {
  _SmoothScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  double? _pointerScrollTarget;
  int _pointerScrollGeneration = 0;

  @override
  void pointerScroll(double delta) {
    if (delta == 0.0) {
      _pointerScrollTarget = null;
      goBallistic(0.0);
      return;
    }

    final nextTarget = math.min(
      math.max((_pointerScrollTarget ?? pixels) + delta, minScrollExtent),
      maxScrollExtent,
    );

    if (nextTarget == pixels) {
      return;
    }

    _pointerScrollTarget = nextTarget;
    final generation = ++_pointerScrollGeneration;
    updateUserScrollDirection(
      -delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse,
    );

    unawaited(
      animateTo(
        nextTarget,
        duration: _wheelAnimationDuration(nextTarget - pixels),
        curve: _kWheelCurve,
      ).whenComplete(() {
        if (generation == _pointerScrollGeneration) {
          _pointerScrollTarget = null;
        }
      }),
    );
  }
}

class SmoothListView extends StatefulWidget {
  const SmoothListView({
    super.key,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.physics,
    this.primary,
    this.shrinkWrap = false,
    required this.children,
  }) : itemBuilder = null,
       itemCount = null;

  const SmoothListView.builder({
    super.key,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.physics,
    this.primary,
    this.shrinkWrap = false,
    required IndexedWidgetBuilder this.itemBuilder,
    required this.itemCount,
  }) : children = const [];

  final ScrollController? controller;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? primary;
  final bool shrinkWrap;
  final List<Widget> children;
  final IndexedWidgetBuilder? itemBuilder;
  final int? itemCount;

  @override
  State<SmoothListView> createState() => _SmoothListViewState();
}

class _SmoothListViewState extends State<SmoothListView> {
  late final SmoothScrollController _controller;

  ScrollController? get _effectiveController =>
      widget.controller ?? _controller;

  @override
  void initState() {
    super.initState();
    _controller = SmoothScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemBuilder != null) {
      return ListView.builder(
        controller: _effectiveController,
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        physics: widget.physics,
        primary: widget.primary,
        shrinkWrap: widget.shrinkWrap,
        itemBuilder: widget.itemBuilder!,
        itemCount: widget.itemCount,
      );
    }

    return ListView(
      controller: _effectiveController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      physics: widget.physics,
      primary: widget.primary,
      shrinkWrap: widget.shrinkWrap,
      children: widget.children,
    );
  }
}

class SmoothSingleChildScrollView extends StatefulWidget {
  const SmoothSingleChildScrollView({
    super.key,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.physics,
    this.primary,
    required this.child,
  });

  final ScrollController? controller;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? primary;
  final Widget child;

  @override
  State<SmoothSingleChildScrollView> createState() =>
      _SmoothSingleChildScrollViewState();
}

class _SmoothSingleChildScrollViewState
    extends State<SmoothSingleChildScrollView> {
  late final SmoothScrollController _controller;

  ScrollController? get _effectiveController =>
      widget.controller ?? _controller;

  @override
  void initState() {
    super.initState();
    _controller = SmoothScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _effectiveController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      physics: widget.physics,
      primary: widget.primary,
      child: widget.child,
    );
  }
}
