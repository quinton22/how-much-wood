import 'package:flutter/material.dart';
import 'package:how_much_wood/board.dart';

class ContainingBoard extends Board {
  List<Board> containedBoards = [];

  ContainingBoard({
    required double length,
    required double width,
  }) : super(length: length, width: width);

  ContainingBoard.fromSize({required Size size}) : super.fromSize(size: size);

  /// Places a [board] on the containing board
  /// Returns [true] if placement succeeds
  /// Will change the board position if position is provided
  /// and will revert if placement doesn't succeed
  bool place({required Board board, Offset? position}) {
    final oldPosition = board.position;

    if (position != null) {
      board.position = position;
    }

    // check if boundingRect of board overlaps with any containedBoards
    final Rect br = board.boundingRect;

    final bool noOverlap = containedBoards
        .every((containedBoard) => !containedBoard.boundingRect.overlaps(br));
    final bool contained = isContained(board: board);

    if (noOverlap && contained) {
      containedBoards.add(board);
      return true;
    }

    if (position != null) {
      board.position = oldPosition;
    }

    return false;
  }

  bool isContained({required Board board}) {
    final containingSize = boundingRect.intersect(board.boundingRect).size;
    final boardSize = board.boundingRect.size;

    if (containingSize.height * containingSize.width !=
        boardSize.height * boardSize.width) {
      return false;
    }

    double area = 0.0;
    for (var rect in rects) {
      double area2 = 0.0;
      for (var rect2 in board.rects) {
        final size =
            rect.overlaps(rect2) ? rect.intersect(rect2).size : Size.zero;
        area2 += size.height * size.width;
      }
      area += area2;
    }

    return area == board.totalRectsArea;
  }
}
