import 'package:flutter/material.dart';

getLoadingModal(context, barrier) {
  return showDialog(
    context: context,
    barrierDismissible:
        false, // No se puede cerrar haciendo clic fuera del diálogo
    builder: (context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20.0),
            Text("Cargando..."),
          ],
        ),
      );
    },
  );
}
