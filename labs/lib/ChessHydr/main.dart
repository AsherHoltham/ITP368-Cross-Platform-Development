import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build
  (  storageDirectory: HydratedStorageDirectory
    ( (await getApplicationDocumentsDirectory()).path,),
  );
  runApp(ChessApp());
}

class ChessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChessCubit>(create: (_) => ChessCubit()),
        BlocProvider<MoveCubit>(create: (_) => MoveCubit()),
      ],
      child: MaterialApp(
        title: "Chess",
        home: ChessBoardScreen(),
      ),
    );
  }
}

/// The game state contains the board (stored as a List<List<String>>)
/// and a turn counter.
class ChessState {
  final List<List<String>> board;
  final int turnCount;

  ChessState({required this.board, required this.turnCount});

  /// The initial state (starting position).
  factory ChessState.initial() {
    return ChessState(
      board: [
        ['r.', 'p', ' ', ' ', ' ', ' ', 'P', 'R.'],
        ['n', 'p', ' ', ' ', ' ', ' ', 'P', 'N'],
        ['b', 'p', ' ', ' ', ' ', ' ', 'P', 'B'],
        ['q', 'p', ' ', ' ', ' ', ' ', 'P', 'Q'],
        ['k', 'p', ' ', ' ', ' ', ' ', 'P', 'K'],
        ['b', 'p', ' ', ' ', ' ', ' ', 'P', 'B'],
        ['n', 'p', ' ', ' ', ' ', ' ', 'P', 'N'],
        ['r.', 'p', ' ', ' ', ' ', ' ', 'P', 'R.'],
      ],
      turnCount: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'board': board,
      'turnCount': turnCount,
    };
  }

  factory ChessState.fromMap(Map<String, dynamic> map) {
    List<dynamic> boardDynamic = map['board'];
    List<List<String>> board = boardDynamic.map((row) {
      List<dynamic> rowDynamic = row;
      return rowDynamic.map((item) => item.toString()).toList();
    }).toList();
    return ChessState(
      board: board,
      turnCount: map['turnCount'] as int,
    );
  }
}

/// This cubit now both manages game moves and persists the board state.
/// It extends HydratedCubit so that the state is saved/restored automatically.
class ChessCubit extends HydratedCubit<ChessState> {
  ChessCubit() : super(ChessState.initial());

  /// Called when a move is made from coordinate [from] to [to].
  void update(Coords from, Coords to) {
    // Create a deep copy of the board to avoid mutating state directly.
    List<List<String>> newBoard =
        state.board.map((row) => List<String>.from(row)).toList();
    newBoard[to.c][to.r] = newBoard[from.c][from.r];
    newBoard[from.c][from.r] = " ";
    emit(ChessState(board: newBoard, turnCount: state.turnCount + 1));
  }

  @override
  ChessState? fromJson(Map<String, dynamic> json) {
    try {
      return ChessState.fromMap(json);
    } catch (_) {
      return ChessState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(ChessState state) {
    return state.toMap();
  }
}

/// A simple screen that shows the chess board.
class ChessBoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chess"),
      ),
      body: Center(child: ChessBoardWidget()),
    );
  }
}

/// This widget builds the board by reading the persisted game state.
class ChessBoardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChessCubit, ChessState>(
      builder: (context, chessState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildBoard(context, chessState),
        );
      },
    );
  }

  /// Builds the board layout. The orientation depends on whose turn it is.
  List<Widget> buildBoard(BuildContext context, ChessState chessState) {
    List<Widget> rows = [];
    if (chessState.turnCount % 2 == 0) {
      // White's turn: draw rank 1 at the bottom.
      for (int row = 7; row >= 0; row--) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(8, (col) {
            return Square(Coords(col, row), chessState.board[col][row]);
          }),
        ));
      }
    } else {
      // Otherwise, draw in reverse.
      for (int row = 0; row < 8; row++) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(8, (index) {
            int col = 7 - index;
            return Square(Coords(col, row), chessState.board[col][row]);
          }),
        ));
      }
    }
    return rows;
  }
}

/// Represents an individual square on the chess board.
class Square extends StatelessWidget {
  final Coords pos;
  final String piece;
  const Square(this.pos, this.piece);

  bool get isLight => (pos.c + pos.r) % 2 == 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // When a square is tapped, delegate to MoveCubit for move logic.
        BlocProvider.of<MoveCubit>(context)
            .selectSquare(pos, BlocProvider.of<ChessCubit>(context));
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : Colors.grey,
          border: Border.all(color: Colors.black),
        ),
        alignment: Alignment.center,
        child: Text(piece, style: TextStyle(fontSize: 30)),
      ),
    );
  }
}

/// A simple coordinate class to hold board positions.
class Coords {
  final int c;
  final int r;
  Coords(this.c, this.r);

  bool equals(Coords other) => c == other.c && r == other.r;
}

/// State used for move selection.
class MoveState {
  final Coords? selected;
  final bool dragging;
  MoveState({this.selected, required this.dragging});
}

/// A cubit to manage the move selection process.
/// The first tap selects a piece and the second tap attempts a move.
class MoveCubit extends Cubit<MoveState> {
  MoveCubit() : super(MoveState(selected: null, dragging: false));

  void selectSquare(Coords square, ChessCubit chessCubit) {
    if (state.dragging) {
      if (state.selected != null && !state.selected!.equals(square)) {
        chessCubit.update(state.selected!, square);
        emit(MoveState(selected: null, dragging: false));
      }
    } else {
      emit(MoveState(selected: square, dragging: true));
    }
  }
}
