import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterState {
  final int count;
  const CounterState(this.count);
}

class RowCounterCubit extends Cubit<CounterState> {
  RowCounterCubit() : super(const CounterState(1));

  void increment() => emit(CounterState(state.count + 1));
  void decrement()
  {
    if(state.count > 1)
    {
      emit(CounterState(state.count - 1));
    }
    else 
    {
      emit(CounterState(state.count));
    }
  }
}

class ColCounterCubit extends Cubit<CounterState> {
  ColCounterCubit() : super(const CounterState(1));

  void increment() => emit(CounterState(state.count + 1));
  void decrement()
  {
    if(state.count > 1)
    {
      emit(CounterState(state.count - 1));
    }
    else 
    {
      emit(CounterState(state.count));
    }
  }
}

class SizedGrid{
  final int mRowCnt;
  final int mColCnt;

  const SizedGrid(
    this.mRowCnt, 
    this.mColCnt
  );
}

class SizedGridCubit extends Cubit<SizedGrid>{
  SizedGridCubit() : super(SizedGrid(1, 1));

  void changeRows(int count) => emit(SizedGrid(count, state.mColCnt));
  void changeCols(int count) => emit(SizedGrid(state.mRowCnt, count));
}

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<RowCounterCubit>(create: (context) => RowCounterCubit()),
        BlocProvider<ColCounterCubit>(create: (context) => ColCounterCubit()),
        BlocProvider<SizedGridCubit>(create: (context) => SizedGridCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp (
      home: MyHomePage(title: 'Sized Grid Lab')
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {

    final int rowCount = context.watch<RowCounterCubit>().state.count;
    final int colCount = context.watch<ColCounterCubit>().state.count;

    context.read<SizedGridCubit>().changeRows(rowCount);
    context.read<SizedGridCubit>().changeCols(colCount);

    List<Widget> gridRows = [];
    for (int i = 0; i < rowCount; i++) {
      List<Widget> rowCells = [];
      for (int j = 0; j < colCount; j++) {
        rowCells.add(
          Icon(Icons.check_box_outline_blank, color: const Color.fromARGB(255, 193, 167, 165)), // Empty icon
        );
      }
      gridRows.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: rowCells));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            Column(children: gridRows), // Grid of bottles
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  FloatingActionButton(
                    onPressed: () => context.read<RowCounterCubit>().increment(),
                    child: 
                      Text("Add a Row",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(255, 30, 204, 186),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () => context.read<RowCounterCubit>().decrement(),
                      child: Text("Remove a Row",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(255, 30, 204, 186),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () => context.read<ColCounterCubit>().increment(),
                      child: Text("Add a Column",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(255, 30, 204, 186),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () => context.read<ColCounterCubit>().decrement(),
                      child: Text("Remove a Column",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(255, 30, 204, 186),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }


}
