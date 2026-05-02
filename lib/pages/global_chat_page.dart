import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class GlobalChatPage extends StatefulWidget {
  const GlobalChatPage({super.key});

  @override
  State<GlobalChatPage> createState() => _GlobalChatPageState();
}

class _GlobalChatPageState extends State<GlobalChatPage> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final String baseUrl = "https://global-chat-backend-u1tk.onrender.com";
  List<dynamic> messages = [];
  VideoPlayerController? videoController;
  bool videoInitialized = false;

  @override
  void initState() {
    super.initState();
    initVideo();
    fetchMessages();
    startAutoRefresh();
  }

  void initVideo() async {
    try {
      videoController = VideoPlayerController.asset('assets/bgvid/3.mp4');
      await videoController!.initialize();
      videoController!.setLooping(true);
      videoController!.setVolume(0);
      videoController!.play();
      setState(() => videoInitialized = true);
    } catch (e) {
      debugPrint("Video init error: $e");
    }
  }

  void startAutoRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) fetchMessages();
      return mounted;
    });
  }

  Future<void> fetchMessages() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/messages"));
      if (res.statusCode == 200) {
        setState(() => messages = jsonDecode(res.body));
      } else {
        debugPrint("Failed to fetch messages: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Fetch messages error: $e");
    }
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;
    try {
      // Store all data in the message field as a JSON string
      final Map<String, dynamic> combinedData = {
        "title": titleController.text.trim(),
        "username": usernameController.text.trim(),
        "message": controller.text.trim(),
      };

      final res = await http.post(
        Uri.parse("$baseUrl/message"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": jsonEncode(combinedData)}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        titleController.clear();
        usernameController.clear();
        controller.clear();
        fetchMessages();
      } else {
        debugPrint("Send message failed: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Send message error: $e");
    }
  }

  Future<void> likeMessage(String messageId) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/message/$messageId/like"),
        headers: {"Content-Type": "application/json"},
      );
      if (res.statusCode == 200) {
        fetchMessages();
      } else {
        debugPrint("Like message failed: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Like message error: $e");
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    titleController.dispose();
    usernameController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          if (videoInitialized && videoController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController!.value.size.width,
                  height: videoController!.value.size.height,
                  child: VideoPlayer(videoController!),
                ),
              ),
            ),
          Container(color: Colors.black.withValues(alpha: 0.5)),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text("Global Chat"),
              ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    return MessageCard(
                      message: msg,
                      onLike: () {
                        final id = msg['id']?.toString() ?? '';
                        if (id.isNotEmpty) likeMessage(id);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black.withValues(alpha: 0.7),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Title...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Username...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Type message...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: sendMessage,
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final dynamic message;
  final VoidCallback onLike;

  const MessageCard({super.key, required this.message, required this.onLike});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String username = 'Anonymous';
    String content = message['message'] ?? '';
    final likes = message['likes'] ?? 0;

    // Try parsing the message as a JSON string to extract title and username
    try {
      final parsed = jsonDecode(content);
      if (parsed is Map) {
        title = parsed['title']?.toString() ?? '';
        username = parsed['username']?.toString() ?? 'Anonymous';
        content = parsed['message']?.toString() ?? '';
        if (username.trim().isEmpty) username = 'Anonymous';
      }
    } catch (_) {
      // Fallback if backend returned raw structure
      title = message['title'] ?? title;
      username = message['username'] ?? username;
      if (username.trim().isEmpty) username = 'Anonymous';
    }

    return Card(
      color: Colors.grey[900]?.withValues(alpha: 0.8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              username,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                Text('$likes', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
