import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class PaymentInformationUpdate extends StatefulWidget {
  final List currentAccount;
  final int index;
  const PaymentInformationUpdate(
      {super.key, required this.currentAccount, required this.index});

  @override
  State<PaymentInformationUpdate> createState() =>
      _PaymentInformationUpdateState();
}

class _PaymentInformationUpdateState extends State<PaymentInformationUpdate> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _bankEntityController = TextEditingController();
  TextEditingController _accountTypeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _accountNumber = TextEditingController();
  TextEditingController _dni = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameController.text = widget.currentAccount[widget.index]['names'];
    _lastnameController.text = widget.currentAccount[widget.index]['last_name'];
    _bankEntityController.text =
        widget.currentAccount[widget.index]['bank_entity'];
    _accountTypeController.text =
        widget.currentAccount[widget.index]['account_type'];
    _emailController.text = widget.currentAccount[widget.index]['email'];
    _accountNumber.text = widget.currentAccount[widget.index]['account_number'];
    _dni.text = widget.currentAccount[widget.index]['dni'] ?? "";
    super.initState();
  }

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
                      keyboardType: TextInputType.emailAddress,
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
                      keyboardType: TextInputType.text,
                      controller: _dni,
                      decoration: InputDecoration(
                        labelText: 'Dni',
                        fillColor:
                            Colors.white, // Color del fondo del TextFormField
                        filled: true,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, ingresa tu numero de identiciación';
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
                editAccount();
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
                'Editar',
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

  Future<void> editAccount() async {
    widget.currentAccount[widget.index]['names'] = _nameController.text;
    widget.currentAccount[widget.index]['last_name'] = _lastnameController.text;
    widget.currentAccount[widget.index]['bank_entity'] =
        _bankEntityController.text;
    widget.currentAccount[widget.index]['account_type'] =
        _accountTypeController.text;
    widget.currentAccount[widget.index]['email'] = _emailController.text;
    widget.currentAccount[widget.index]['account_number'] = _accountNumber.text;
    widget.currentAccount[widget.index]['dni'] = _dni.text;

    var response = await Connections().modifyAccountData(widget.currentAccount);
    if (response == 0) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Guardado Exitosamente',
        desc: 'Su cuenta bancaria ha sido editada',
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
