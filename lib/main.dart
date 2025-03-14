import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/database_helper.dart';
import 'services/bible_service.dart';
import 'screens/loading_screen.dart'; // Import the LoadingScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('bibleBox'); // Open a Hive box for storing data

  final dbHelper = DatabaseHelper();
  await dbHelper.initialize(); // Initialize the database

  bool isLoading = true;

  if (await dbHelper.isDatabaseEmpty()) {
    final bibleService = BibleService();

    // Show the loading screen while data is being inserted
    runApp(MaterialApp(
      home: LoadingScreen(),
      debugShowCheckedModeBanner: false,
    ));

    // Load and insert NIV data
    Map<String, dynamic> nivData = await bibleService.loadBible("niv");
    await bibleService.insertBibleData(nivData, "niv");

    // Load and insert KJV data
    Map<String, dynamic> kjvData = await bibleService.loadBible("kjv");
    await bibleService.insertBibleData(kjvData, "kjv");

    print("Data inserted successfully!");
  }

  isLoading = false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Bible App Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
