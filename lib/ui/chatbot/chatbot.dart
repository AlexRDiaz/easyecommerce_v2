import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/chatbot/chatbot_provider.dart';

class ChatbotFloatingWidget extends StatefulWidget {
  @override
  _ChatbotFloatingWidgetState createState() => _ChatbotFloatingWidgetState();
}

class _ChatbotFloatingWidgetState extends State<ChatbotFloatingWidget> {
  bool _isChatbotOpen =
      false; // Estado para controlar si el chatbot está abierto
  double screenWidth = 0.0;
  double iconSize = 0.0;

  @override
  void initState() {
    super.initState();
    // Agregar mensaje por defecto al abrir el chatbot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatbotProvider =
          Provider.of<ChatbotProvider>(context, listen: false);
      chatbotProvider.sendMessage('¡Hola! ¿En qué puedo ayudarte hoy?',
          false); // Agregar mensaje por defecto
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    iconSize = screenWidth > 600 ? 70 : 25;
    final chatbotProvider = Provider.of<ChatbotProvider>(context);

    return Stack(
      children: [
        // Si el chatbot está abierto, añadimos un GestureDetector que cubrirá toda la pantalla
        if (_isChatbotOpen)
          GestureDetector(
            onTap: () {
              setState(() {
                _isChatbotOpen = false; // Cierra el chatbot al hacer clic fuera
              });
            },
            child: Container(
              color: Colors.transparent, // Permite que los toques se detecten
            ),
          ),

        // El widget del chatbot flotante
        Align(
          alignment:
              Alignment.bottomRight, // Alineación del chatbot en la esquina
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isChatbotOpen = !_isChatbotOpen; // Abre o cierra el chatbot
              });
            },
            child: _isChatbotOpen
                ? _buildChatbotUI(
                    chatbotProvider) // Construye el UI del chatbot
                : _buildChatbotIcon(), // Muestra solo el icono
          ),
        ),
      ],
    );
  }

  // Función para construir solo el icono del chatbot
  Widget _buildChatbotIcon() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.blue,
        child: Image.asset(
          images.bot,
          width: iconSize * 0.3,
          height: iconSize * 0.3,
        ),
      ),
    );
  }

  // Función para construir la UI completa del chatbot
  Widget _buildChatbotUI(ChatbotProvider chatbotProvider) {
    return Container(
      margin: EdgeInsets.all(20), // Margen para separar el widget del borde
      width: 300,
      height: 400, // Tamaño ajustado del chatbot
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado del chatbot
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            images.bot,
                            width: iconSize * 0.3,
                            height: iconSize * 0.3,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "EasyBot",
                            style: TextStylesSystem().ralewayStyle(
                                18, FontWeight.w600, Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Cuerpo del chatbot
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorsSystem().colorSection),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        itemCount: chatbotProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatbotProvider.messages[index];
                          final isUserMessage = message['isUserMessage'];

                          return Align(
                            alignment: isUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              padding: const EdgeInsets.all(10.0),
                              constraints: const BoxConstraints(maxWidth: 200),
                              decoration: BoxDecoration(
                                color: isUserMessage
                                    ? Colors.grey[300]
                                    : Colors.blue[100],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(15),
                                  topRight: const Radius.circular(15),
                                  bottomLeft: isUserMessage
                                      ? const Radius.circular(15)
                                      : const Radius.circular(0),
                                  bottomRight: isUserMessage
                                      ? const Radius.circular(0)
                                      : const Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                message['message'],
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Campo de texto para enviar el mensaje
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Escribe tu mensaje...",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    onSubmitted: (text) {
                      // Enviar el mensaje al provider como mensaje del usuario
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        chatbotProvider.sendMessage(text, true);

                        // Llama al método chatbot con el mensaje ingresado
                        Connections().chatbot(text).then((response) {
                          // Maneja la respuesta del chatbot
                          chatbotProvider.sendMessage('${response["response"]}',
                              false); // Mensaje del bot
                        }).catchError((error) {
                          print('Error enviando el mensaje: $error');
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
