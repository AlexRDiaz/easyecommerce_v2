// Método para construir un TextFormField con un estilo común
import 'package:flutter/material.dart';

Widget buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  required String hintText,
  required IconData prefixIcon,
  required String validationMessage,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (value!.isEmpty) {
          return validationMessage;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: Color.fromARGB(255, 23, 0, 168), // Color del ícono
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700], // Color del texto de sugerencia
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.black87, // Color del texto de etiqueta
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto', // Fuente de la etiqueta
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 190, 218, 241), // Color del borde
            width: 1.5, // Grosor del borde
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Color.fromARGB(
                255, 8, 82, 142), // Color del borde cuando está enfocado
            width: 2, // Grosor del borde cuando está enfocado
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.black
                .withOpacity(0.3), // Color del borde cuando está habilitado
            width: 1, // Grosor del borde cuando está habilitado
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.red, // Color del borde cuando hay un error
            width: 2, // Grosor del borde cuando hay un error
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors
                .red, // Color del borde cuando hay un error y está enfocado
            width: 2, // Grosor del borde cuando hay un error y está enfocado
          ),
        ),
      ),
    ),
  );
}
