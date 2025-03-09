// file_stuff_bloc.dart
// Barrett Koster
// This demos some basic file io in flutter.
// Uses BlocProvider for state.

import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:path_provider/path_provider.dart";
// cd to the project directory
// > flutter pub add path_provider

class BufState {
  String text = "empty so far";
  bool loaded = false;

  BufState(this.text, this.loaded);
}

class BufCubit extends Cubit<BufState> {
  BufCubit() : super(BufState("empty so far", false));

  void update(String s) {
    emit(BufState(s, true));
  }
}

void main() {
  runApp(FileStuff());
}

class FileStuff extends StatelessWidget {
  const FileStuff({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "file stuff - barrett",
      home: BlocProvider<BufCubit>(
        create: (context) => BufCubit(),
        child: BlocBuilder<BufCubit, BufState>(
          builder: (context, state) => FileStuff2(),
        ),
      ),
    );
  }
}

class FileStuff2 extends StatelessWidget {
  const FileStuff2({super.key});

  @override
  Widget build(BuildContext context) {
    BufCubit bc = BlocProvider.of<BufCubit>(context);
    BufState bs = bc.state;

    TextEditingController tec = TextEditingController();
    tec.text = bs.loaded ? bs.text : "not loaded yet";

    List<String> raw = [
      "apples",
      "bananas",
      "cherries",
      "donuts",
    ];
    List<Widget> groc = [];
    for (String s in raw) {
      groc.add(Text(s));
    }

    // Future<String> contents = readFile();
    // writeFile("hi there");
    return Scaffold(
      appBar: AppBar(title: Text("file stuff - barrett")),
      body: Column(
        children: [
          Container(
            height: 300,
            width: 400,
            decoration: BoxDecoration(border: Border.all(width: 1)),
            child: makeListView(),
          ),
          FloatingActionButton // loads from the file
              (
            onPressed: () async {
              String contents = await readFile();
              bc.update(contents);
            },
            child: Text("load", style: TextStyle(fontSize: 20)),
          ),
          bs.loaded ? Text(bs.text) : Text("not loaded yet"),
          Container(
            height: 50,
            width: 200,
            decoration: BoxDecoration(border: Border.all(width: 2)),
            child: TextField(controller: tec, style: TextStyle(fontSize: 20)),
          ),
          FloatingActionButton(
            onPressed: () {
              writeFile(tec.text);
            },
            child: Text("write", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  ListView makeListView() {
    List<Widget> kids = [];
    for (int i = 0; i < 16; i++) {
      kids.add(Text("hi there"));
    }

    ListView lv = ListView(
      scrollDirection: Axis.vertical,
      itemExtent: 30,
      children: kids,
    );

    return lv;
  }

  Future<String> whereAmI() async {
    Directory mainDir = await getApplicationDocumentsDirectory();
    String mainDirPath = mainDir.path;
    // String mainDirPath = "/Users/bkoster/Documents/courses/USC/368/shared";
    print("mainDirPath is $mainDirPath");
    return mainDirPath;
  }

  Future<String> readFile() async {
    await Future.delayed(const Duration(seconds: 2)); // adds drama
    String myStuff = await whereAmI();
    String filePath = "$myStuff/stuff.txt";
    File fodder = File(filePath);
    String contents = fodder.readAsStringSync();
    print("-------------in readFile ...");
    print(contents);
    return contents;
  }

  Future<void> writeFile(String writeMe) async {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/otherStuff.txt";
    File fodder = File(filePath);
    fodder.writeAsStringSync(writeMe);
  }
}
