import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/build_text_form_field.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/my_carousel.dart';
import 'package:gap/gap.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:animate_do/animate_do.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  final TextEditingController _urlStoreController = TextEditingController();
  bool showAnimation = false;
  bool isLoading = false;
  bool _isTextEnlarged = false;

  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        // Agregar un booleano para controlar la animación
        showAnimation = true;
        _isTextEnlarged = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final String id = Get.parameters['id'] ?? '';
    ButtonState stateOnlyText = ButtonState.idle;
    ButtonState stateOnlyCustomIndicatorText = ButtonState.idle;
    ButtonState stateTextWithIcon = ButtonState.idle;
    ButtonState stateTextWithIconMinWidthState = ButtonState.idle;

    void onPressedCustomButton() {
      setState(() {
        switch (stateOnlyText) {
          case ButtonState.idle:
            stateOnlyText = ButtonState.loading;
            break;
          case ButtonState.loading:
            stateOnlyText = ButtonState.fail;
            break;
          case ButtonState.success:
            stateOnlyText = ButtonState.idle;
            break;
          case ButtonState.fail:
            stateOnlyText = ButtonState.success;
            break;
        }
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: showAnimation
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 23, 0, 168),
                      Color.fromARGB(255, 3, 0, 24),
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Image.asset(
                          images.logoEasyEcommercce,
                          width: MediaQuery.of(context).size.width * 0.15,
                        ),
                        SizedBox(height: 40),
                        showAnimation
                            ? SlideInLeft(
                                child: boxRegister(id, context),
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          showAnimation
                              ? SlideInRight(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white.withOpacity(0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 5,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.only(
                                        right: 20, top: 20, bottom: 20),
                                    height: MediaQuery.of(context).size.height *
                                        0.53,
                                    // Adjust the height based on your preference
                                    child: MyCarousel(),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 50),
                          textPresentation(),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
      ),
    );
  }

  TweenAnimationBuilder<double> textPresentation() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
          begin: _isTextEnlarged ? 4.0 : 0.5, end: _isTextEnlarged ? 4.5 : 1.0),
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(
              child: Text(
                'La mejor manera',
                style: GoogleFonts.kaushanScript(
                  fontSize: 24,
                  color: Colors.white,
                  // Otros estilos
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Container boxRegister(String id, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade200, Color.fromARGB(255, 6, 95, 167)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 100),
      padding: const EdgeInsets.all(20),
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Text(
              "Únete al mejor equipo",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 37,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    buildTextFormField(
                      controller: _nameController,
                      labelText: "Nombre Comercial",
                      hintText: "Ingrese el nombre de su tienda",
                      prefixIcon: Icons.people,
                      validationMessage:
                          'Por favor, ingresa tu nombre comercial',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextFormField(
                            controller: _phone1Controller,
                            labelText: "Teléfono",
                            hintText: "Ingrese su número telefónico",
                            prefixIcon: Icons.phone,
                            validationMessage:
                                'Por favor, ingresa tu número de teléfono',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(width: 10), // Espacio entre los campos
                        Expanded(
                          child: buildTextFormField(
                            controller: _phone2Controller,
                            labelText: "Teléfono 2",
                            hintText: "Ingrese número telefónico de respaldo",
                            prefixIcon: Icons.phone,
                            validationMessage:
                                'Por favor, ingresa un segundo número de teléfono',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    buildTextFormField(
                      controller: _usernameController,
                      labelText: "Nombre de usuario",
                      hintText: "Ingrese su nombre",
                      prefixIcon: Icons.person,
                      validationMessage: 'Ingresa tu nombre de usuario',
                    ),
                    buildTextFormField(
                      controller: _emailController,
                      labelText: "Email",
                      hintText: "Ingrese su correo electrónico",
                      prefixIcon: Icons.email,
                      validationMessage: 'Ingresa un correo electrónico válido',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    buildTextFormField(
                      controller: _password1Controller,
                      labelText: "Contraseña",
                      hintText: "Ingrese una contraseña",
                      prefixIcon: Icons.lock,
                      validationMessage:
                          'La contraseña debe tener al menos 6 caracteres',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    buildTextFormField(
                      controller: _password2Controller,
                      labelText: "Repetir Contraseña",
                      hintText: "Verifique su contraseña",
                      prefixIcon: Icons.lock,
                      validationMessage: 'Las contraseñas no son iguales',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    buildTextFormField(
                      controller: _urlStoreController,
                      labelText: "URL tienda",
                      hintText: "Ingrese el dominio de su tienda",
                      prefixIcon: Icons.link,
                      validationMessage:
                          'Debe tener este formato www.comprafacil@gmail.com',
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          registerButton(id, context),
        ],
      ),
    );
  }

  SizedBox registerButton(String id, BuildContext context) {
    return SizedBox(
      width: 200, // Ancho deseado para el botón
      child: ElevatedButton(
        onPressed: () async {
          await register(id, context);
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.blue,
          padding:
              const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
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
              isLoading ? "Cargando" : 'Registrarme ahora',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> register(String id, BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      var res = await Connections().createSellerGeneralLaravel(
          _usernameController.text,
          _emailController.text,
          _password2Controller.text,
          _nameController.text,
          _phone1Controller.text,
          _phone2Controller.text,
          5,
          5.50,
          _urlStoreController.text,
          id);
      print(id);
      if (res == 0) {
        // ignore: use_build_context_synchronously
        showSuccessModal(context, "Se ha registrado exitosamente",
            Icons8.check_circle_color);
        Future.delayed(Duration(milliseconds: 2000), () {
          Navigator.pop(context);
          Get.offNamed('/login');
        });
      }
      if (res == 1) {
        // ignore: use_build_context_synchronously
        showSuccessModal(
            context, "No se pudo guardar los cambios", Icons8.fatal_error);
      }
      if (res == 2) {
        SnackBarHelper.showErrorSnackBar(
            context, "Ha ocurrido un error de conexión");
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  showSuccessModal(BuildContext context, text, icon) {
    showDialog(
      context: context,
      builder: (context) => CustomSuccessModal(text: text, animatedIcon: icon),
    );
  }
}
