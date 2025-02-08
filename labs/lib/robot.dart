// Asher Holtham
import "package:flutter/material.dart";

void main(){
  runApp(Robot());
}

class Robot extends StatelessWidget {
  ValueNotifier<Coordinate> mCoordinates;

  Robot({ super.key }): mCoordinates = set();

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Robot", 
      home: RobotHome(mCoordinates)
    );
  }
}

ValueNotifier<Coordinate> set(){
  ValueNotifier<Coordinate> set = ValueNotifier(Coordinate(mX: 2,mY: 2));
  return set;
}

class RobotHome extends StatefulWidget{
  ValueNotifier<Coordinate> mCoordinates;
  RobotHome(this.mCoordinates);

  State<RobotHome> createState() => RobotHomeState(mCoordinates);
}

class RobotHomeState extends State<RobotHome>{
  ValueNotifier<Coordinate> mCoordinates;
  List<GlobalKey<BtnState>> rowButtonKeys = [];
  List<Tile> mTiles = [];
  Column tiles = Column(children:<Row>[]);

  RobotHomeState(this.mCoordinates);

  @override
  void initState() {
    super.initState();
    rowButtonKeys = List.generate(5, (_) => GlobalKey<BtnState>());
  }

  Widget build(BuildContext context) {
    List<Widget> gridRows = [];
    for(int i = 0; i < 5; i++){
      List<Widget> rowCells = [];
      for(int j = 0; j < 5; j++){
        Coordinate tileCoordinate = Coordinate(mX: i, mY: j);
        Tile t = Tile(tileCoordinate, rhs: this);
        rowCells.add(t);
      }
      gridRows.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: rowCells));
    }

    List<String> btnVars = ['UP', 'DOWN', 'LEFT', 'RIGHT'];
    List<Widget> rowButtons = List.generate(
      4,
      (index) => Btn(
        mType: btnVars[index],
        rhs: this,
        btnKey: rowButtonKeys[index],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Robot"),
      ),
      body: Column(
        children: [
          Column(children: gridRows),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: rowButtons),          
        ],
      )
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
  Coordinate tileCoords;
  bool onTile;

  Tile(coords, {required this.rhs}): tileCoords = coords, onTile = false{
    if(tileCoords.mX == rhs.mCoordinates.value.mX && tileCoords.mY == rhs.mCoordinates.value.mY){
      onTile = true;
    }
  }

  TileState createState() => TileState();
}

class TileState extends State<Tile>{
  late bool onTile;

  @override
  void initState() {
    super.initState();
    widget.rhs.mCoordinates.addListener(_updateOnTile);
    _updateOnTile(); // Initialize onTile state
  }

  @override
  void dispose() {
    widget.rhs.mCoordinates.removeListener(_updateOnTile);
    super.dispose();
  }

  void _updateOnTile() {
    setState(() {
      onTile = widget.tileCoords.mX == widget.rhs.mCoordinates.value.mX &&
               widget.tileCoords.mY == widget.rhs.mCoordinates.value.mY;
    });
  }  
  @override
  Widget build(BuildContext context){
    return Container(
        height: 50, 
        width: 50,
        decoration: BoxDecoration( 
          border: Border.all( 
            width:2, 
            color: Color(0xff000000), 
          ),
        ),
        child: Text(onTile ? "R" : "", style : TextStyle(fontSize: 40)),
    );
  }
} 


class Btn extends StatefulWidget {
  final String mType;
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
  late String mType;
  late RobotHomeState rhs;

  @override
  void initState() {
    super.initState();
    mType = widget.mType;
    rhs = widget.rhs;
  }

void toggleState() {
  setState(() {
    int currentX = widget.rhs.mCoordinates.value.mX;
    int currentY = widget.rhs.mCoordinates.value.mY;

    if (mType == 'DOWN' && currentX < 4) {
      widget.rhs.mCoordinates.value = Coordinate(mX: currentX + 1, mY: currentY);
    }
    if (mType == 'UP' && currentX > 0) {
      widget.rhs.mCoordinates.value = Coordinate(mX: currentX - 1, mY: currentY);
    }
    if (mType == 'LEFT' && currentY > 0) {
      widget.rhs.mCoordinates.value = Coordinate(mX: currentX, mY: currentY - 1);
    }
    if (mType == 'RIGHT' && currentY < 4) {
      widget.rhs.mCoordinates.value = Coordinate(mX: currentX, mY: currentY + 1);
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
