import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class PaymentInformation extends StatefulWidget {
  const PaymentInformation({super.key});

  @override
  State<PaymentInformation> createState() => _PaymentInformationState();
}

class _PaymentInformationState extends State<PaymentInformation> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _bankEntityController = TextEditingController();
  TextEditingController _accountTypeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _accountNumber = TextEditingController();
  TextEditingController _dniController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              'Agregar cuenta',
              style: TextStyle(
                fontSize: 30.0, // Tamaño de fuente grande
                fontWeight: FontWeight.bold, // Texto en negrita
                color: Color.fromARGB(255, 3, 3, 3), // Color de texto
                fontFamily:
                    'Arial', // Fuente personalizada (cámbiala según tus necesidades)
                letterSpacing: 2.0, // Espaciado entre letras
                decorationColor: Colors.red, // Color del subrayado
                decorationThickness: 2.0, // Grosor del subrayado
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
                        fillColor:
                            Colors.white, // Color del fondo del TextFormField
                        filled: true,
                        labelText: 'Nombres',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Sus dos nombres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _lastnameController,
                      decoration: InputDecoration(
                        fillColor:
                            Colors.white, // Color del fondo del TextFormField
                        filled: true,
                        labelText: 'Apellidos',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Sus dos apellidos';
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
                        fillColor:
                            Colors.white, // Color del fondo del TextFormField
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
                      keyboardType: TextInputType.emailAddress,
                      controller: _bankEntityController,
                      decoration: InputDecoration(
                        labelText: 'Entidad Bancaria',
                        fillColor:
                            Colors.white, // Color del fondo del TextFormField
                        filled: true,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Nombre del banco';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _accountTypeController,
                      decoration: InputDecoration(
                        labelText: 'Tipo de cuenta',
                        fillColor:
                            Colors.white, // Color del fondo del TextFormField
                        filled: true,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Corriente / de ahorro';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _accountNumber,
                      decoration: InputDecoration(
                        labelText: 'Numero de cuenta',
                        fillColor:
                            Colors.white, // Color del fondo del TextFormField
                        filled: true,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, ingresa tu numero de cuenta';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _dniController,
                      decoration: InputDecoration(
                        labelText: 'Cédula',
                        fillColor:
                            Colors.white, // Color del fondo del TextFormField
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, ingresa tu numero de cédula';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              )),
            ),
            // Container(width: 200, height: 300, child: HtmlEditor()),

            ElevatedButton(
              onPressed: () async {
                saveAccount();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Cambia el color de fondo del botón
                onPrimary: Colors.white, // Cambia el color del texto del botón
                padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 40), // Ajusta el espaciado interno del botón
                textStyle:
                    TextStyle(fontSize: 18), // Cambia el tamaño del texto
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Agrega bordes redondeados
                ),
                elevation: 3, // Agrega una sombra al botón
              ),
              child: Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 18, // Cambia el tamaño del texto
                  fontWeight: FontWeight.bold, // Aplica negrita al texto
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveAccount() async {
    var response = await Connections().editAccountData(
        _nameController.text,
        _lastnameController.text,
        _emailController.text,
        _bankEntityController.text,
        _accountTypeController.text,
        _accountNumber.text);

    print(response);
    if (response == 0) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Guardado Exitosamente',
        desc: 'Su cuenta bancaria ha sido guardada',
        btnCancel: Container(),
        btnOkText: "Aceptar",
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
        title: 'Error',
        desc: 'No se pudo guardar su cuenta bancaria',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.redAccent,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
    }
  }
}
