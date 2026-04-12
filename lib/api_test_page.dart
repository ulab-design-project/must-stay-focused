import 'package:flutter/material.dart';
import 'data/services/user_service.dart';
import 'data/services/deck_service.dart';
import 'data/services/task_list_service.dart';

class ApiTestPage extends StatefulWidget
{
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage>
{
  final userService = UserService();
  final deckService = DeckService();
  final taskService = TaskListService();

  String output = "";

  void log(String msg)
  {
    setState(() => output = msg);
    print(msg);
  }

  Future<void> testUsers() async
  {
    final data = await userService.getUsers();
    log("Users: $data");
  }

  Future<void> testDecks() async
  {
    final data = await deckService.getAll();
    log("Decks: $data");
  }

  Future<void> testTasks() async
  {
    final data = await taskService.getAll();
    log("Tasks: $data");
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text("API Test")),
      body: Column(
        children:
        [
          ElevatedButton(onPressed: testUsers, child: const Text("Test Users")),
          ElevatedButton(onPressed: testDecks, child: const Text("Test Decks")),
          ElevatedButton(onPressed: testTasks, child: const Text("Test Tasks")),

          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              child: Text(output),
            ),
          )
        ],
      ),
    );
  }
}