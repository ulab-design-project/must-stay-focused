// File: lib/pages/home.dart
// Home Page with Placeholder Widgets

import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotes here'),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.store),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Placeholder(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Templates drop down'),
                    ),
                  ),
                ),
                Expanded(
                  child: Placeholder(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Sort By'),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Placeholder(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Task List'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
