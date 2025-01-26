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
  Row int_button_inputs = Row(children:<Btn>[]);
  Row char_button_inputs = Row(children:<Btn>[]);

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
      Btn btn = Btn("$i", 0, mhs:this);
      int_button_inputs.children.add(btn);
    }
  }

  return Scaffold( 
    appBar: AppBar(
      title: Text("Coke Machine")
      ),
    body: Column( 
      children: [ 
        cans, // This is the grid of letters to click on.
        int_button_inputs,
        char_button_inputs,

        FloatingActionButton(
          onPressed: (){ 
            setState( 
              (){   
                
              }
            );
          },
          child: Text("Buy", style: TextStyle(fontSize:20),),
        ),
      ],
    ),
  );
}



// FaceUp is a single letter in a box on the screen.
// If you click on it, it highlights.
class Btn extends StatefulWidget{
  final String mType;
  bool mInput;
  MachineHomeState mhs;
  BtnState? bs;

  Btn(String type, bool input, {required this.mhs}): mType = type, mInput = input;

  State<Btn> createState() => (bs = BtnState(mType, mInput, mhs:mhs));
}

class BtnState extends State<Btn>{
  String mType;
  bool mInput;
  MachineHomeState mhs;

  BtnState(String type, bool input, {required this.mhs}): mType = type, mInput = input;

  @override
  Widget build(BuildContext context ){ 
    return 
    FloatingActionButton(
      onPressed: (){
        setState( 
          (){   
            if(mInput == true){
              mInput = false;
            } else {
              mInput = true;
            }
          }
        );
      },
      child: Text(
        mType, style: TextStyle(
          fontSize:15
        ),
      )
    );
  }
}
