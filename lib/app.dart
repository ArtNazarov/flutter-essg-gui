import 'package:flutter/material.dart';
import 'package:page_creator/screens/page_list_screen.dart';
import 'package:page_creator/screens/create_page_screen.dart';

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
