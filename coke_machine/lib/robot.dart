// Asher Holtham
import "package:flutter/material.dart";

void main(){
  runApp(Robot());
}

class Robot extends StatelessWidget {
final mRobot = 'R';
Coordinate mCoordinates = Coordinate(mX: 3,mY: 3);

Robot({ super.key });

@override
Widget build(BuildContext context){
  return MaterialApp(title: "Robot", home: RobotHome());
}

}

class RobotHome extends StatefulWidget{

  RobotHome();

  State<RobotHome> createState() => RobotHomeState();
}

class RobotHomeState extends State<RobotHome>{

  RobotHomeState();

  Widget build(BuildContext context) {

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