import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/login/controllers/controllers.dart';
import 'package:frontend/ui/logistic/add_sellers/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/loading_button.dart';
import 'package:frontend/ui/widgets/menu_categories.dart';
import 'package:frontend/ui/widgets/terms_conditions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginControllers _controllers = LoginControllers();
  AddSellersControllers _controllers2 = AddSellersControllers();
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNodeSubmitButton = FocusNode();

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  bool obscureC = true;
  bool ischecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            _buildWaveBackground(1200, 2000, Alignment.bottomRight, 125),
            _buildWaveBackground(2000, 1200, Alignment.bottomRight, -55),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView(
                  child: responsive(
                      Column(
                        children: [
                          _logo(),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              padding:
                                  EdgeInsets.all(20.0), // Espaciado interno
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(
                                    194, 199, 204, 0.973), // Color de fondo
                                border: Border.all(
                                  color: ColorsSystem()
                                      .colorBlack
                                      .withOpacity(0.3), // Color del borde
                                  width: 1.5, // Ancho del borde
                                ),
                                borderRadius: BorderRadius.circular(
                                    12.0), // Radio de borde
                              ),
                              child: _content()),
                        ],
                      ),
                      Column(
                        children: [
                          _logo(),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.82,
                            padding: EdgeInsets.all(20.0), // Espaciado interno
                            // decoration: BoxDecoration(
                            //   color: Color.fromRGBO(
                            //       194, 199, 204, 0.973), // Color de fondo
                            //   border: Border.all(
                            //     color: ColorsSystem()
                            //         .colorBlack, // Color del borde
                            //     width: 1.0, // Ancho del borde
                            //   ),
                            //   borderRadius:
                            //       BorderRadius.circular(12.0), // Radio de borde
                            // ),
                            child: _content(),
                          ),
                        ],
                      ),
                      context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveBackground(height, width, aligment, angle) {
    return Align(
      alignment: aligment,
      child: Transform.rotate(
        angle: angle * (3.14159265359 / 180), // Convierte 65 grados a radianes
        child: ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: height, // Ajusta la altura de la ola según tus necesidades
            width: width, // Ajusta el ancho de la ola según tus necesidades
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 18, 151, 168).withOpacity(0.6),
                  const Color.fromARGB(255, 33, 175, 218).withOpacity(0.4)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column _content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Bienvenido, ingresa con correo y contraseña",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        responsive(
          //"web,
          Column(
            children: [
              _modelTextField(
                text: "@Email",
                obscure: false,
                email: true,
                controller: _controllers.controllerMail,
                focusNode: _focusNode1,
                nextFocusNode: _focusNode2,
              ),
              const SizedBox(
                height: 20,
              ),
              _modelTextField(
                text: "Contraseña",
                obscure: obscureC,
                email: false,
                controller: _controllers.controllerPassword,
                focusNode: _focusNode2,
                onFieldSubmitted: () {
                  FocusScope.of(context).requestFocus(_focusNodeSubmitButton);
                },
              ),
            ],
          ),
          //  mobile,
          Column(
            children: [
              _modelTextFieldMob(
                text: "@Email",
                obscure: false,
                email: true,
                controller: _controllers.controllerMail,
                focusNode: _focusNode1,
                nextFocusNode: _focusNode2,
              ),
              const SizedBox(
                height: 20,
              ),
              _modelTextFieldMob(
                text: "Contraseña",
                obscure: obscureC,
                email: false,
                controller: _controllers.controllerPassword,
                focusNode: _focusNode2,
                onFieldSubmitted: () {
                  FocusScope.of(context).requestFocus(_focusNodeSubmitButton);
                },
              ),
            ],
          ),
          context,
        ),
        const SizedBox(
          height: 30,
        ),
        Column(
          children: [
            LoadingButton(
              function: submit,
              colorPrimary: const Color.fromRGBO(0, 200, 83, 1),
              colorSecundary: Colors.white,
              focusNode: _focusNodeSubmitButton,
            ),
            // ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.all(16.0),
            //       backgroundColor: Colors.greenAccent[700],
            //       minimumSize: const Size(460, 50),
            //       shape: RoundedRectangleBorder(
            //         borderRadius:
            //             BorderRadius.circular(10.0), // Bordes redondeados
            //       ),
            //       elevation: 5,
            //       shadowColor: Colors.greenAccent[400],
            //     ),
            //     onPressed: () async {
            //       await submit();
            //     },
            //     child: const Text(
            //       "INGRESAR",
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 16,
            //       ),
            //     )),

            const SizedBox(
              height: 30,
            ),
            const Text(
              "EASYECOMMERCE - Copyright © 2023.  v.3.1.7",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> submit() async {
    getLoadingModal(context, false);
    Navigator.pop(context);

    await _controllers.login(success: () async {
      var user_id = sharedPrefs!.getString('id') ?? "";
      var acceptedTC = await _controllers2.verifyUserTC(user_id);

      // print(acceptedTC);
      if (acceptedTC == 'false') {
        await showTermsAndConditionsDialog(context, user_id);
      } else {
        redirectToCorrectView(context);
      }
    }, error: (String error) {
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: '$error',
        desc: 'Vuelve a intentarlo',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: colors.colorGreen,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
    });
  }

  Column _logo() {
    return Column(
      children: [
        Image.asset(
          images.logoEasyEcommercce,
          width: MediaQuery.of(context).size.width * 0.25,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _modelTextField({
    text,
    obscure,
    email,
    controller,
    focusNode,
    nextFocusNode,
    VoidCallback? onFieldSubmitted,
  }) {
    return Container(
      width: 450,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: (value) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
          onFieldSubmitted
              ?.call(); // Llama a la función personalizada si está definida
        },
        obscureText: obscure,
        keyboardType:
            email ? TextInputType.emailAddress : TextInputType.visiblePassword,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
            hintText: text,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
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
        // onSubmitted: (value) {
        //   // Cuando se presiona Enter en este campo
        //   if (nextFocusNode != null) {
        //     // Mueve el foco al siguiente campo si está definido
        //     FocusScope.of(context).requestFocus(nextFocusNode);
        //   }
        // },
      ),
    );
  }

  _modelTextFieldMob({
    text,
    obscure,
    email,
    controller,
    focusNode,
    nextFocusNode,
    VoidCallback? onFieldSubmitted,
  }) {
    return Container(
      width: 450,
      height: 50,
      // decoration: BoxDecoration(
      //   border: Border.all(width: 1, color: Colors.grey),
      //   borderRadius: BorderRadius.circular(10.0),
      //   color: const Color.fromARGB(255, 245, 244, 244),
      // ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: (value) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
          onFieldSubmitted
              ?.call(); // Llama a la función personalizada si está definida
        },
        obscureText: obscure,
        keyboardType:
            email ? TextInputType.emailAddress : TextInputType.visiblePassword,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        decoration: InputDecoration(
            hintText: text,
            // enabledBorder: OutlineInputBorder(
            //   borderSide: const BorderSide(
            //       width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            //   borderRadius: BorderRadius.circular(10.0),
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: const BorderSide(
            //       width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            //   borderRadius: BorderRadius.circular(10.0),
            // ),
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
        // onSubmitted: (value) {
        //   // Cuando se presiona Enter en este campo
        //   if (nextFocusNode != null) {
        //     // Mueve el foco al siguiente campo si está definido
        //     FocusScope.of(context).requestFocus(nextFocusNode);
        //   }
        // },
      ),
    );
  }

  Future<void> redirectToCorrectView(context) async {
    if (sharedPrefs!.getString('role') == "LOGISTICA") {
      Navigators().pushNamedAndRemoveUntil(context, '/layout/logistic');
    }
    if (sharedPrefs!.getString('role') == "VENDEDOR") {
      Navigators().pushNamedAndRemoveUntil(context, '/layout/sellers');
    }

    if (sharedPrefs!.getString('role') == "TRANSPORTADOR") {
      Navigators().pushNamedAndRemoveUntil(context, '/layout/transport');
    }
    if (sharedPrefs!.getString('role') == "OPERADOR") {
      Navigators().pushNamedAndRemoveUntil(context, '/layout/operator');
    }
    if (sharedPrefs!.getString('role') == "PROVEEDOR") {
      Navigators().pushNamedAndRemoveUntil(context, '/layout/provider');
    }
  }

  Future<void> showTermsAndConditionsDialog(context, String userId) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Términos y Condiciones"),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Al marcar esta casilla, afirmo que he leído y acepto estar sujeto a los Términos y Condiciones de Easy Ecommerce",
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Checkbox(
                    value: ischecked,
                    onChanged: (value) {
                      setState(() {
                        ischecked = value!;
                      });
                      Navigator.pop(context);
                      showTermsAndConditionsDialog(context, userId);
                    },
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TermsConditions(),
                          ),
                        );
                      },
                      child: const Text(
                        "Acepto los términos y condiciones",
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (ischecked) {
                    await _controllers2.updateUserTC(userId, true);
                    Navigator.of(context).pop();
                    redirectToCorrectView(context);
                  }
                },
                child: const Text("Continuar"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - 100); // Ajusta la altura de la ola
    final firstControlPoint = Offset(size.width / 3, size.height);
    final firstEndPoint = Offset(
        size.width / 2.25, size.height - 80); // Ajusta la forma de la ola
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    final secondControlPoint = Offset(size.width - (size.width / 3),
        size.height - 120); // Ajusta la forma de la ola
    final secondEndPoint =
        Offset(size.width, size.height - 100); // Ajusta la forma de la ola
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
