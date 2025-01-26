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
  List<Bottle> num_buttons = [];
  
  Column cans = Column(children:<Row>[]);

  MachineHomeState(this.bottles);

  @override
  Widget build(BuildContext context){
    for(int i = 0; i < 5; i++){
      Row r = Row(children:[]);
      for(int j = 0; j < 5; j++){
        if(bottles[i][j] == true){
          r.children.add( /**add Full ICON */ );
        } else {
          r.children.add( /**add Empty ICON */ );
        }
      }
      cans.children.add(r);
    }
  }

  return Scaffold
  ( 
    appBar: AppBar(title: Text("Coke Machine")),
    body: Column
    ( 
      children:
      [ cans, // This is the grid of letters to click on.

      FloatingActionButton(
        onPressed: (){ 
          setState( 
            (){   
              
            }
          );
        },
        child: Text("Buy", style:TextStyle(fontSize:20),),
      ),
      ],
    ),
  );
}



// FaceUp is a single letter in a box on the screen.
// If you click on it, it highlights.
class Bottle extends StatefulWidget
{
  MachineHomeState mhs; // This is the state of the enclosing app.
                       // We have to pass it down through the constructors
                       // so that a single letter can add itself to the word.
  BottleState? bs;

  Bottle({required this.mhs});

  State<Bottle> createState() => (bs = BottleState(mhs:mhs));
}

class BottleState extends State<Bottle>
{
  MachineHomeState mhs; // And passed down again ... so we can add to the word.
  bool picked = false; // black border if picked.
                       // We should probably also disallow picking again.  Whatever.
  BottleState({required this.mhs});

  @override
  Widget build(BuildContext context ){ 
    return Listener // holds Container with letter, and listens
    ( onPointerDown: (_)
      { setState((){picked=true;} ); 
      }, 
      child: Container
      ( height: 50, width: 50,
        decoration: BoxDecoration // changes color if picked
        ( border: Border.all
          ( width:2, 
            color: picked? Color(0xff000000): Color(0xff00ff00), 
          ),
        ),
      ),
    );
  }
}
