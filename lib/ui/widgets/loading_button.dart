import 'package:flutter/material.dart';
import 'package:frontend/config/textstyles.dart';

class LoadingButton extends StatefulWidget {
  final Function function;
  final Color colorPrimary;
  final Color colorSecundary;
  final FocusNode focusNode;
  final int responsiveValue;

  const LoadingButton(
      {super.key,
      required this.function,
      required this.colorSecundary,
      required this.colorPrimary,
      required this.focusNode,
      required this.responsiveValue});

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        focusNode: widget.focusNode,
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          await widget.function();
          setState(() {
            isLoading = false;
          });
        },
        style: ElevatedButton.styleFrom(
          primary: widget.colorPrimary,
          onPrimary: widget.colorSecundary,
          padding: const EdgeInsets.all(16.0),
          minimumSize: const Size(460, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // Bordes redondeados
          ),
          textStyle: const TextStyle(fontSize: 18),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? SizedBox(
                    width: 20, // Ancho deseado para el indicador circular
                    height: 20, // Altura deseada para el indicador circular
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth:
                          4, // Ancho de la línea del indicador circular
                      // Color del indicador circular
                    ),
                  )
                : Container(),
            const SizedBox(width: 8),
            Text(
              isLoading ? "Cargando" : 'Ingresar',
              style: TextStylesSystem().ralewayStyle(
                widget.responsiveValue == 1 ? 16 : 12,
                FontWeight.w500,
                Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
