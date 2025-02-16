/*
Groceries

lab for ITP368

Make a Flutter app that holds a grocery list.  

You should be able to
-- load the existing list
-- add to it
-- save it (so you can load it later)

If you stop and re-run the program, it should have the saved list.

Submit via BrightSpace and your GitHub.

Asher Holtham
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

/// The main App widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        // Provide the GroceryCubit to the widget tree.
        create: (_) => GroceryCubit(),
        child: GroceryListPage(),
      ),
    );
  }
}

/// Cubit that manages the list of grocery items.
/// The state is simply a [List<String>].
class GroceryCubit extends Cubit<List<String>> {
  GroceryCubit() : super([]) {
    _loadList();
  }

  /// Loads the grocery list from persistent storage.
  Future<void> _loadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('groceryList') ?? [];
    emit(list);
  }

  /// Adds a new item to the grocery list and saves it.
  Future<void> addItem(String item) async {
    final updatedList = List<String>.from(state)..add(item);
    emit(updatedList);
    await _saveList();
  }

  /// Saves the current grocery list to persistent storage.
  Future<void> _saveList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('groceryList', state);
  }
}

/// The main page displaying the grocery list.
class GroceryListPage extends StatefulWidget {
  @override
  _GroceryListPageState createState() => _GroceryListPageState();
}

class _GroceryListPageState extends State<GroceryListPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List'),
      ),
      body: Column(
        children: [
          // Display the list of grocery items.
          Expanded(
            child: BlocBuilder<GroceryCubit, List<String>>(
              builder: (context, groceryList) {
                return ListView.builder(
                  itemCount: groceryList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(groceryList[index]),
                    );
                  },
                );
              },
            ),
          ),
          // Input field and button to add new items.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Text field to input new grocery item.
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'New item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Button to add the item.
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final itemText = _controller.text.trim();
                    if (itemText.isNotEmpty) {
                      // Add the new item via the Cubit.
                      context.read<GroceryCubit>().addItem(itemText);
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}