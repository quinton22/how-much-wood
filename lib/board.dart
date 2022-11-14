import 'package:flutter/material.dart';

/// the convention will be the same as [Rect]
/// the position will be measured from the top left corner
class Board {
  List<Rect> rects = [];

  Board.fromSize({
    required Size size,
    Offset position = Offset.zero,
  }) : rects = [(position & size)];

  Board.fromRect({required Rect rect}) : rects = [rect];

  Board.fromRects({required this.rects, Offset position = Offset.zero}) {
    position = position;
  }

  Board({
    required double length,
    required double width,
    double left = 0.0,
    double top = 0.0,
  }) : rects = [Rect.fromLTWH(left, top, width, length)];

  set position(Offset desiredPos) {
    final Offset shift = desiredPos - position;

    rects = rects.map((rect) => rect.shift(shift)).toList();
  }

  Offset get position => boundingRect.topLeft;

  Rect get boundingRect => rects.skip(1).fold(
        rects[0],
        (Rect bounding, Rect rect) => bounding.expandToInclude(rect),
      );

  /// The area of each rect combined
  double get totalRectsArea {
    return rects.fold(
      0.0,
      (double area, rect) => area + rect.height * rect.width,
    );
  }

  /// The area of the board
  double get area {
    final intersectionArea =
        rects.asMap().entries.fold(0.0, (double prev, entry) {
      double area = 0.0;
      for (var entry2 in rects.asMap().entries) {
        if (entry.key != entry2.key && entry.value.overlaps(entry2.value)) {
          final intersectingRect = entry.value.intersect(entry2.value);
          area += intersectingRect.height * intersectingRect.width;
        }
      }

      return prev + area;
    });

    return totalRectsArea - intersectionArea;
  }

  bool isConnected() {
    throw UnimplementedError();

    // List<List<bool>> overlaps = [];

    // for (var entry1 in rects.asMap().entries) {
    //   overlaps.add(rects
    //       .asMap()
    //       .entries
    //       .map((entry2) =>
    //           entry1.key != entry1.key && entry1.value.overlaps(entry2.value))
    //       .toList(growable: false));
    // }

    // // for now just allow 1 rect
    // // build connection into the board builder
    // return rects.length == 1;
  }
}
