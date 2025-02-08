import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterState {
  final int count;
  const CounterState(this.count);
}

class RowCounterCubit extends Cubit<CounterState> {
  RowCounterCubit() : super(const CounterState(0));

  void increment() => emit(CounterState(state.count + 1));
  void decrement()
  {
    if(state.count > 0)
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
  ColCounterCubit() : super(const CounterState(0));

  void increment() => emit(CounterState(state.count + 1));
  void decrement()
  {
    if(state.count > 0)
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

class SizedGridWidget extends StatelessWidget {
  const SizedGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SizedGridCubit, SizedGrid>(
      builder: (context, sizedGrid) {
        // Fallback to 1 if the value is less than or equal to 0.
        final int rows = sizedGrid.mRowCnt > 0 ? sizedGrid.mRowCnt : 1;
        final int cols = sizedGrid.mColCnt > 0 ? sizedGrid.mColCnt : 1;
        final int itemCount = rows * cols;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }
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

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            Expanded(
              child: const SizedGridWidget()
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    FloatingActionButton(
                      onPressed: () => context.read<RowCounterCubit>().increment(),
                      child: Text("Add a Row"),
                    ),
                    FloatingActionButton(
                      onPressed: () => context.read<RowCounterCubit>().decrement(),
                      child: Text("Remove a Row"),
                    ),
                                FloatingActionButton(
                      onPressed: () => context.read<ColCounterCubit>().increment(),
                      child: Text("Add a Column"),
                    ),
                    FloatingActionButton(
                      onPressed: () => context.read<ColCounterCubit>().decrement(),
                      child: Text("Remove a Column"),
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
