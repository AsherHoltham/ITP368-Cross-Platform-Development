/*
lab
Hydrate Chess

You are given a chess board. It is not a finished interface,
but you can see where all of the pieces are, and you can move
them (click on a piece to move, then click where you want to move
it).

The goal of this lab is to hydrate the game state so that if you stop
the program and restart it, the game resumes where you left off.
*/

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

// -----------------------------------------------------------------------------
// ChessState: Now supports JSON serialization for hydration.
class ChessState {
  final List<List<String>> board;
  final int turnCount;

  ChessState({required this.board, required this.turnCount});

  // Initial chess board state.
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

  // Converts the object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'board': board,
      'turnCount': turnCount,
    };
  }

  // Creates an object from a Map.
  factory ChessState.fromMap(Map<String, dynamic> map) {
    // 'board' is stored as a List<dynamic> where each row is a List.
    final rawBoard = map['board'] as List<dynamic>;
    List<List<String>> board = rawBoard
        .map<List<String>>((row) => List<String>.from(row as List))
        .toList();

    return ChessState(
      board: board,
      turnCount: map['turnCount'] as int,
    );
  }

  // Converts the object into JSON.
  String toJson() => json.encode(toMap());

  // Creates an object from JSON.
  factory ChessState.fromJson(String source) =>
      ChessState.fromMap(json.decode(source));
}

// -----------------------------------------------------------------------------
// ChessCubit: Now a HydratedCubit so state is persisted.
class ChessCubit extends HydratedCubit<ChessState> {
  ChessCubit() : super(ChessState.initial());

  // Updates the board by moving a piece from 'fromHere' to 'toHere'.
  void update(Coords fromHere, Coords toHere) {
    // Create a deep copy of the board.
    List<List<String>> newBoard =
        state.board.map((row) => List<String>.from(row)).toList();

    newBoard[toHere.c][toHere.r] = newBoard[fromHere.c][fromHere.r];
    newBoard[fromHere.c][fromHere.r] = " ";

    emit(ChessState(board: newBoard, turnCount: state.turnCount + 1));
  }

  // Hydration: Converts JSON map into a ChessState.
  @override
  ChessState? fromJson(Map<String, dynamic> json) {
    try {
      return ChessState.fromMap(json);
    } catch (e) {
      return ChessState.initial();
    }
  }

  // Hydration: Converts a ChessState into a JSON map.
  @override
  Map<String, dynamic>? toJson(ChessState state) {
    return state.toMap();
  }
}

// -----------------------------------------------------------------------------
// UI Code (unchanged except for using the hydrated ChessCubit)

void main() async {
WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build
  (  storageDirectory: HydratedStorageDirectory
    ( (await getApplicationDocumentsDirectory()).path,),
  );
  runApp(Chess());
}

class Chess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chess",
      home: BlocProvider<ChessCubit>(
        create: (context) => ChessCubit(),
        child: BlocProvider<MoveCubit>(
          create: (context) => MoveCubit(),
          child: Chess1(),
        ),
      ),
    );
  }
}

class Chess1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chess")),
      body: drawBoard(context),
    );
  }

  // Draws the chess board.
  Widget drawBoard(BuildContext context) {
    ChessCubit cc = BlocProvider.of<ChessCubit>(context);
    ChessState cs = cc.state;

    Column theGrid = Column(children: []);

    // Depending on whose turn it is, flip the board.
    if (cs.turnCount % 2 == 0) {
      // White's turn, draw rank 1 at bottom.
      for (int row = 7; row >= 0; row--) {
        Row r = Row(children: []);
        for (int col = 0; col < 8; col++) {
          r.children.add(Square(Coords(col, row), cs.board[col][row]));
        }
        theGrid.children.add(r);
      }
    } else {
      for (int row = 0; row < 8; row++) {
        Row r = Row(children: []);
        for (int col = 7; col >= 0; col--) {
          r.children.add(Square(Coords(col, row), cs.board[col][row]));
        }
        theGrid.children.add(r);
      }
    }

    return theGrid;
  }
}

class Square extends StatelessWidget {
  final Coords here;
  final String letter;
  final bool light; // true means light-colored square

  Square(this.here, this.letter) : light = ((here.r + here.c) % 2 == 1) {
    print("Square constructor .. coords = ${here.c},${here.r}");
  }

  @override
  Widget build(BuildContext context) {
    MoveCubit mc = BlocProvider.of<MoveCubit>(context);
    ChessCubit cc = BlocProvider.of<ChessCubit>(context);

    return Listener(
      onPointerDown: (_) {
        print("mouse down at ${here.c},${here.r}");
        mc.mouseDown(here, cc);
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: light ? Colors.white : Colors.grey,
          border: Border.all(),
        ),
        child: Center(
          child: Text(letter, style: TextStyle(fontSize: 30)),
        ),
      ),
    );
  }
}

class Coords {
  final int c;
  final int r;

  Coords(this.c, this.r);

  bool equals(Coords there) {
    return there.c == c && there.r == r;
  }
}

class MoveState {
  final Coords? mouseAt;
  final bool dragging;

  MoveState(this.mouseAt, this.dragging);
}

class MoveCubit extends Cubit<MoveState> {
  MoveCubit() : super(MoveState(null, false));

  void mouseDown(Coords here, ChessCubit cc) {
    if (state.dragging) {
      // This is a move (second click).
      if (!here.equals(state.mouseAt!)) {
        if (state.mouseAt != null) {
          Coords temp = Coords(state.mouseAt!.c, state.mouseAt!.r);
          emit(MoveState(null, false));
          cc.update(temp, here);
        } else {
          print("mouseAt is null -- how?");
        }
      }
    } else {
      // First click of a move.
      emit(MoveState(here, true));
    }
  }
}