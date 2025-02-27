import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Input Demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String tripTitle = "";
  String tripDescription = "";

  // This method opens a custom dialog using showGeneralDialog.
  void _openTripDialog() async {
    final result = await showGeneralDialog(
      context: context,
      barrierDismissible: true, // Allows dismissal by tapping outside.
      barrierLabel: "Trip Input",
      barrierColor: Colors.black.withOpacity(0.5), // Dims the background.
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TripDialog(),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        // Use a scale transition to create the "expanding" effect.
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );

    // If data is returned from the dialog, update the state.
    if (result != null) {
      setState(() {
        tripTitle = 'conf';
        tripDescription = 'conf';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trip Input Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button that triggers the custom dialog.
            ElevatedButton(
              onPressed: _openTripDialog,
              child: Text("Add Trip"),
            ),
            // Display the entered trip details if available.
            if (tripTitle.isNotEmpty && tripDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Trip Title: $tripTitle",
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text("Trip Description: $tripDescription",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// A stateful widget representing the dialog content.
class TripDialog extends StatefulWidget {
  const TripDialog({super.key});

  @override
  _TripDialogState createState() => _TripDialogState();
}

class _TripDialogState extends State<TripDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Wraps content vertically.
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(labelText: 'Trip Title'),
        ),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(labelText: 'Trip Description'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Return the entered data and close the dialog.
            Navigator.of(context).pop({
              'title': _titleController.text,
              'description': _descriptionController.text,
            });
          },
          child: Text("Submit"),
        ),
      ],
    );
  }
}
