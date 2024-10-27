import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mon_projet/pages/login_page.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Fonction pour envoyer la requête POST vers l'API Spring Boot
  Future<void> _registerUser(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // Vérification des mots de passe
    if (password != confirmPassword) {
      _showErrorDialog(context, "Le mot de passe ne correspondent pas !");
      _clearFields(); // Vider les champs
      return;
    }

    final url = Uri.parse('http://192.168.1.104:8080/api/auth/register');

    // Le body de la requête
    final Map<String, String> requestBody = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Inscription réussie : afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Inscription réussie ! "),
            backgroundColor: Colors.green,
          ),
        );

        // Redirection vers la page de login après un délai de 2 secondes
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      } else if (response.statusCode == 400) {
        // Gestion des erreurs spécifiques, par exemple : utilisateur déjà existant
        final errorData = jsonDecode(response.body);
        _showErrorDialog(context, errorData['error']);
        _clearFields(); // Vider les champs
      } else {
        // Autres erreurs
        final errorData = jsonDecode(response.body);
        _showErrorDialog(context, errorData['error']);
        _clearFields(); // Vider les champs
      }
    } catch (e) {
      _showErrorDialog(context, "Une erreur est survenue : $e");
      _clearFields(); // Vider les champs
    }
  }

  // Fonction pour afficher une boîte de dialogue d'erreur
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Erreur"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // Fonction pour vider les champs de texte
  void _clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBFCFC),
      appBar: AppBar(
        backgroundColor: Color(0xFFFBFCFC),
        elevation: 0,
      ),
      body: SingleChildScrollView( // Ajout du SingleChildScrollView pour gérer le défilement
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "S'inscrire",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191970),
                ),
              ),
              SizedBox(height: 32),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Nom d'utilisateur",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF191970),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    _registerUser(context);
                  },
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous avez déjà un compte ?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'se connecter',
                      style: TextStyle(
                        color: Color(0xFF191970),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
