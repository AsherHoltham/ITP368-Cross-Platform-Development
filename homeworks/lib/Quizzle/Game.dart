import "package:flutter/material.dart";
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GameEvent {}

class StartGame extends GameEvent {}

class AskQuestion extends GameEvent {}

class SubmitAnswer extends GameEvent {
  final String input;
  SubmitAnswer({required this.input});
}

class EndGame extends GameEvent {}

class GameState {
  final int mCorrect;
  final int mQuestionCounter;
  final String mOutput;

  GameState(
      {required this.mCorrect,
      required this.mQuestionCounter,
      required this.mOutput});

  factory GameState.initial() {
    return GameState(mCorrect: 0, mQuestionCounter: 0, mOutput: "");
  }
}

class GameBloc extends Bloc<GameEvent, GameState> {
  List<String> mStates = [];
  List<String> mCapitols = [];

  void init() async {
    var config = File('assets/StateCapitols.txt');
    var lines = await config.readAsLines();
    for (int i = 1; i < lines.length; i++) {
      List<String> parts = lines[i].split(',');
      mStates.add(parts[0]);
      mCapitols.add(parts[1]);
    }
  }

  GameBloc() : super(GameState.initial()) {
    on<StartGame>((event, emit) {
      emit(GameState.initial());
    });
    on<AskQuestion>((event, emit) {
      emit(GameState(
          mCorrect: state.mCorrect,
          mQuestionCounter: state.mQuestionCounter,
          mOutput:
              "What is the Capitol of ${mCapitols[state.mQuestionCounter]}?"));
    });
    on<SubmitAnswer>((event, emit) {
      if (event.input == mCapitols[state.mQuestionCounter]) {
        emit(GameState(
            mCorrect: state.mCorrect + 1,
            mQuestionCounter: state.mQuestionCounter + 1,
            mOutput: "Correct Answer"));
      } else {
        emit(GameState(
            mCorrect: state.mCorrect,
            mQuestionCounter: state.mQuestionCounter + 1,
            mOutput: "Incorrect Answer"));
      }
    });
    on<EndGame>((event, emit) {
      emit(GameState(
          mCorrect: state.mCorrect,
          mQuestionCounter: state.mQuestionCounter + 1,
          mOutput: "Game Finished"));
    });
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quizzle: State Capitols'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              BlocBuilder<GameBloc, GameState>(builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                  ],
                );
              })
            ])));
  }
}
