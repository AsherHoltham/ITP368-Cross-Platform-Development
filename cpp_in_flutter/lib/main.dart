import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:google_maps_flutter/google_maps_flutter.dart';

String mapKey = 'KEY';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MapPage());
  }
}

class MapState {
  int count;
  MapState({required this.count});
}

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapState(count: 0));
  void update() => emit(MapState(count: state.count + 1));
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Map Page')),
        body: BlocProvider(
          create: (context) => MapCubit(),
          child: MapView(),
        ));
  }
}

class MapView extends StatelessWidget {
  const MapView({super.key});
  @override
  Widget build(BuildContext context) {
    final LatLng googleplexLocation = LatLng(37.4220, -122.0841);
    return Scaffold(
        body: GoogleMap(
            initialCameraPosition: CameraPosition(target: googleplexLocation)));
  }
}
