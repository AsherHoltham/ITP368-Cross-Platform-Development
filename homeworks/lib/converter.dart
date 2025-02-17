import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main entry point of the app.
void main() {
  runApp(MyApp());
}

/// The top-level widget that sets up MaterialApp and provides the ConversionBloc.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => ConversionBloc(),
        child: ConversionScreen(),
      ),
    );
  }
}

/// Enumeration for the four conversion operations.
enum ConversionType {
  fahrenheitToCelsius,
  celsiusToFahrenheit,
  poundsToKilograms,
  kilogramsToPounds,
}

/// Base class for all events in our conversion BloC.
abstract class ConversionEvent {}

/// Event triggered when a digit button is pressed.
class DigitPressed extends ConversionEvent {
  final String digit;
  DigitPressed({required this.digit});
}

/// Event triggered when the decimal point button is pressed.
class DecimalPressed extends ConversionEvent {}

/// Event triggered when the negative sign button is pressed.
class NegativePressed extends ConversionEvent {}

/// Event triggered when the clear button is pressed.
class ClearPressed extends ConversionEvent {}

/// Event triggered when a conversion operation button is pressed.
class OperationPressed extends ConversionEvent {
  final ConversionType conversionType;
  OperationPressed({required this.conversionType});
}

/// The state of the conversion calculator.
class ConversionState {
  final String input;  // The user-entered number as a string.
  final String output; // The converted result as a string.

  ConversionState({required this.input, required this.output});

  /// Returns a copy of the current state with optional new values.
  ConversionState copyWith({String? input, String? output}) {
    return ConversionState(
      input: input ?? this.input,
      output: output ?? this.output,
    );
  }

  /// The initial state with empty input and output.
  factory ConversionState.initial() {
    return ConversionState(input: '', output: '');
  }
}

/// The BloC that handles conversion logic and user input events.
class ConversionBloc extends Bloc<ConversionEvent, ConversionState> {
  ConversionBloc() : super(ConversionState.initial()) {
    // When a digit is pressed, append it to the input string.
    on<DigitPressed>((event, emit) {
      final newInput = state.input + event.digit;
      emit(state.copyWith(input: newInput, output: ''));
    });

    // When the decimal button is pressed, add a decimal point if not already present.
    on<DecimalPressed>((event, emit) {
      if (!state.input.contains('.')) {
        // If input is empty, start with "0."
        final newInput = state.input.isEmpty ? '0.' : state.input + '.';
        emit(state.copyWith(input: newInput, output: ''));
      }
    });

    // Toggle the negative sign of the current input.
    on<NegativePressed>((event, emit) {
      String newInput;
      if (state.input.startsWith('-')) {
        newInput = state.input.substring(1);
      } else {
        newInput = '-' + state.input;
      }
      emit(state.copyWith(input: newInput, output: ''));
    });

    // Clear both the input and output.
    on<ClearPressed>((event, emit) {
      emit(ConversionState.initial());
    });

    // When a conversion operation is pressed, perform the calculation.
    on<OperationPressed>((event, emit) {
      final inputValue = double.tryParse(state.input);
      if (inputValue == null) {
        // If parsing fails, display an error.
        emit(state.copyWith(output: 'Error'));
        return;
      }

      double result;
      // Perform the appropriate conversion based on the button pressed.
      switch (event.conversionType) {
        case ConversionType.fahrenheitToCelsius:
          result = (inputValue - 32) * 5 / 9;
          break;
        case ConversionType.celsiusToFahrenheit:
          result = (inputValue * 9 / 5) + 32;
          break;
        case ConversionType.poundsToKilograms:
          result = inputValue * 0.45359237;
          break;
        case ConversionType.kilogramsToPounds:
          result = inputValue / 0.45359237;
          break;
      }
      // Format the result to two decimal places.
      final outputStr = result.toStringAsFixed(2);
      emit(state.copyWith(output: outputStr));
    });
  }
}

/// The main screen displaying input/output and the keypad.
class ConversionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display area for the input and converted output.
            BlocBuilder<ConversionBloc, ConversionState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        state.input,
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        state.output,
                        style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            // Row of conversion operation buttons.
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<ConversionBloc>().add(
                        OperationPressed(conversionType: ConversionType.fahrenheitToCelsius));
                  },
                  child: Text("F → C"),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ConversionBloc>().add(
                        OperationPressed(conversionType: ConversionType.celsiusToFahrenheit));
                  },
                  child: Text("C → F"),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ConversionBloc>().add(
                        OperationPressed(conversionType: ConversionType.poundsToKilograms));
                  },
                  child: Text("lb → kg"),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ConversionBloc>().add(
                        OperationPressed(conversionType: ConversionType.kilogramsToPounds));
                  },
                  child: Text("kg → lb"),
                ),
              ],
            ),
            SizedBox(height: 20),
            // The number keypad.
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  // First row
                  NumberButton('7'),
                  NumberButton('8'),
                  NumberButton('9'),
                  // Second row
                  NumberButton('4'),
                  NumberButton('5'),
                  NumberButton('6'),
                  // Third row
                  NumberButton('1'),
                  NumberButton('2'),
                  NumberButton('3'),
                  // Fourth row: negative, 0, decimal
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConversionBloc>().add(NegativePressed());
                    },
                    child: Text("±", style: TextStyle(fontSize: 24)),
                  ),
                  NumberButton('0'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConversionBloc>().add(DecimalPressed());
                    },
                    child: Text(".", style: TextStyle(fontSize: 24)),
                  ),
                  // Clear button (spanning the width of one cell)
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConversionBloc>().add(ClearPressed());
                    },
                    child: Text("C", style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget for number buttons.
class NumberButton extends StatelessWidget {
  final String number;
  const NumberButton(this.number, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // When pressed, dispatch a DigitPressed event.
        context.read<ConversionBloc>().add(DigitPressed(digit: number));
      },
      child: Text(
        number,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}