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
      home: const PageListScreen(),
      routes: {
        '/create': (context) => const CreatePageScreen(),
        '/list': (context) => const PageListScreen(),
      },
    );
  }
}

class PageListScreen extends StatefulWidget {
  const PageListScreen({super.key});

  @override
  _PageListScreenState createState() => _PageListScreenState();
}

class _PageListScreenState extends State<PageListScreen> {
  List<String> _pageIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataDir = Directory('${directory.path}/data');

      if (await dataDir.exists()) {
        final files = await dataDir.list().toList();
        final pageIds = files
        .where((file) => file is File)
        .map((file) => file.path.split('/').last)
        .where((filename) => filename.contains('-'))
        .map((filename) => filename.split('-').first)
        .toSet()
        .toList();

        setState(() => _pageIds = pageIds);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pages: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePage(String pageId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataDir = Directory('${directory.path}/data');

      if (await dataDir.exists()) {
        final files = await dataDir.list().toList();
        for (final file in files.where((f) => f is File)) {
          if (file.path.split('/').last.startsWith('$pageId-')) {
            await File(file.path).delete();
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Page $pageId deleted successfully')),
        );

        _loadPages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting page: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pages List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _pageIds.isEmpty
            ? const Center(child: Text('No pages found'))
            : ListView.builder(
              itemCount: _pageIds.length,
              itemBuilder: (context, index) {
                final pageId = _pageIds[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text('Page ID: $pageId'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                EditPageScreen(pageId: pageId),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deletePage(pageId),
                          ),
                        ],
                      ),
                    ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Page'),
                onPressed: () => Navigator.pushNamed(context, '/create'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditPageScreen extends StatefulWidget {
  final String pageId;

  const EditPageScreen({super.key, required this.pageId});

  @override
  _EditPageScreenState createState() => _EditPageScreenState();
}

class _EditPageScreenState extends State<EditPageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _headingController = TextEditingController();
  final _contentController = TextEditingController();
  final _yearController = TextEditingController();
  final _authorController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  Future<void> _loadPageData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dataDir = Directory('${directory.path}/data');

      if (await dataDir.exists()) {
        final attributes = [
          'title',
          'description',
          'heading',
          'content',
          'year',
          'author'
        ];

        for (final attr in attributes) {
          final file = File('${dataDir.path}/${widget.pageId}-$attr.txt');
          if (await file.exists()) {
            final content = await file.readAsString();
            switch (attr) {
              case 'title':
                _titleController.text = content;
                break;
              case 'description':
                _descriptionController.text = content;
                break;
              case 'heading':
                _headingController.text = content;
                break;
              case 'content':
                _contentController.text = content;
                break;
              case 'year':
                _yearController.text = content;
                break;
              case 'author':
                _authorController.text = content;
                break;
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading page data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePage() async {
    if (_formKey.currentState!.validate()) {
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
          final file = File('${dataDir.path}/${widget.pageId}-${entry.key}.txt');
          await file.writeAsString(entry.value);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Page updated successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving page: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _headingController.dispose();
    _contentController.dispose();
    _yearController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Page ${widget.pageId}'),
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  'Save Changes',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
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
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/list'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Return to List',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
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
