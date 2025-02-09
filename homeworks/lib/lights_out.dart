import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ==========================
/// 1. Define the Events
/// ==========================
abstract class LightsOutEvent {}

/// Event to start a new game with a given number of lights.
class StartGame extends LightsOutEvent {
  final int numLights;
  StartGame(this.numLights);
}

/// Event to toggle a light (and its neighbors) at the given index.
class ToggleLight extends LightsOutEvent {
  final int index;
  ToggleLight(this.index);
}

/// ==========================
/// 2. Define the State
/// ==========================
class LightsOutState {
  final List<bool> lights;

  LightsOutState({required this.lights});

  /// The game is won when all lights are off.
  bool get gameWon => lights.isNotEmpty && lights.every((light) => light == false);
}

/// ==========================
/// 3. Create the BLoC
/// ==========================
class LightsOutBloc extends Bloc<LightsOutEvent, LightsOutState> {
  LightsOutBloc() : super(LightsOutState(lights: [])) {
    /// When the StartGame event is added, generate a list of random booleans.
    on<StartGame>((event, emit) {
      final random = Random();
      List<bool> lights =
          List.generate(event.numLights, (_) => random.nextBool());
      emit(LightsOutState(lights: lights));
    });

    /// When a ToggleLight event is added, flip the selected light and its neighbors.
    on<ToggleLight>((event, emit) {
      if (state.lights.isEmpty) return; // No game running.
      List<bool> newLights = List.from(state.lights);
      int i = event.index;

      // Toggle the tapped light.
      if (i >= 0 && i < newLights.length) {
        newLights[i] = !newLights[i];
      }
      // Toggle the left neighbor if it exists.
      if (i - 1 >= 0) {
        newLights[i - 1] = !newLights[i - 1];
      }
      // Toggle the right neighbor if it exists.
      if (i + 1 < newLights.length) {
        newLights[i + 1] = !newLights[i + 1];
      }
      emit(LightsOutState(lights: newLights));
    });
  }
}

/// ==========================
/// 4. Build the Application
/// ==========================
void main() {
  runApp(MyApp());
}

/// MyApp sets up the BLoC provider for the widget tree.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lights Out',
      home: BlocProvider(
        create: (_) => LightsOutBloc(),
        child: LightsOutScreen(),
      ),
    );
  }
}

/// ==========================
/// 5. Build the UI
/// ==========================
class LightsOutScreen extends StatefulWidget {
  @override
  _LightsOutScreenState createState() => _LightsOutScreenState();
}

class _LightsOutScreenState extends State<LightsOutScreen> {
  // Controller to capture the number of lights input.
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lights Out')
      ),
      body: BlocBuilder<LightsOutBloc, LightsOutState>(
        builder: (context, state) 
        {
          // If no game is running (empty lights list), show the input form.
          if (state.lights.isEmpty) 
          {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Enter number of lights:"),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "E.g. 5"),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final n = int.tryParse(_controller.text);
                      if (n != null && n > 0) 
                      {
                        // Start a new game.
                        context.read<LightsOutBloc>().add(StartGame(n));
                      }
                    },
                    child: const Text("Start Game"),
                  ),
                ],
              ),
            );
          } 
          else 
          {
            // A game is in progress; show the board and (if applicable) a win message.
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.gameWon)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "You Won!",
                      style: TextStyle(fontSize: 24, color: Colors.green[700]),
                    ),
                  ),
                // Display the row of lights.
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(state.lights.length, (index) {
                        bool lightOn = state.lights[index];
                        return GestureDetector(
                          onTap: () {
                            // Tapping dispatches a ToggleLight event.
                            context.read<LightsOutBloc>().add(ToggleLight(index));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: lightOn ? Colors.yellow : Colors.grey[800],
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // A Reset button to start a new game with the same number of lights.
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<LightsOutBloc>()
                        .add(StartGame(state.lights.length));
                  },
                  child: const Text("Reset Game"),
                ),
                const SizedBox(height: 16),
              ],
            );
          }
        },
      ),
    );
  }
}