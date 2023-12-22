import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/connections/connections.dart';

class CreateIntegration extends StatefulWidget {
  const CreateIntegration({super.key});
  @override
  _CreateIntegrationState createState() => _CreateIntegrationState();
}

class _CreateIntegrationState extends State<CreateIntegration> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createIntegration() async {
    setState(() {
      isLoading = true;
    });
    // Lógica para crear la integración con los datos ingresados
    final String storeName = _storeNameController.text;
    final String description = _descriptionController.text;

    // Aquí puedes manejar la lógica para crear la integración con los datos ingresados
    // Por ejemplo, puedes enviar estos datos a través de una función o un método
    var res = await Connections().createIntegration(storeName, description);

    setState(() {
      isLoading = false;
    });
    dialogCrear(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Integración'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _storeNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la tienda',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                await _createIntegration();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.blue,
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 10, right: 10),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? SizedBox(
                          width: 20, // Ancho deseado para el indicador circular
                          height:
                              20, // Altura deseada para el indicador circular
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
                    isLoading ? "Cargando" : 'Registrarme ahora',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> dialogCrear(resDelivered) async {
    if (resDelivered == 0) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Token generado correctamente',
        desc: 'No comparta publicamente el token de acceso a la plataforma',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        descTextStyle: const TextStyle(color: Colors.green),
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    } else {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Error al generar el token",
        //  desc: 'Vuelve a intentarlo',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    }
  }
}
