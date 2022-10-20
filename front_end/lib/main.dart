import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/ui/pages/init_page/init_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Repo().localStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //final Widget initPage;
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greengrocery App V2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Init(),
    );
  }
}
