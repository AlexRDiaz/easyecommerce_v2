import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Definir ancho dinámico basado en el tamaño de la pantalla
    double containerWidth = screenWidth * 0.22;

    // Asegurar un tamaño mínimo para que no se reduzca demasiado
    if (containerWidth < 400) {
      containerWidth = 400; // Tamaño mínimo para el contenedor
    }

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
                        _logo(0.22),
                        Container(
                          width: containerWidth, // Ajusta según la pantalla
                          padding:
                              const EdgeInsets.all(20.0), // Espaciado interno
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(222, 225, 226, 0.612),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: _content(1),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        _logo(0.82),
                        Container(
                          width: screenWidth * 0.82, // Para pantallas grandes
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(222, 225, 226, 0.612),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: _content(0),
                        ),
                      ],
                    ),
                    context,
                  ),
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

  void showEmailInputDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Restablecer Contraseña",
                  style: TextStylesSystem().ralewayStyle(
                    18,
                    FontWeight.w600,
                    ColorsSystem().colorStore,
                  ),
                ),
                const SizedBox(height: 10),
                // Subtitle
                Text(
                  "Ingresa tu email para recibir el link de restablecimiento de contraseña.",
                  style: TextStylesSystem().ralewayStyle(
                    14,
                    FontWeight.w500,
                    Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                // Email Input Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email Address",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey[500],
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                      },
                      child: Text(
                        "Cancelar",
                        style: TextStylesSystem().ralewayStyle(
                          14,
                          FontWeight.w500,
                          Colors.redAccent,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text;
                        if (email.isNotEmpty &&
                            RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                          print("Email entered: $email");

                          var responesendEmail =
                              await Connections().newsendEmail("", email);
                          print(responesendEmail);

                          Navigator.of(context).pop(); // Close the modal
                        } else {
                          print("Invalid email");
                          // You can add a visual error indicator here
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Aceptar",
                        style: TextStylesSystem().ralewayStyle(
                          14,
                          FontWeight.w500,
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Row customLabelRow(text, color, size, fontWeight, mainaxisalign) {
    return Row(
      mainAxisAlignment: mainaxisalign,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            text,
            style: TextStylesSystem().ralewayStyle(
              size, // Tamaño de la fuente
              fontWeight, // Peso de la fuente medio
              color, // Color del label
            ),
          ),
        )
      ],
    );
  }

  Row customLabelRowDual(String text, String text2, Color color, double size,
      FontWeight fontWeight, MainAxisAlignment mainAxisAlign) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            text,
            style: TextStylesSystem().ralewayStyle(
              size,
              fontWeight,
              color,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            showEmailInputDialog(context);
            // print("resetear contraseña");
            // Navigator.of(context).push(
            // MaterialPageRoute(
            // builder: (context) => TermsConditions(),
            // ),
            // );
          },
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              text2,
              style: TextStylesSystem().ralewayStyle(
                size,
                fontWeight,
                color,
              ),
            ),
          ),
        )
      ],
    );
  }

  Column _content(responsiveValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 5,
        ),
        customLabelRow(
            "Bienvenido!",
            ColorsSystem().colorStore,
            responsiveValue == 1 ? 14 : 12,
            FontWeight.w600,
            MainAxisAlignment.center),
        customLabelRow(
            "Ingrese sus credenciales",
            ColorsSystem().colorStore,
            responsiveValue == 1 ? 14 : 12,
            FontWeight.w500,
            MainAxisAlignment.center),
        SizedBox(
          height: responsiveValue == 1 ? 20 : 10,
        ),
        responsive(
          //"web,
          Column(
            children: [
              customLabelRow("Username", ColorsSystem().colorSection2, 14,
                  FontWeight.w600, MainAxisAlignment.start),
              _modelTextField(
                text: "@Email",
                obscure: false,
                email: true,
                controller: _controllers.controllerMail,
                focusNode: _focusNode1,
                nextFocusNode: _focusNode2,
              ),
              const SizedBox(
                height: 40,
              ),
              // customLabelRow("Password", ColorsSystem().colorSection2, 14,FontWeight.w600, MainAxisAlignment.start),
              customLabelRowDual(
                  "Password",
                  "Olvido su contraseña?",
                  ColorsSystem().colorSection2,
                  14,
                  FontWeight.w600,
                  MainAxisAlignment.start),
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
              customLabelRow("Username", ColorsSystem().colorSection2, 12,
                  FontWeight.w600, MainAxisAlignment.start),
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
              customLabelRowDual(
                  "Password",
                  "Olvido su contraseña?",
                  ColorsSystem().colorSection2,
                  12,
                  FontWeight.w600,
                  MainAxisAlignment.start),
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
              responsiveValue: responsiveValue,
              function: submit,
              colorPrimary: ColorsSystem().colorSelected,
              colorSecundary: Colors.white,
              focusNode: _focusNodeSubmitButton,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "EASYECOMMERCE - Copyright © 2023.  v.3.1.15",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorsSystem().colorStore,
                  fontSize: 12),
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

  Column _logo(width) {
    return Column(
      children: [
        Image.asset(
          images.logoEasyEcommercce,
          width: MediaQuery.of(context).size.width * width,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _modelTextField({
    required String text,
    required bool obscure,
    required bool email,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    VoidCallback? onFieldSubmitted,
  }) {
    return Container(
      width: 450,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: (value) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
          onFieldSubmitted?.call();
        },
        obscureText: obscure,
        keyboardType:
            email ? TextInputType.emailAddress : TextInputType.visiblePassword,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorsSystem().colorStore,
        ),
        decoration: InputDecoration(
          hintText: text,
          hintStyle: TextStyle(
            color: Color.fromRGBO(188, 191, 192, 0.612),
            fontWeight: FontWeight.normal,
          ),
          hoverColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: ColorsSystem().colorSection),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: ColorsSystem().colorSelected),
            borderRadius: BorderRadius.circular(10.0),
          ),
          fillColor: Colors.white,
          filled: true, // Asegura que el fondo sea blanco
        ),
      ),
    );
  }

  _modelTextFieldMob({
    required String text,
    required bool obscure,
    required bool email,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    VoidCallback? onFieldSubmitted,
  }) {
    return Container(
      width: 450,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: (value) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
          onFieldSubmitted?.call();
        },
        obscureText: obscure,
        keyboardType:
            email ? TextInputType.emailAddress : TextInputType.visiblePassword,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ColorsSystem().colorStore,
        ),
        decoration: InputDecoration(
          hintText: text,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade500,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: ColorsSystem().colorSection,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: ColorsSystem().colorSelected,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: email == false
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      obscureC = !obscureC;
                    });
                  },
                  child: Icon(
                    obscure ? Icons.remove_red_eye_outlined : Icons.password,
                    color: Colors.grey,
                  ),
                )
              : null,
        ),
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
