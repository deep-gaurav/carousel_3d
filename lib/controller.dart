import 'dart:async';

import 'package:carousel_3d/widget.dart';
import 'package:flutter/material.dart';

class Carousel3DController {
  final Completer<Null> _readyCompleter = Completer<Null>();

  Carousel3DState? _state;

  bool get ready => _state != null;

  Future<Null> get onReady => _readyCompleter.future;

  int get currentPageIndex =>
      (-_state!.offsetAngle / (360 / _state!.itemsCount)).round() %
      _state!.itemsCount;

  /// Animates the controlled [Carousel3D] to the previous page.
  ///
  /// The animation follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future previousPage({Curve curve = Curves.easeOut}) {
    var sectionAngle = 360 / _state!.itemsCount;

    var nextPageAngle =
        sectionAngle * ((_state!.offsetAngle / sectionAngle).round() + 1);
    return _state!.animateToAngle(nextPageAngle);
  }

  /// Animates the controlled [Carousel3D] to the next page.
  ///
  /// The animation follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future nextPage({Curve curve = Curves.easeOut}) {
    var sectionAngle = 360 / _state!.itemsCount;

    var nextPageAngle =
        sectionAngle * ((_state!.offsetAngle / sectionAngle).round() - 1);
    return _state!.animateToAngle(nextPageAngle);
  }

  /// Jumps the controlled [Carousel3D] to the specified item with index [index].
  void jumpToPage(int index) {
    if (_state!.animationController.isAnimating) {
      _state!.animationController.stop();
    }

    var sectionAngle = 360 / _state!.itemsCount;
    var currentPage = currentPageIndex;
    var forwardDistance = (index - currentPage) % _state!.itemsCount;
    var backwardDistance = (currentPage - index) % _state!.itemsCount;
    var distance = 0;
    if (forwardDistance < backwardDistance) {
      distance = -forwardDistance;
    } else {
      distance = backwardDistance;
    }

    var nextPageAngle = sectionAngle *
        ((_state!.offsetAngle / sectionAngle).round() + distance);
    _state!.jumpToAngle(nextPageAngle);
  }

  /// Animates the controlled [Carousel3D] to the item with index [index].
  ///
  /// The animation follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future animateToPage(int index, {Curve curve = Curves.easeOut}) {
    var sectionAngle = 360 / _state!.itemsCount;
    var currentPage = currentPageIndex;
    var forwardDistance = (index - currentPage) % _state!.itemsCount;
    var backwardDistance = (currentPage - index) % _state!.itemsCount;
    var distance = 0;
    if (forwardDistance < backwardDistance) {
      distance = -forwardDistance;
    } else {
      distance = backwardDistance;
    }

    var nextPageAngle = sectionAngle *
        ((_state!.offsetAngle / sectionAngle).round() + distance);
    var fut = _state!.animateToAngle(nextPageAngle);
    return fut;
  }

  set state(Carousel3DState? state) {
    _state = state;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }
}
