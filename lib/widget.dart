import 'dart:ui';

import 'package:carousel_3d/controller.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// [index] will be index of item in list, [zValue] will be value between 1.0 to 0.0, 1.0 when item is at front and 0.0 when item is at back.
typedef CarouselBuilder = Widget Function(int index, double zValue);

/// A 3D carousel, widgets will rotated on a 3d circle.
/// items on sides will extend to maximum of [maxHorizontalShift]
/// items will shrink to a [minScaleFactor]
class Carousel3D extends StatefulWidget {
  const Carousel3D(
      {Key? key,
      required this.itemCount,
      this.startIndex = 0,
      required this.itemBuilder,
      this.maxHorizontalShift = 50,
      this.minScaleFactor = 0.5,
      this.infiniteScroll = true,
      this.controller})
      : super(key: key);

  /// [itemCount] of Carousel
  final int itemCount;

  /// start index of carousel
  final int startIndex;

  /// [controller] for carousel
  final Carousel3DController? controller;

  /// carousel should loop infinitely or be limited to item length.
  final bool infiniteScroll;

  /// radius of 3d carousel
  final double maxHorizontalShift;

  /// The [itemBuilder] callback will be called only with indices greater than or equal to zero and less than [itemCount].
  /// [index] will be index of item in list, [zValue] will be value between 1.0 to 0.0, 1.0 when item is at front and 0.0 when item is at back.
  final CarouselBuilder itemBuilder;

  /// minimumSize of widget at back
  final double minScaleFactor;

  @override
  State<Carousel3D> createState() => Carousel3DState();
}

class Carousel3DState extends State<Carousel3D>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  double offsetAngle = 0.0;

  int get itemsCount => widget.itemCount;

  GlobalKey gestureKey = GlobalKey();

  Size? size;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
    );
    offsetAngle = -360.0 / itemsCount * widget.startIndex;
    if (widget.controller != null) {
      widget.controller?.state = this;
    }
    super.initState();
  }

  Future animateToAngle(double angle, {Curve curve = Curves.easeOut}) {
    var smoothStartAngle = offsetAngle;
    if (!widget.infiniteScroll) {
      angle = -1 * (angle * -1).clamp(0.0, 360.0 - 360.0 / itemsCount);
    }
    animationController.reset();

    animationController.duration = Duration(
        milliseconds: ((angle - smoothStartAngle) * 1.5).abs().toInt() | 100);
    var fut = animationController.forward();
    animationController.addListener(() {
      if (mounted) {
        setState(() {
          offsetAngle = lerpDouble(smoothStartAngle, angle,
                  curve.transform(animationController.value)) ??
              0;
        });
      }
    });
    return fut;
  }

  jumpToAngle(double angle) {
    if (!widget.infiniteScroll) {
      angle = -1 * (angle * -1).clamp(0.0, 360.0 - 360.0 / itemsCount);
    }
    animationController.reset();

    if (mounted) {
      setState(() {
        offsetAngle = angle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (size != null) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        setState(() {
          size = gestureKey.currentContext?.size;
        });
      });
    } else {}
    if (itemsCount == 0) {
      return const SizedBox();
    }

    var indexes = List.generate(itemsCount, (i) => i);
    indexes.sort((a, b) {
      var angleA = degToRad(a * 360 / itemsCount + offsetAngle);
      var angleB = degToRad(b * 360 / itemsCount + offsetAngle);
      return math.cos(angleA).compareTo(math.cos(angleB));
    });
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (animationController.isAnimating) {
          animationController.stop(canceled: true);
        }
        setState(() {
          offsetAngle += details.delta.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          var sectionAngle = 360 / itemsCount; // n is number of widgets
          var smoothAngle = sectionAngle *
              ((offsetAngle + (details.primaryVelocity ?? 0) / 20) /
                      sectionAngle)
                  .round();
          animateToAngle(smoothAngle);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: widget.maxHorizontalShift),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...indexes.map(
              (e) {
                var angle = degToRad(e * 360 / itemsCount + offsetAngle);
                var cosvalue = math.cos(angle); // from +1 to -1
                var factor = (cosvalue + 1) / 2; // from +1 to 0
                var scaleFactor = lerpDouble(
                    widget.minScaleFactor, 1, factor); // from 0.5 to 1
                var opacity = (e * 360 / itemsCount + offsetAngle) > 180.0
                    ? 0.0
                    : (offsetAngle * -1) > (e * 360.0 / itemsCount + 180.0)
                        ? 0.0
                        : 1.0;

                return Opacity(
                  opacity: widget.infiniteScroll ? 1 : opacity,
                  child: Transform.translate(
                    offset:
                        Offset(widget.maxHorizontalShift * math.sin(angle), 0),
                    child: Transform.scale(
                      scale: scaleFactor,
                      alignment: math.sin(angle).sign > 0
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                          key: e == 0 ? gestureKey : null,
                          child: widget.itemBuilder(e, factor)),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  num degToRad(num deg) {
    return deg * math.pi / 180;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
