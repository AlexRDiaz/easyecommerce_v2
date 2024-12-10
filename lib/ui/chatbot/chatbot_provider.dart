import 'package:flutter/material.dart';

class ChatbotProvider with ChangeNotifier {
  bool _showChatbot = false;
  // final List<String> _messages = []; // Lista para almacenar mensajes
  List<Map<String, dynamic>> _messages = [];

  bool get showChatbot => _showChatbot;
  // List<String> get messages => _messages; // Getter para acceder a los mensajes
  List<Map<String, dynamic>> get messages => _messages;
  void toggleChatbot(bool value) {
    _showChatbot = value;
    notifyListeners();
  }

  void checkUserRole(String role) {
    if (role == 'LOGISTICA') {
      toggleChatbot(true);
    } else {
      toggleChatbot(false);
    }
  }

  // void sendMessage(String message) {
  //   _messages.add(message); // Agregar el mensaje a la lista
  //   notifyListeners(); // Notificar a los oyentes
  // }
  void sendMessage(String message, bool isUserMessage) {
    _messages.add({'message': message, 'isUserMessage': isUserMessage});
    notifyListeners();
  }

  void _addDefaultMessage() {
    _messages.add({
      'message': '¡Hola! ¿En qué puedo ayudarte hoy?',
      'isUserMessage': false
    });
    notifyListeners(); // Notificar a los oyentes de cambios
  }
}
