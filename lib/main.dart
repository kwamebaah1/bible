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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final verses = await _dbHelper.getVerses();
    final books = verses.map((verse) => verse['book'] as String).toSet().toList();
    setState(() {
      _books = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return ListTile(
                  leading: const Icon(Icons.book, color: Colors.deepPurple),
                  title: Text(
                    book,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Navigate to the chapters screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChaptersScreen(book: book),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class ChaptersScreen extends StatefulWidget {
  final String book;

  const ChaptersScreen({super.key, required this.book});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<int> _chapters = [];

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final verses = await _dbHelper.getVerses();
    final chapters = verses
        .where((verse) => verse['book'] == widget.book)
        .map((verse) => verse['chapter'] as int)
        .toSet()
        .toList();
    setState(() {
      _chapters = chapters..sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book),
      ),
      body: _chapters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // Number of columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return Card(
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      // Navigate to the verses screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VersesScreen(
                            book: widget.book,
                            chapter: chapter,
                          ),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        chapter.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class VersesScreen extends StatefulWidget {
  final String book;
  final int chapter;

  const VersesScreen({super.key, required this.book, required this.chapter});

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _verses = [];

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    final verses = await _dbHelper.getVerses();
    final filteredVerses = verses
        .where((verse) =>
            verse['book'] == widget.book && verse['chapter'] == widget.chapter)
        .toList();
    setState(() {
      _verses = filteredVerses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book} ${widget.chapter}'),
      ),
      body: _verses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _verses.length,
              itemBuilder: (context, index) {
                final verse = _verses[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(
                      'Verse ${verse['verse']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      verse['text'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
