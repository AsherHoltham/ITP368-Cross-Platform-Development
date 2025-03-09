import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

/// The different phases of the game.
enum GamePhase {
  pickingPlayerSuitcase,
  waitingForDealerDecision,
  waitingForReveal,
  gameOver,
}

/// A suitcase holds a hidden monetary value.
class Suitcase {
  final int id;
  final int value;
  bool isRevealed;
  bool isPlayer;

  Suitcase({
    required this.id,
    required this.value,
    this.isRevealed = false,
    this.isPlayer = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'isRevealed': isRevealed,
      'isPlayer': isPlayer,
    };
  }

  factory Suitcase.fromJson(Map<String, dynamic> json) {
    return Suitcase(
      id: json['id'],
      value: json['value'],
      isRevealed: json['isRevealed'],
      isPlayer: json['isPlayer'],
    );
  }
}

/// The overall game state.
class GameState {
  final List<Suitcase> suitcases;
  final int? playerSuitcaseIndex;
  final GamePhase phase;
  final double? dealerOffer;
  final double? winnings;

  GameState({
    required this.suitcases,
    this.playerSuitcaseIndex,
    required this.phase,
    this.dealerOffer,
    this.winnings,
  });

  GameState copyWith({
    List<Suitcase>? suitcases,
    int? playerSuitcaseIndex,
    GamePhase? phase,
    double? dealerOffer,
    double? winnings,
  }) {
    return GameState(
      suitcases: suitcases ?? this.suitcases,
      playerSuitcaseIndex: playerSuitcaseIndex ?? this.playerSuitcaseIndex,
      phase: phase ?? this.phase,
      dealerOffer: dealerOffer,
      winnings: winnings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suitcases': suitcases.map((s) => s.toJson()).toList(),
      'playerSuitcaseIndex': playerSuitcaseIndex,
      'phase': phase.toString(),
      'dealerOffer': dealerOffer,
      'winnings': winnings,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    List<dynamic> suitcaseJson = json['suitcases'];
    List<Suitcase> suitcases =
        suitcaseJson.map((s) => Suitcase.fromJson(s)).toList();
    GamePhase phase;
    String phaseStr = json['phase'];
    if (phaseStr.contains('pickingPlayerSuitcase')) {
      phase = GamePhase.pickingPlayerSuitcase;
    } else if (phaseStr.contains('waitingForDealerDecision')) {
      phase = GamePhase.waitingForDealerDecision;
    } else if (phaseStr.contains('waitingForReveal')) {
      phase = GamePhase.waitingForReveal;
    } else {
      phase = GamePhase.gameOver;
    }
    return GameState(
      suitcases: suitcases,
      playerSuitcaseIndex: json['playerSuitcaseIndex'],
      phase: phase,
      dealerOffer:
          (json['dealerOffer'] != null) ? json['dealerOffer'].toDouble() : null,
      winnings: (json['winnings'] != null) ? json['winnings'].toDouble() : null,
    );
  }
}

/// Game events for the Bloc.
abstract class GameEvent {}

class StartNewGameEvent extends GameEvent {}

class SelectPlayerSuitcaseEvent extends GameEvent {
  final int index;
  SelectPlayerSuitcaseEvent(this.index);
}

class DealerDecisionEvent extends GameEvent {
  /// Accept = true means “Deal” (end game now with the dealer’s offer)
  /// Accept = false means “No Deal” (continue the game).
  final bool accept;
  DealerDecisionEvent(this.accept);
}

class RevealSuitcaseEvent extends GameEvent {
  final int index;
  RevealSuitcaseEvent(this.index);
}

class ResetGameEvent extends GameEvent {}

/// The Bloc which holds the game’s logic.
class GameBloc extends Bloc<GameEvent, GameState> {
  final SharedPreferences prefs;
  static const String storageKey = 'deal_or_no_deal_state';

  GameBloc({required this.prefs}) : super(_initializeState()) {
    on<StartNewGameEvent>(_onStartNewGame);
    on<SelectPlayerSuitcaseEvent>(_onSelectPlayerSuitcase);
    on<DealerDecisionEvent>(_onDealerDecision);
    on<RevealSuitcaseEvent>(_onRevealSuitcase);
    on<ResetGameEvent>(_onResetGame);
  }

  /// Creates a new game state with randomized suitcases.
  static GameState _initializeState() {
    List<int> values = [
      1,
      5,
      10,
      100,
      1000,
      5000,
      10000,
      100000,
      500000,
      1000000
    ];
    values.shuffle(Random());
    List<Suitcase> suitcases = List.generate(10, (index) {
      return Suitcase(id: index, value: values[index]);
    });
    return GameState(
        suitcases: suitcases, phase: GamePhase.pickingPlayerSuitcase);
  }

  Future<void> _saveState(GameState state) async {
    String jsonString = json.encode(state.toJson());
    await prefs.setString(storageKey, jsonString);
  }

  void _onStartNewGame(StartNewGameEvent event, Emitter<GameState> emit) {
    GameState newState = _initializeState();
    emit(newState);
    _saveState(newState);
  }

  void _onSelectPlayerSuitcase(
      SelectPlayerSuitcaseEvent event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.pickingPlayerSuitcase) return;
    List<Suitcase> updated = List.from(state.suitcases);
    if (event.index < 0 || event.index >= updated.length) return;
    updated[event.index].isPlayer = true;
    // Calculate the dealer’s offer using only the hidden suitcases (exclude the player's case).
    List<Suitcase> remaining = updated.where((s) => !s.isPlayer).toList();
    double sum = remaining.fold(0, (prev, s) => prev + s.value);
    double avg = sum / remaining.length;
    double offer = 0.9 * avg;
    GameState newState = state.copyWith(
      suitcases: updated,
      playerSuitcaseIndex: event.index,
      phase: GamePhase.waitingForDealerDecision,
      dealerOffer: offer,
    );
    emit(newState);
    _saveState(newState);
  }

  void _onDealerDecision(DealerDecisionEvent event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.waitingForDealerDecision) return;
    if (event.accept) {
      GameState newState = state.copyWith(
        phase: GamePhase.gameOver,
        winnings: state.dealerOffer,
        dealerOffer: null,
      );
      emit(newState);
      _saveState(newState);
    } else {
      GameState newState = state.copyWith(
        phase: GamePhase.waitingForReveal,
        dealerOffer: null,
      );
      emit(newState);
      _saveState(newState);
    }
  }

  void _onRevealSuitcase(RevealSuitcaseEvent event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.waitingForReveal) return;
    List<Suitcase> updated = List.from(state.suitcases);
    if (event.index < 0 || event.index >= updated.length) return;
    if (updated[event.index].isRevealed || updated[event.index].isPlayer)
      return;
    updated[event.index].isRevealed = true;
    // Calculate remaining suitcases (excluding revealed and player's)
    List<Suitcase> remaining =
        updated.where((s) => !s.isRevealed && !s.isPlayer).toList();
    if (remaining.isEmpty) {
      int playerIndex = state.playerSuitcaseIndex!;
      double winnings = updated[playerIndex].value.toDouble();
      GameState newState = state.copyWith(
        suitcases: updated,
        phase: GamePhase.gameOver,
        winnings: winnings,
      );
      emit(newState);
      _saveState(newState);
    } else {
      double sum = remaining.fold(0, (prev, s) => prev + s.value);
      double avg = sum / remaining.length;
      double offer = 0.9 * avg;
      GameState newState = state.copyWith(
        suitcases: updated,
        phase: GamePhase.waitingForDealerDecision,
        dealerOffer: offer,
      );
      emit(newState);
      _saveState(newState);
    }
  }

  void _onResetGame(ResetGameEvent event, Emitter<GameState> emit) {
    GameState newState = _initializeState();
    emit(newState);
    _saveState(newState);
  }
}

/// The root widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<SharedPreferences> _prefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefs(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BlocProvider(
            create: (context) {
              SharedPreferences prefs = snapshot.data!;
              return GameBloc(prefs: prefs)..add(StartNewGameEvent());
            },
            child: MaterialApp(
              title: 'Deal or No Deal',
              theme: ThemeData(
                primarySwatch: Colors.deepPurple,
                scaffoldBackgroundColor: Colors.grey[200],
              ),
              home: DealOrNoDealPage(),
            ),
          );
        } else {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
      },
    );
  }
}

/// The main game page with updated UI.
class DealOrNoDealPage extends StatefulWidget {
  const DealOrNoDealPage({super.key});

  @override
  _DealOrNoDealPageState createState() => _DealOrNoDealPageState();
}

class _DealOrNoDealPageState extends State<DealOrNoDealPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus so that keyboard events are captured.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (event) {
            if (event is RawKeyDownEvent) {
              // Dealer decision keys when waiting for decision.
              if (state.phase == GamePhase.waitingForDealerDecision) {
                if (event.logicalKey.keyLabel.toLowerCase() == 'd') {
                  context.read<GameBloc>().add(DealerDecisionEvent(true));
                } else if (event.logicalKey.keyLabel.toLowerCase() == 'n') {
                  context.read<GameBloc>().add(DealerDecisionEvent(false));
                }
              } else if (state.phase == GamePhase.waitingForReveal) {
                // Use number keys (1-10) to reveal a suitcase.
                String keyLabel = event.logicalKey.keyLabel;
                int? num = int.tryParse(keyLabel);
                if (num != null && num >= 1 && num <= 10) {
                  int index = num - 1;
                  context.read<GameBloc>().add(RevealSuitcaseEvent(index));
                }
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Deal or No Deal'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<GameBloc>().add(ResetGameEvent());
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _getStatusText(state),
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (state.playerSuitcaseIndex != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Center(
                        child: Text(
                          'Your Suitcase: ${state.playerSuitcaseIndex! + 1}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Suitcases Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: state.suitcases.length,
                      itemBuilder: (context, index) {
                        Suitcase s = state.suitcases[index];
                        bool clickable = false;
                        if (state.phase == GamePhase.pickingPlayerSuitcase) {
                          clickable = true;
                        } else if (state.phase == GamePhase.waitingForReveal &&
                            !s.isRevealed &&
                            !s.isPlayer) {
                          clickable = true;
                        }
                        return InkWell(
                          onTap: clickable
                              ? () {
                                  if (state.phase ==
                                      GamePhase.pickingPlayerSuitcase) {
                                    context
                                        .read<GameBloc>()
                                        .add(SelectPlayerSuitcaseEvent(index));
                                  } else if (state.phase ==
                                      GamePhase.waitingForReveal) {
                                    context
                                        .read<GameBloc>()
                                        .add(RevealSuitcaseEvent(index));
                                  }
                                }
                              : null,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color:
                                s.isRevealed ? Colors.grey[400] : Colors.white,
                            child: Center(
                              child: s.isRevealed
                                  ? Text(
                                      '\$${s.value}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Money Table displayed as Chips.
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _buildMoneyChips(state),
                      ),
                    ),
                  ),
                  // Dealer Offer or Game Over display.
                  if (state.phase == GamePhase.waitingForDealerDecision)
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              'Dealer Offer: \$${state.dealerOffer?.toStringAsFixed(2) ?? ''}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<GameBloc>()
                                        .add(DealerDecisionEvent(true));
                                  },
                                  child: const Text('DEAL (d)'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<GameBloc>()
                                        .add(DealerDecisionEvent(false));
                                  },
                                  child: const Text('NO DEAL (n)'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (state.phase == GamePhase.gameOver)
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              'Game Over! You won: \$${state.winnings?.toStringAsFixed(2) ?? ''}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<GameBloc>().add(ResetGameEvent());
                              },
                              child: const Text('Reset Game'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Text(
                    'Keyboard: Press number (1-10) to select a suitcase, "d" for deal, "n" for no deal.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(GameState state) {
    switch (state.phase) {
      case GamePhase.pickingPlayerSuitcase:
        return 'Pick your suitcase.';
      case GamePhase.waitingForDealerDecision:
        return 'Dealer has made an offer. Accept or Reject?';
      case GamePhase.waitingForReveal:
        return 'Select a suitcase to reveal.';
      case GamePhase.gameOver:
        return 'Game Over.';
      default:
        return '';
    }
  }

  List<Widget> _buildMoneyChips(GameState state) {
    List<int> moneyValues = [
      1,
      5,
      10,
      100,
      1000,
      5000,
      10000,
      100000,
      500000,
      1000000
    ];
    return moneyValues.map((value) {
      bool revealed =
          state.suitcases.any((s) => s.isRevealed && s.value == value);
      return Chip(
        label: Text('\$${value.toString()}'),
        backgroundColor: revealed ? Colors.grey : Colors.lightGreenAccent[100],
      );
    }).toList();
  }
}
