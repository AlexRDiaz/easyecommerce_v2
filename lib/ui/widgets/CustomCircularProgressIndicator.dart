import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 6, // Grosor de la línea
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.blue, // Color de la animación
        ),
        // Puedes agregar más propiedades de estilo aquí
      ),
    );
  }
}
