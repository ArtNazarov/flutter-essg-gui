import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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
