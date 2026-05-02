import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GlobalChatPage extends StatefulWidget
{
    const GlobalChatPage({super.key});

    @override
    State<GlobalChatPage> createState() => _GlobalChatPageState();
}

class _GlobalChatPageState extends State<GlobalChatPage>
{
    final TextEditingController controller = TextEditingController();

    List messages = [];

    final String baseUrl = "https://global-chat-backend-u1tk.onrender.com";

    @override
    void initState()
    {
        super.initState();
        fetchMessages();

        // auto refresh every 3 seconds
        Future.doWhile(() async
        {
            await Future.delayed(const Duration(seconds: 3));
            fetchMessages();
            return mounted;
        });
    }

    Future<void> fetchMessages() async
    {
        try
        {
            final res = await http.get(Uri.parse("$baseUrl/messages"));

            if (res.statusCode == 200)
            {
                setState(()
                {
                    messages = jsonDecode(res.body);
                });
            }
        }
        catch (e)
        {
            // ignore for now
        }
    }

    Future<void> sendMessage() async
    {
        if (controller.text.trim().isEmpty) return;

        try
        {
            await http.post(
                Uri.parse("$baseUrl/message"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(
                {
                    "message": controller.text.trim()
                })
            );

            controller.clear();
            fetchMessages();
        }
        catch (e)
        {
            // ignore
        }
    }

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
                backgroundColor: Colors.black,
                title: const Text("Global Chat"),
            ),
            body: Column(
                children:
                [
                    Expanded(
                        child: ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index)
                            {
                                final msg = messages[messages.length - 1 - index];

                                return Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                        msg["message"] ?? "",
                                        style: const TextStyle(color: Colors.white),
                                    ),
                                );
                            },
                        ),
                    ),

                    Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.black,
                        child: Row(
                            children:
                            [
                                Expanded(
                                    child: TextField(
                                        controller: controller,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                            hintText: "Type message...",
                                            hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                    ),
                                ),

                                IconButton(
                                    onPressed: sendMessage,
                                    icon: const Icon(Icons.send, color: Colors.white),
                                )
                            ],
                        ),
                    )
                ],
            ),
        );
    }
}