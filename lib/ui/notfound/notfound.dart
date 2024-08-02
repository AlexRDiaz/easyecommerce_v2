import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

class NoAccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Fondo azul claro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de error
            Icon(
              Icons.error_outline,
              size: 100,
              color: ColorsSystem()
                  .colorPrincipalBrand, // Color rojo para el icono de error
            ),
            SizedBox(height: 20),
            // Mensaje de error
            Text(
              '¡Acceso Denegado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    ColorsSystem().colorPrincipalBrand, // Texto en azul oscuro
              ),
            ),
            SizedBox(height: 10),
            Text(
              'No tienes permisos para acceder a esta página.',
              style: TextStyle(
                fontSize: 16,
                color: ColorsSystem().colorPrincipalBrand, // Texto en azul
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
