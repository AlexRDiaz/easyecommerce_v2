import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/provider/update_password/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import '../../widgets/show_error_snackbar.dart';

class UpdatePasswordProviders extends StatefulWidget {
  const UpdatePasswordProviders({super.key});

  @override
  State<UpdatePasswordProviders> createState() => _UpdatePasswordProvidersState();
}

class _UpdatePasswordProvidersState extends State<UpdatePasswordProviders> {
  PasswordProvidersControllers _controllers = PasswordProvidersControllers();
  bool obscureC = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: _content(),
            ),
          ),
        )));
  }

  Column _content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 20,
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/layout/provider');
          },
          icon: Icon(Icons.home), // Icono de Home
          iconSize: 30, // Tamaño del icono
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          "Actualizar tu contraseña!!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Divider(),
        Column(
          children: [
            SizedBox(
              height: 20,
            ),
            // _modelTextField(
            //     text: "@Email", controller: _controllers.controllerMail),
            Text(
              sharedPrefs!.getString("email").toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: 20,
            ),
            _modelTextField(
                text: "Contraseña", controller: _controllers.password),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.colorRedPassword,
                  minimumSize: Size(150, 40),
                ),
                onPressed: () async {
                  try {
                    getLoadingModal(context, false);
                    await _controllers.updatePassword(success: () {
                      Navigator.pop(context);
                      setState(() {
                        _controllers.password.clear();
                      });
                      AwesomeDialog(
                        width: 500,
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.rightSlide,
                        title: 'Completado',
                        desc: '',
                        btnCancel: Container(),
                        btnOkText: "Aceptar",
                        btnOkColor: colors.colorGreen,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {},
                      ).show();
                    }, error: () {
                      Navigator.pop(context);
                      AwesomeDialog(
                        width: 500,
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: 'Vuelve a intentarlo',
                        btnCancel: Container(),
                        btnOkText: "Aceptar",
                        btnOkColor: colors.colorGreen,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {},
                      ).show();
                    });
                  } catch (e) {
                    Navigator.pop(context);
                    SnackBarHelper.showErrorSnackBar(
                        context, "Ha ocurrido un error de conexión");
                  }
                },
                child: Text(
                  "ACTUALIZAR",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )),
            SizedBox(
              height: 50,
            ),
          ],
        )
      ],
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          Text(
            "Contraseña: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (value) {
                setState(() {});
              },
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: text,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusColor: Colors.black,
                iconColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
