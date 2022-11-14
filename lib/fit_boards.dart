import 'package:flutter/material.dart';
import 'package:how_much_wood/containing_board.dart';
import 'package:how_much_wood/board.dart';

enum FitAlgorithmName {
  bruteForce,
}

class FitBoardsFactory {
  static final List<FitBoardsBase> algorithms = [
    FitBoardsBruteForce(),
  ];

  static FitBoardsBase getFitAlg(FitAlgorithmName algorithm) {
    return algorithms.firstWhere((alg) => alg.name == algorithm);
  }
}

abstract class FitBoardsBase {
  abstract final FitAlgorithmName name;

  ContainingBoard? fit({
    required List<Board> boards,
  });
}

class FitBoardsBruteForce implements FitBoardsBase {
  @override
  final FitAlgorithmName name = FitAlgorithmName.bruteForce;

  @override
  ContainingBoard? fit({
    required List<Board> boards,
  }) {
    return null;
  }
}
