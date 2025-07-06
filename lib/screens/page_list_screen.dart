import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'edit_page_screen.dart';
import 'create_page_screen.dart';

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
            onPressed: () async {
              final newPageId = await Navigator.pushNamed(context, '/create');
              if (newPageId != null) {
                setState(() {
                  _pageIds.add(newPageId as String);
                  _pageIds = _pageIds.toSet().toList();
                });
              }
            },
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
                onPressed: () async {
                  final newPageId = await Navigator.pushNamed(context, '/create');
                  if (newPageId != null) {
                    setState(() {
                      _pageIds.add(newPageId as String);
                      _pageIds = _pageIds.toSet().toList();
                    });
                  }
                },
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
