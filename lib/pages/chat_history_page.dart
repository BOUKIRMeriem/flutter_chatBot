import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mon_projet/pages/chat_page.dart';

class ChatHistoryPage extends StatefulWidget {
  final int userId;

  const ChatHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  int _selectedIndex = 1;
  List<dynamic> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
  }

  Future<void> _fetchChatHistory() async {
    final url = Uri.parse('http://192.168.1.104:8080/api/conversations/${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _conversations = jsonDecode(response.body);
        });
      } else {
        _showSnackBar('Erreur lors de la récupération de l\'historique');
      }
    } catch (e) {
      _showSnackBar('Erreur de connexion : $e');
    }
  }

  Future<void> _deleteConversation(int conversationId) async {
    final url = Uri.parse('http://192.168.1.104:8080/api/conversations/$conversationId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _conversations.removeWhere((conv) => conv['id'] == conversationId);
        });
        _showSnackBar('Conversation supprimée avec succès');
      } else {
        _showSnackBar('Erreur lors de la suppression de la conversation');
      }
    } catch (e) {
      _showSnackBar('Erreur de connexion : $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatPage(userId: widget.userId)),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        final messages = conversation['messages'] as List<dynamic>;
        final lastMessage = messages.isNotEmpty ? messages.last : null;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: Colors.grey[200],
          child: ListTile(
            title: Text(
              lastMessage?['question'] ?? 'Question inconnue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(lastMessage?['response'] ?? 'Réponse inconnue'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    _showDeleteConfirmationDialog(conversation['id']);
                  },
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ],
            ),
            onTap: () {
              // Navigate to the conversation details page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationDetailPage(conversation: conversation),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int conversationId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supprimer la conversation'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette conversation ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () {
                _deleteConversation(conversationId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF191970),
        title: const Text(
          "Historique de chat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _conversations.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _buildChatList(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique de chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF191970),
        onTap: _onItemTapped,
      ),
    );
  }
}

class ConversationDetailPage extends StatelessWidget {
  final dynamic conversation;

  const ConversationDetailPage({Key? key, required this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messages = conversation['messages'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Historique de chat",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF191970),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final question = message['question'] ?? 'Question inconnue';
          final response = message['response'] ?? 'Réponse inconnue';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: Color(0xFF6c3483 ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        question,
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        response,
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
