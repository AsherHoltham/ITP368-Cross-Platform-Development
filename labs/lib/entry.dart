// Barrett Koster 2024
// converter prep - entry
// This is an example of a field where a user can type
// something from the keyboard.  
// TextEditingController is the center thing here.

import "package:flutter/material.dart";

void main()
{ runApp(Converter());
}

// demo of a simple page
class Converter extends StatelessWidget
{
  const Converter({super.key});

  @override
  Widget build(BuildContext context)
  { return MaterialApp
    ( title: "converter prep - entry",
      home: ConveterHome(),
    );
  }
}

class ConveterHome extends StatefulWidget
{
  const ConveterHome({super.key});

  @override
  State<ConveterHome> createState() => ConveterHomeState();
}

class ConveterHomeState extends State<ConveterHome>
{ String copied = "zip";
  TextEditingController tec = TextEditingController();

  // build makes the PigHomeState widget
  @override
  Widget build( BuildContext context )
  { return Scaffold
    ( appBar: AppBar(title:Text("entry")),
      body: Column
      ( children:
        [ Container
          ( height: 50, width: 300,
            decoration: BoxDecoration
            ( border: Border.all (width:2,), ),    
            child: TextField
            (controller:tec, style:const TextStyle(fontSize:30) ),
          ),
          FloatingActionButton
          ( onPressed: ()
            { setState( () { copied = tec.text; }  ); },
            child: Text("copy"),
          ),
          TextWithBorder(copied),
        ],
      ),
    );
  }
}

// box with some text in it.
class TextWithBorder extends StatelessWidget
{ final String s; // this is what is in the box
  const TextWithBorder(this.s, {super.key});

  @override
  Widget build( BuildContext context )
  { return Container
    ( height: 50,
      width: 300,
      decoration: BoxDecoration
      ( border: Border.all
                (width:2,color: const Color(0xff0000ff)),
      ),    
      child: Text(s, style:const TextStyle(fontSize:30) ),
    );
  }
}
