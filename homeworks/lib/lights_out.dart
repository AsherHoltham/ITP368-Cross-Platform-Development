import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LightsOutEvent {}
class StartGame extends LightsOutEvent {
  final int numLights;
  StartGame(this.numLights);
}
class ToggleLight extends LightsOutEvent {
  final int index;
  ToggleLight(this.index);
}

class LightsOutState {
  final List<bool> lights;

  LightsOutState({required this.lights});

  bool get gameWon => lights.isNotEmpty && lights.every((light) => light == false);
}

class LightsOutBloc extends Bloc<LightsOutEvent, LightsOutState> {
  LightsOutBloc() : super(LightsOutState(lights: [])) {

    on<StartGame>((event, emit) {
      final random = Random();
      List<bool> lights =
          List.generate(event.numLights, (_) => random.nextBool());
      emit(LightsOutState(lights: lights));
    });

    on<ToggleLight>((event, emit) {
      if (state.lights.isEmpty) return; // No game running.
      List<bool> newLights = List.from(state.lights);
      int i = event.index;
      if (i >= 0 && i < newLights.length) 
      {
        newLights[i] = !newLights[i];
      }
      if (i - 1 >= 0) 
      {
        newLights[i - 1] = !newLights[i - 1];
      }
      if (i + 1 < newLights.length) 
      {
        newLights[i + 1] = !newLights[i + 1];
      }
      emit(LightsOutState(lights: newLights));
    });
  }
}

void main() {
  runApp(MyApp());
}

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

class LightsOutScreen extends StatefulWidget {
  @override
  _LightsOutScreenState createState() => _LightsOutScreenState();
}

class _LightsOutScreenState extends State<LightsOutScreen> {
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