// routes3.dart
// Barrett Koster
// demo of Routing/Navigation
// this one does the routing with GENERATED routes.
// The Router class handles what was previously
// in the "routes:" section of the MaterialApp,
// which is replaced with "onGenerateRoute: routy.getRoute,"
// where routy is the instance of the Router class we
// make in the top Widget to get it started,
// and getRoute() is the function that generates the specified
// route.  The function takes a parameter whose ".name"
// property contains the nameString you give it when you call
// "Navigator .... pushNamed(nameString)", and it returns a
// MaterialPageApp just like the routes2.dart version.
// As for providing the CounterCubit, routy is now the
// provider of the cubit.  It makes a cubit when it is created,
// and we insert the BlocProvider.value layer just after each
// MaterialPageApp and before we call the RouteX(), just
// like routes2.dart.  THe one difference there is that ...
// we lose the auto-delete of BlocProvider, so we have to add
// cc.close() in a dispose() method at the bottom of Router.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(RoutesDemo());
}

// A simple text style used across pages.
TextStyle ts = const TextStyle(fontSize: 30);

// --- Counter State and Cubit ---

class CounterState {
  final int count;
  CounterState(this.count);
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(0));

  void inc() => emit(CounterState(state.count + 1));
}

// --- RouterApp: Generates routes based on settings ---

class RouterApp {
  final CounterCubit cc;
  RouterApp({required this.cc});

  Route genRoute(RouteSettings settings) {
    if (settings.name == "/" || settings.name == null) {
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cc,
          child: const Route1(),
        ),
      );
    } else if (settings.name == "p2") {
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cc,
          child: const Route2(),
        ),
      );
    } else if (settings.name == "p3") {
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cc,
          child: const Route3(),
        ),
      );
    } else {
      // Fallback to Route1 if an unknown route is requested.
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cc,
          child: const Route1(),
        ),
      );
    }
  }
}

// --- Top-Level Widget: Provides a single CounterCubit to all routes ---

class RoutesDemo extends StatelessWidget {
  RoutesDemo({super.key});

  // Create one instance of CounterCubit
  final CounterCubit cc = CounterCubit();

  // Create the router, passing the same cubit.
  late final RouterApp router = RouterApp(cc: cc);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routes Demo',
      // onGenerateRoute uses our custom RouterApp.
      onGenerateRoute: router.genRoute,
      // Start at Route1. (You can also use initialRoute: "/")
      home: BlocProvider.value(
        value: cc,
        child: const Route1(),
      ),
    );
  }
}

// --- Page 1 ---

class Route1 extends StatelessWidget {
  const Route1({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain the cubit instance from the context.
    final cc = BlocProvider.of<CounterCubit>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Route 1", style: ts)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Page 1", style: ts),
            // Using BlocBuilder to rebuild when the counter changes.
            BlocBuilder<CounterCubit, CounterState>(
              builder: (context, state) {
                return Text("${state.count}", style: ts);
              },
            ),
            ElevatedButton(
              onPressed: cc.inc,
              child: Text("Add 1", style: ts),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("p2");
              },
              child: Text("Go to Page 2", style: ts),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("p3");
              },
              child: Text("Go to Page 3", style: ts),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Page 2 ---

class Route2 extends StatelessWidget {
  const Route2({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = BlocProvider.of<CounterCubit>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Route 2", style: ts)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Page 2", style: ts),
            BlocBuilder<CounterCubit, CounterState>(
              builder: (context, state) {
                return Text("${state.count}", style: ts);
              },
            ),
            ElevatedButton(
              onPressed: cc.inc,
              child: Text("Add 1", style: ts),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Go back", style: ts),
            ),
            // Instead of pushing a new page, replace the current one.
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed("p3");
              },
              child: Text("Go to Page 3", style: ts),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Page 3 ---

class Route3 extends StatelessWidget {
  const Route3({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = BlocProvider.of<CounterCubit>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Route 3", style: ts)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Page 3", style: ts),
            BlocBuilder<CounterCubit, CounterState>(
              builder: (context, state) {
                return Text("${state.count}", style: ts);
              },
            ),
            ElevatedButton(
              onPressed: cc.inc,
              child: Text("Add 1", style: ts),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Go back", style: ts),
            ),
            // Replace current page with Page 2.
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed("p2");
              },
              child: Text("Go to Page 2", style: ts),
            ),
          ],
        ),
      ),
    );
  }
}
