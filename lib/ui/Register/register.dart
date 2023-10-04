import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/my_carousel.dart';
import 'package:get/get.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

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
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(6.0),
                  padding: const EdgeInsets.all(16.0),
                  height: height * 0.9,
                  width: width * 0.4,
                  child: Column(
                    children: [
                      Text(
                        'Ingreso de datos',
                        style: TextStyle(
                          fontSize: 30.0, // Tamaño de fuente grande
                          fontWeight: FontWeight.bold, // Texto en negrita
                          color: Colors.blue, // Color de texto
                          // decoration: TextDecoration., // Subrayado
                          // decorationColor: Colors.red, // Color del subrayado
                          fontFamily:
                              'AtractivaFont', // Fuente personalizada (si está configurada)
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                            child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  fillColor: Colors
                                      .white, // Color del fondo del TextFormField
                                  filled: true,
                                  labelText: 'Nombre Comercial',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                style: TextStyle(
                                    fontFamily:
                                        'AtractivaFont'), // Estilo de fuente personalizado
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, ingresa tu nombre comercial';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: _phone1Controller,
                                decoration: InputDecoration(
                                  fillColor: Colors
                                      .white, // Color del fondo del TextFormField
                                  filled: true,
                                  labelText: 'Telefono',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, ingresa tu número de telefono';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: _phone2Controller,
                                decoration: InputDecoration(
                                  labelText: 'Telefono 2',
                                  fillColor: Colors
                                      .white, // Color del fondo del TextFormField
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, ingresa un segundo número de telefono';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 10),

                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  fillColor: Colors
                                      .white, // Color del fondo del TextFormField
                                  filled: true,
                                  labelText: 'Nombre de usuario',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Tu nombre de usuario';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 10),

                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Correo Electrónico',
                                  fillColor: Colors
                                      .white, // Color del fondo del TextFormField
                                  filled: true,

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return 'Por favor, ingresa un correo electrónico válido';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _password1Controller,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  fillColor: Colors
                                      .white, // Color del fondo del TextFormField
                                  filled: true,
                                  labelText: 'Contraseña',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 6) {
                                    return 'La contraseña debe tener al menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),

                              TextFormField(
                                controller: _password2Controller,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  fillColor: Colors
                                      .white, // Color del fondo del TextFormField
                                  filled: true,
                                  labelText: 'Rrepetir Contraseña',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 6) {
                                    return 'La contraseña debe tener al menos 6 caracteres';
                                  }
                                  if (_password1Controller.text != value) {
                                    return 'las contraseñas no son iguales';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),

                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _urlStoreController,
                                decoration: InputDecoration(
                                  fillColor: Colors
                                      .white, // Color del fondo del TextFormField
                                  filled: true,
                                  labelText: 'Url de su tienda',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'debe tener este formato www.comprafacil@gmail.com';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Los otros TextFormField seguirían un patrón similar
                              // ...
                            ],
                          ),
                        )),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var res = await Connections()
                                .createSellerGeneralLaravel(
                                    _usernameController.text,
                                    _emailController.text,
                                    _nameController.text,
                                    _phone1Controller.text,
                                    _phone2Controller.text,
                                    5,
                                    5.50,
                                    _urlStoreController.text,
                                    id);
                            // Aquí puedes enviar los datos del formulario al servidor o realizar otras acciones
                            print(id);
                            if (res == 0) {
                              showSuccessModal(
                                  context,
                                  "Se ha registrado exitosamente",
                                  Icons8.check_circle_color);
                              Future.delayed(Duration(milliseconds: 2000), () {
                                Navigator.pop(context);
                                Get.offNamed('/login');
                              });
                            }
                            if (res == 1) {
                              showSuccessModal(
                                  context,
                                  "No se pudo guardar los cambios",
                                  Icons8.fatal_error);
                            }
                            if (res == 2) {
                              SnackBarHelper.showErrorSnackBar(
                                  context, "Ha ocurrido un error de conexión");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary:
                              Colors.blue, // Cambia el color de fondo del botón
                          onPrimary: Colors
                              .white, // Cambia el color del texto del botón
                          padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal:
                                  20), // Ajusta el espaciado interno del botón
                          textStyle: TextStyle(
                              fontSize: 18), // Cambia el tamaño del texto
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Agrega bordes redondeados
                          ),
                          elevation: 3, // Agrega una sombra al botón
                        ),
                        child: Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 18, // Cambia el tamaño del texto
                            fontWeight:
                                FontWeight.bold, // Aplica negrita al texto
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Segunda sección con información adicional
          Container(
            color: Colors.blue, // Personaliza el color de fondo
            padding: EdgeInsets.all(16.0),
            width: width * 0.40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'EasyRef',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white, // Personaliza el color del texto
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Unete a easyRef y crecemos todos.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white, // Personaliza el color del texto
                  ),
                ),
                //      MyCarousel()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
