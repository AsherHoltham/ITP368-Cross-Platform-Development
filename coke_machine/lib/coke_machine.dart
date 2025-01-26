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
  List<List<bool>> retList = [];
  for(int i = 0; i < 5; i++){
    for(int j = 0; j < 5; j++){
      retList[i].add(true);
    }
  }
  return retList;
}

class MachineHome extends StatefulWidget{
  List<List<bool>> bottles;

  MachineHome( this.bottles );

  @override
  State<MachineHome> createState() => MachineHomeState( bottles );
}

class MachineHomeState extends State<MachineHome>{
  List<List<bool>> bottles; // from above, fixed

  Column cans = Column(children:<Row>[]);
  Row rowButtonInputs = Row(children:<Btn>[]);
  Row colButtonInputs = Row(children:<Btn>[]);

  MachineHomeState(this.bottles);

  @override
  Widget build(BuildContext context){
    for(int i = 0; i < 5; i++){
      Row r = Row(
        children:[]
      );
      for(int j = 0; j < 5; j++){
        if(bottles[i][j] == true){
          r.children.add( /**add Full ICON */ );
        } else {
          r.children.add( /**add Empty ICON */ );
        }
      }
      cans.children.add(r);
    }

    for(int i = 0; i < 5; i++){
      Btn btn = Btn("$i", false, mhs:this);
      rowButtonInputs.children.add(btn);
    }

    List<String> btnVars = ['A', 'B', 'C', 'D', 'E'];
    for(int i = 0; i < 5; i++){
      Btn btn = Btn(btnVars[i], false, mhs:this);
      colButtonInputs.children.add(btn);
    }

    return Scaffold( 
      appBar: AppBar(
        title: Text("Coke Machine")
        ),
      body: Column( 
        children: [ 
          cans, // This is the grid of letters to click on.
          rowButtonInputs,
          colButtonInputs,

          FloatingActionButton(
            onPressed: (){ 
              setState( 
                (){
                  int row = 5;
                  int col = 5;
                  for(int r = 0; r < 5; r++){
                    if(rowButtonInputs.children[r].mState == true){
                      row = r;
                    }
                  }
                  for(int c = 0; c < 5; c++){
                    if(colButtonInputs.children[c].mState == true){
                      col = c;
                    }
                  }
                  if( row != 5 && col != 5){
                    bottles[row][col] = false;
                  }
                }
              );
            },
            child: Text("Buy", style: TextStyle(fontSize:20),),
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
  final bool initialState;
  final MachineHomeState mhs;
  final GlobalKey<BtnState> btnKey;

  Btn({
    required this.mType,
    required this.initialState,
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
    mState = widget.initialState;
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
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
