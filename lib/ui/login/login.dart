import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/login/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginControllers _controllers = LoginControllers();
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
        _logo(),
        SizedBox(
          height: 20,
        ),
        Text(
          "Bienvenido, ingresa con correo y contraseña",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          children: [
            SizedBox(
              height: 20,
            ),
            _modelTextField(
                text: "@Email",
                obscure: false,
                email: true,
                controller: _controllers.controllerMail),
            SizedBox(
              height: 20,
            ),
            _modelTextField(
                text: "Contraseña",
                obscure: obscureC,
                email: false,
                controller: _controllers.controllerPassword),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.colorGreen,
                  minimumSize: Size(150, 40),
                ),
                onPressed: () async {
                  getLoadingModal(context, false);

                  await _controllers.login(success: () {
                    Navigator.pop(context);
                    if (sharedPrefs!.getString('role') == "LOGISTICA") {
                      Navigators()
                          .pushNamedAndRemoveUntil(context, '/layout/logistic');
                    }
                    if (sharedPrefs!.getString('role') == "VENDEDOR") {
                      Navigators()
                          .pushNamedAndRemoveUntil(context, '/layout/sellers');
                    }

                    if (sharedPrefs!.getString('role') == "TRANSPORTADOR") {
                      Navigators().pushNamedAndRemoveUntil(
                          context, '/layout/transport');
                    }
                    if (sharedPrefs!.getString('role') == "OPERADOR") {
                      Navigators()
                          .pushNamedAndRemoveUntil(context, '/layout/operator');
                    }
                  }, error: () {
                    Navigator.pop(context);

                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Credenciales Incorrectas',
                      desc: 'Vuelve a intentarlo',
                      btnCancel: Container(),
                      btnOkText: "Aceptar",
                      btnOkColor: colors.colorGreen,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                  });
                },
                child: Text(
                  "INGRESAR",
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

  Column _logo() {
    return Column(
      children: [
        Image.asset(
          images.logoEasyEcommercce,
          width: 150,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _modelTextField({text, obscure, email, controller}) {
    return Container(
      width: 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType:
            email ? TextInputType.emailAddress : TextInputType.visiblePassword,
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
            suffixIcon: email == false
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        obscureC = !obscureC;
                      });
                    },
                    child: Icon(
                      obscure ? Icons.remove_red_eye_outlined : Icons.password,
                      color: Colors.black,
                    ))
                : null),
      ),
    );
  }
}
