import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';

void main() {
  runApp(const PageCreatorApp());
}

class PageCreatorApp extends StatelessWidget {
  const PageCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page Creator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CreatePageScreen(),
    );
  }
}

class CreatePageScreen extends StatefulWidget {
  const CreatePageScreen({super.key});

  @override
  _CreatePageScreenState createState() => _CreatePageScreenState();
}

class _CreatePageScreenState extends State<CreatePageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _headingController = TextEditingController();
  final _contentController = TextEditingController();
  final _yearController = TextEditingController();
  final _authorController = TextEditingController();
  final Random _random = Random();
  String _saveLocation = '';
  List<String> _savedFiles = [];

  @override
  void initState() {
    super.initState();
    _yearController.text = DateTime.now().year.toString();
    _authorController.text = 'Default Author';
  }

  @override
  void dispose() {
    _pageIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _headingController.dispose();
    _contentController.dispose();
    _yearController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  String _generateRandomId(int length) {
    Iterable<int> _rndCharCodes(int count) {
      return Iterable.generate(
        count,
        (_) => _random.nextInt(26) + 65, // 65-90 for A-Z
      );
    }
    return String.fromCharCodes(_rndCharCodes(length));
  }

  Future<void> _listFiles(Directory dir) async {
    try {
      final files = await dir.list().toList();
      setState(() {
        _savedFiles = files
        .where((entity) => entity is File)
        .map((file) => file.path.split('/').last)
        .toList();
      });
    } catch (e) {
      debugPrint('Error listing files: $e');
    }
  }

  Future<void> _savePage() async {
    if (_formKey.currentState!.validate()) {
      final pageId = _pageIdController.text.isEmpty
      ? _generateRandomId(10)
      : _pageIdController.text;

      final attributes = {
        'template': 'page',
        'title': _titleController.text,
        'description': _descriptionController.text,
        'heading': _headingController.text,
        'content': _contentController.text,
        'year': _yearController.text,
        'author': _authorController.text,
      };

      try {
        final directory = await getApplicationDocumentsDirectory();
        final dataDir = Directory('${directory.path}/data');

        if (!await dataDir.exists()) {
          await dataDir.create(recursive: true);
        }

        for (final entry in attributes.entries) {
          final file = File('${dataDir.path}/$pageId-${entry.key}.txt');
          await file.writeAsString(entry.value);
        }

        setState(() {
          _saveLocation = dataDir.path;
        });

        await _listFiles(dataDir);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Page saved successfully in: ${dataDir.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        _pageIdController.clear();
        _titleController.clear();
        _descriptionController.clear();
        _headingController.clear();
        _contentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving page: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        debugPrint('Error saving files: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _pageIdController,
                decoration: const InputDecoration(
                  labelText: 'Page ID (leave empty to generate random)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _headingController,
                decoration: const InputDecoration(
                  labelText: 'Heading',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a heading';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Page',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              if (_saveLocation.isNotEmpty) ...[
                Text(
                  'Files saved in:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(_saveLocation),
                const SizedBox(height: 16),
                Text(
                  'Saved Files:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_savedFiles.isEmpty)
                  const Text('No files found')
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _savedFiles
                      .map((file) => Text('- $file'))
                      .toList(),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
