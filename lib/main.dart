import 'package:flutter/material.dart';

import 'pages/home/home.dart';

void main() {
  runApp(const MSF());
}

class MSF extends StatelessWidget {
  const MSF({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Must Stay Focused',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(),
    );
  }
}
