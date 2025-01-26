// Asher Holtham
import "package:flutter/material.dart";

void main(){
  runApp(Robot());
}

class Robot extends StatelessWidget {
Coordinate mCoordinates;

Robot({ super.key }): mCoordinates = set();

@override
Widget build(BuildContext context){
  return MaterialApp(title: "Robot", home: RobotHome(mCoordinates));
}

}

Coordinate set(){
  return Coordinate(mX: 3,mY: 3);
}

class RobotHome extends StatefulWidget{
  Coordinate mCoordinates;
  RobotHome(this.mCoordinates);

  State<RobotHome> createState() => RobotHomeState(mCoordinates);
}

class RobotHomeState extends State<RobotHome>{
  Coordinate mCoordinates;
  RobotHomeState(this.mCoordinates);

  Widget build(BuildContext context) {


    return Scaffold(

    );
  }
}

class Coordinate{
  int mX;
  int mY;

  Coordinate({
    required this.mX, 
    required this.mY
  });
}

class Tile extends StatefulWidget{
  RobotHomeState rhs;
  TileState? ts;
  bool onTile;

  Tile({required this.rhs}): onTile = false;

  TileState createState() => TileState(rhs: rhs);
}

class TileState extends State<Tile>{
  RobotHomeState rhs;
  TileState({required this.rhs});

  @override
  Widget build(BuildContext context){
    return (

    );
    
  }
} 


class Btn extends StatefulWidget {
  final int mType;
  final RobotHomeState rhs;
  final GlobalKey<BtnState> btnKey;

  Btn({
    required this.mType,
    required this.rhs,
    required this.btnKey,
  }) : super(key: btnKey);

  @override
  BtnState createState() => BtnState();
}

class BtnState extends State<Btn> {
  late int mType;
  late RobotHomeState rhs;

  @override
  void initState() {
    super.initState();
    mType = widget.mType;
    rhs = widget.rhs;
  }

  void toggleState() {
    setState(() {
        if(mType == 0 && rhs.mCoordinates.mX < 4){
          rhs.mCoordinates.mX + 1;
        }
        if(mType == 1 && rhs.mCoordinates.mX < 4){
          rhs.mCoordinates.mX + 1;
        }

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
        )),
      );
  }
}
