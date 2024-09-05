import 'dart:io';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gemini_ai/drawer.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Gemini",
      profileImage:
          "https://cdn.vectorstock.com/i/500p/67/56/happy-robot-3d-ai-character-chat-bot-mascot-vector-51396756.jpg");
  List<ChatMessage> messages = [];
  bool isLoading = false;
  final Gemini gemini = Gemini.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Aapki Soch Hamare Samadhan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      drawer: CustomDrawer(onClearChat: permissionToClearChat),
      body: buildBodyUI(),
    );
  }

  Widget buildBodyUI() {
    return Stack(
      children: [
        DashChat(
          inputOptions: InputOptions(
            trailing: [
              IconButton(
                  onPressed: sendMediaMessage, icon: const Icon(Icons.image))
            ],
          ),
          currentUser: currentUser,
          onSend: sendMessages,
          messages: messages,
        ),
        if (isLoading)
          const SpinKitThreeBounce(
            color: Colors.black,
            size: 14,
          )
      ],
    );
  }

  void sendMessages(ChatMessage chatMessage) {
    FocusScope.of(context).unfocus();
    setState(() {
      messages = [chatMessage, ...messages];
      isLoading = true;
    });

    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
            isLoading = false;
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
              user: geminiUser, createdAt: DateTime.now(), text: response);
          setState(() {
            messages = [message, ...messages];
            isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  void sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Tell me something about this picture please?",
        medias: [
          ChatMedia(url: file!.path, fileName: "", type: MediaType.image)
        ]);
    sendMessages(chatMessage);
  }

  void permissionToClearChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Clear"),
          content: const Text("Are you sure you want to clear all messages?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                  messages.clear();
                });
              },
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );
  }
}
