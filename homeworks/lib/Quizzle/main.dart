import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

import "Game.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizzle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => GameBloc(),
        child: GameScreen(),
      ),
    );
  }
}
