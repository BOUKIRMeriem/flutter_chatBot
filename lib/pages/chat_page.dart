import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;
import 'package:mon_projet/pages/chat_history_page.dart';
import 'package:mon_projet/pages/home_page.dart';

class ChatPage extends StatefulWidget {
  final int userId;

  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 0;
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  late ChatUser currentUser;
  ChatUser geminiUser = ChatUser(id: "0", firstName: "");

  @override
  void initState() {
    super.initState();
    currentUser = ChatUser(id: widget.userId.toString(), firstName: "User");
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _saveConversation(messages); // Enregistrer la conversation avant de naviguer
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatHistoryPage(userId: widget.userId),
        ),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _saveConversation(List<ChatMessage> messages) async {
    final url = Uri.parse('http://192.168.1.104:8080/api/conversations');
    List<Map<String, String>> messageData = [];

    for (var i = 0; i < messages.length; i++) {
      if (messages[i].user.id == currentUser.id) {
        final question = messages[i].text;
        String response = '';

        // Cherche la réponse en avançant jusqu'à ce qu'on trouve un message de geminiUser
        for (var j = i + 1; j < messages.length; j++) {
          if (messages[j].user.id == geminiUser.id) {
            response = messages[j].text;
            print("Réponse trouvée : $response"); // Journaliser la réponse trouvée
            break; // On sort dès qu'on trouve la première réponse
          }
        }

        // Enregistre uniquement si la question et la réponse existent
        if (question.isNotEmpty && response.trim().isNotEmpty) {
          messageData.add({
            'question': question,
            'response': response,
          });
        } else {
          print("Question ou réponse vide : question='$question', response='$response'");
        }
      }
    }

    if (messageData.isNotEmpty) {
      print("Données à envoyer : ${jsonEncode({'user': {'id': widget.userId}, 'messages': messageData})}");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': {'id': widget.userId},
          'messages': messageData,
        }),
      );

      if (response.statusCode != 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de l\'enregistrement de la conversation')),
        );
      } else {
        // Efface les messages uniquement après un succès
        setState(() {
          messages.clear();
        });
      }
    } else {
      print("Aucune donnée à envoyer car messageData est vide.");
    }
  }

  void _startNewChat() {
    _saveConversation(messages); // Enregistrer la conversation avant de commencer une nouvelle
    setState(() {
      messages.clear(); // Effacer les messages pour une nouvelle conversation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF191970),
        title: const Text("Chat Bot", style: TextStyle(color: Colors.white)),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _startNewChat, // Enregistrer et commencer une nouvelle conversation
            ),
          IconButton(
            icon: Image.asset('assets/log.png'),
            onPressed: () async {
              _saveConversation(messages); // Enregistrer la conversation avant de se déconnecter
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: _buildUI(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique de chat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF191970),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
      messageOptions: MessageOptions(
        avatarBuilder: (ChatUser user, Function? onPress, Function? onLongPress) {
          return SizedBox.shrink();
        },
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }
      gemini.streamGenerateContent(
        question,
        images: images,
      ).listen((event) {
        String response = event.content?.parts?.fold("", (previous, current) => "$previous ${current.text}") ?? "";

        print("Réponse du modèle : $response"); // Vérifiez ici si la réponse est bien capturée

        if (response.trim().isNotEmpty) {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );

          setState(() {
            messages = [message, ...messages];
          });
        } else {
          print("Aucune réponse reçue pour la question : $question");
        }
      });
    } catch (e) {
      print("Erreur lors de l'envoi du message : $e");
    }
  }
}
