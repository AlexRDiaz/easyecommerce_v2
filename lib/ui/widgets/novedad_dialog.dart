import 'package:flutter/material.dart';

class NovedadDialog extends StatelessWidget {
  final String message;

  NovedadDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Registro de Novedad'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Text('Aceptar'),
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
          },
        ),
      ],
    );
  }
}
