// Barrett Koster 2025
// Boggle (more or less?)
// It shuffles a grid of letter-cubes and lets you make
// words by clicking on letters, then hit 'done' to 
// end word.

import "dart:math";
import "package:flutter/material.dart";

void main(){ 
  runApp(Machine()); 
}

// This does ONE board of letters.
class Machine extends StatelessWidget {
  List<List<bool>> bottles = [ ]; // 25 bottles in the machine

  Machine({ super.key }) : bottles = fill(); // note: shake()

  @override
  Widget build(BuildContext context){ 
    return MaterialApp( title: "Coke Machine", home: MachineHome(bottles),);
  }
}

List<List<bool>> fill(){
List<List<bool>> retList = List.generate(
  5, // Number of rows
  (_) => List.generate(
    5, // Number of columns
    (_) => false, // Default value
  ),
);
  return retList;
}

class MachineHome extends StatefulWidget{
  List<List<bool>> bottles;

  MachineHome( this.bottles );

  @override
  State<MachineHome> createState() => MachineHomeState( bottles );
}

class MachineHomeState extends State<MachineHome> {
  List<List<bool>> bottles;
  List<GlobalKey<BtnState>> rowButtonKeys = [];
  List<GlobalKey<BtnState>> colButtonKeys = [];

  MachineHomeState(this.bottles);

  @override
  void initState() {
    super.initState();

    // Initialize button keys for rows and columns
    rowButtonKeys = List.generate(5, (_) => GlobalKey<BtnState>());
    colButtonKeys = List.generate(5, (_) => GlobalKey<BtnState>());
  }

  @override
  Widget build(BuildContext context) {
    // Build the grid of bottles
    List<Widget> gridRows = [];
    for (int i = 0; i < 5; i++) {
      List<Widget> rowCells = [];
      for (int j = 0; j < 5; j++) {
        rowCells.add(
          bottles[i][j]
              ? Icon(Icons.check_box, color: Colors.green) // Full icon
              : Icon(Icons.check_box_outline_blank, color: Colors.red), // Empty icon
        );
      }
      gridRows.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: rowCells));
    }

    // Build row buttons
    List<Widget> rowButtons = List.generate(
      5,
      (index) => Btn(
        mType: "$index",
        mState: false,
        mhs: this,
        btnKey: rowButtonKeys[index],
      ),
    );

    // Build column buttons
    List<String> btnVars = ['A', 'B', 'C', 'D', 'E'];
    List<Widget> colButtons = List.generate(
      5,
      (index) => Btn(
        mType: btnVars[index],
        mState: false,
        mhs: this,
        btnKey: colButtonKeys[index],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Coke Machine"),
      ),
      body: Column(
        children: [
          Column(children: gridRows), // Grid of bottles
          Row(mainAxisAlignment: MainAxisAlignment.center, children: rowButtons),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: colButtons),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                int selectedRow = -1;
                int selectedCol = -1;

                // Determine selected row
                for (int r = 0; r < 5; r++) {
                  if (rowButtonKeys[r].currentState?.mState == true) {
                    selectedRow = r;
                  }
                }

                // Determine selected column
                for (int c = 0; c < 5; c++) {
                  if (colButtonKeys[c].currentState?.mState == true) {
                    selectedCol = c;
                  }
                }

                // Update the bottle grid if valid selection
                if (selectedRow != -1 && selectedCol != -1) {
                  bottles[selectedRow][selectedCol] = false;
                }
              });
            },
            child: Text(
              "Buy",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// FaceUp is a single letter in a box on the screen.
// If you click on it, it highlights.
class Btn extends StatefulWidget {
  final String mType;
  final bool mState;
  final MachineHomeState mhs;
  final GlobalKey<BtnState> btnKey;

  Btn({
    required this.mType,
    required this.mState,
    required this.mhs,
    required this.btnKey,
  }) : super(key: btnKey);

  @override
  BtnState createState() => BtnState();
}

class BtnState extends State<Btn> {
  late String mType;
  late bool mState;
  late MachineHomeState mhs;

  @override
  void initState() {
    super.initState();
    mType = widget.mType;
    mState = widget.mState;
    mhs = widget.mhs;
  }

  void toggleState() {
    setState(() {
      mState = !mState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: toggleState,
      child: Text(
        mType,
        style: TextStyle(
          fontSize: 15, 
          backgroundColor: mState? Color(0xff000000): Color(0xff00ff00),
        )),
      );
  }
}
