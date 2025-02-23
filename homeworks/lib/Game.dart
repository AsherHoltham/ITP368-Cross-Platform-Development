import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter_bloc/flutter_bloc.dart';

// Event definitions
abstract class GameEvent {}

class StartGame extends GameEvent {}

class AskQuestion extends GameEvent {}

class SubmitAnswer extends GameEvent {
  final String input;
  SubmitAnswer({required this.input});
}

class NextQuestion extends GameEvent {}

class EndGame extends GameEvent {}

// Game state includes an 'answered' flag.
class GameState {
  final int mCorrect;
  final int mQuestionCounter;
  final String mOutput;
  final bool answered;

  GameState({
    required this.mCorrect,
    required this.mQuestionCounter,
    required this.mOutput,
    required this.answered,
  });

  factory GameState.initial() {
    return GameState(
      mCorrect: 0,
      mQuestionCounter: 0,
      mOutput: '',
      answered: false,
    );
  }
}

class GameBloc extends Bloc<GameEvent, GameState> {
  List<String> mStates = [];
  List<String> mCapitols = [];

  // Updated init() method using rootBundle
  Future<void> init() async {
    final data = await rootBundle.loadString('assets/StateCapitols.txt');
    final lines = data.split('\n');
    // Skip the header (first line)
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue; // Skip empty lines
      List<String> parts = lines[i].split(',');
      mStates.add(parts[0].trim());
      mCapitols.add(parts[1].trim());
    }
  }

  GameBloc() : super(GameState.initial()) {
    // Load file data then start the quiz.
    init().then((_) {
      add(AskQuestion());
    });

    on<StartGame>((event, emit) {
      emit(GameState.initial());
      add(AskQuestion());
    });

    on<AskQuestion>((event, emit) {
      if (state.mQuestionCounter < mStates.length) {
        emit(GameState(
          mCorrect: state.mCorrect,
          mQuestionCounter: state.mQuestionCounter,
          mOutput: "What is the capitol of ${mStates[state.mQuestionCounter]}?",
          answered: false,
        ));
      } else {
        emit(GameState(
          mCorrect: state.mCorrect,
          mQuestionCounter: state.mQuestionCounter,
          mOutput: "Game Finished! Final Score: ${state.mCorrect} / ${mStates.length}",
          answered: true,
        ));
      }
    });

    on<SubmitAnswer>((event, emit) {
      if (state.mQuestionCounter < mStates.length) {
        String correctAnswer = mCapitols[state.mQuestionCounter];
        String feedback;
        int updatedCorrect = state.mCorrect;
        if (event.input.trim().toLowerCase() ==
            correctAnswer.trim().toLowerCase()) {
          feedback = "Correct Answer!";
          updatedCorrect++;
        } else {
          feedback = "Incorrect Answer. The correct answer is $correctAnswer.";
        }
        emit(GameState(
          mCorrect: updatedCorrect,
          mQuestionCounter: state.mQuestionCounter,
          mOutput: feedback,
          answered: true,
        ));
      }
    });

    on<NextQuestion>((event, emit) {
      int nextCounter = state.mQuestionCounter + 1;
      if (nextCounter < mStates.length) {
        emit(GameState(
          mCorrect: state.mCorrect,
          mQuestionCounter: nextCounter,
          mOutput: "What is the capitol of ${mStates[nextCounter]}?",
          answered: false,
        ));
      } else {
        emit(GameState(
          mCorrect: state.mCorrect,
          mQuestionCounter: nextCounter,
          mOutput: "Game Finished! Final Score: ${state.mCorrect} / ${mStates.length}",
          answered: true,
        ));
      }
    });

    on<EndGame>((event, emit) {
      emit(GameState(
        mCorrect: state.mCorrect,
        mQuestionCounter: state.mQuestionCounter,
        mOutput: "Game Finished! Final Score: ${state.mCorrect} / ${mStates.length}",
        answered: true,
      ));
    });
  }
}

// UI: A stateful widget that handles answer input and displays the quiz.
class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzle: State Capitols'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display question or feedback.
                Text(
                  state.mOutput,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                // Display current score.
                Text(
                  "Score: ${state.mCorrect} / ${state.mQuestionCounter}",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                // Show input field if waiting for an answer.
                if (!state.answered && state.mOutput.isNotEmpty)
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Your Answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                SizedBox(height: 20),
                // Submit answer button.
                if (!state.answered && state.mOutput.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      final answer = _controller.text;
                      if (answer.isNotEmpty) {
                        gameBloc.add(SubmitAnswer(input: answer));
                        _controller.clear();
                      }
                    },
                    child: Text('Submit'),
                  ),
                // Next/Finish button after feedback.
                if (state.answered)
                  ElevatedButton(
                    onPressed: () {
                      if (state.mQuestionCounter < gameBloc.mStates.length - 1) {
                        gameBloc.add(NextQuestion());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Quiz Finished!")),
                        );
                      }
                    },
                    child: Text(
                      state.mQuestionCounter < gameBloc.mStates.length - 1 ? 'Next' : 'Finish'
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizzle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => GameBloc(),
        child: GameScreen(),
      ),
    );
  }
}