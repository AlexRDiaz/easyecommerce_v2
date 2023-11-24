import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/sellers/my_seller_account/edit_autome.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:http/http.dart';

class MySellerAccount extends StatefulWidget {
  const MySellerAccount({super.key});

  @override
  State<MySellerAccount> createState() => _MySellerAccountState();
}

class _MySellerAccountState extends State<MySellerAccount> {
  late MySellerAccountControllers _controllers;
  bool loading = true;
  TextEditingController _validar = TextEditingController();
  var data = {};
  String state = "";
  String costoEntrega = "";
  String costoDevolucion = "";
  String idShopify = "";
  String referCost = "";
  var codigo = "";
  List<String> referers = [];
  @override
  void initState() {
    super.initState();
    initControllers();
    getReferers();
  }

  getReferers() async {
    var request = await Connections().getReferers();

    for (var element in request) {
      referers.add(
          "${element['nombre_comercial']} (${element['up_users'][0]['username']})");
    }
  }

  initControllers() async {
    setState(() {
      loading = true;
    });
    _controllers = MySellerAccountControllers(
        nombreComercial: '',
        numeroTelefono: '',
        telefonoDos: '',
        usuario: '',
        fechaAlta: '',
        correo: '');
    // var response = await Connections().getPersonalInfoAccount();
    var responseL = await Connections().getPersonalInfoAccountLaravel();
    var response = responseL['user'];
    referCost = response['vendedores'][0]['referer_cost'] ?? "";
    _controllers = MySellerAccountControllers(
      nombreComercial: response['vendedores'][0]['nombre_comercial'].toString(),
      numeroTelefono: response['vendedores'][0]['telefono_1'].toString(),
      telefonoDos: response['vendedores'][0]['telefono_2'].toString(),
      usuario: response['username'].toString(),
      fechaAlta: response['fecha_alta'].toString(),
      correo: response['email'].toString(),
    );
    codigo = response['codigo_generado'].toString();
    setState(() {
      data = response;
      idShopify = data['vendedores'][0]['id_master'].toString();
      loading = false;
      state = response['estado'].toString();
      costoEntrega = response['vendedores'][0]['costo_envio'].toString();
      costoDevolucion =
          response['vendedores'][0]['costo_devolucion'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.all(22),
        child: loading == true
            ? Container()
            : Container(
                color: Colors.grey[200],
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/layout/sellers');
                          },
                          icon: Icon(Icons.home), // Icono de Home
                          iconSize: 30, // Tamaño del icono
                        ),
                        InputRow(
                            controller: _controllers.nombreComercialController,
                            title: 'Nombre Comercial'),
                        SizedBox(
                          height: 30,
                        ),
                        _identifier(),
                        SizedBox(
                          height: 30,
                        ),
                        _referenced(),
                        SizedBox(
                          height: 30,
                        ),
                        InputRow(
                            controller: _controllers.correoController,
                            title: 'Correo'),
                        SizedBox(
                          height: 30,
                        ),
                        InputRow(
                            controller: _controllers.usuarioController,
                            title: 'Usuario'),
                        SizedBox(
                          height: 30,
                        ),
                        InputRow(
                            controller: _controllers.numeroTelefonoController,
                            title: 'Número de Teléfono'),
                        SizedBox(
                          height: 30,
                        ),
                        InputRow(
                            controller: _controllers.telefonoDosController,
                            title: 'Teléfono Dos'),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Fecha Alta: ${_controllers.fechaAltaController.text.toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "ESTADO: ${state.toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Costo Entrega: $costoEntrega",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Costo Devolución: $costoDevolucion",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        state != "NO VALIDADO" ? Container() : _validate(),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                            width: 500,
                            child: ElevatedButton(
                              child: Text(
                                "Guardar",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: () async {
                                getLoadingModal(context, false);
                                var response = await Connections()
                                    .updateUserLaravel(
                                        _controllers.usuarioController.text,
                                        _controllers.correoController.text,
                                        "");
                                var responseMaster = await Connections()
                                    .updateSellerGeneralInternalAccountLaravel(
                                        _controllers
                                            .nombreComercialController.text,
                                        _controllers
                                            .numeroTelefonoController.text,
                                        _controllers.telefonoDosController.text,
                                        data['vendedores'][0]['id'].toString());
                                await initControllers();
                                Navigator.pop(context);
                              },
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () => openConfigAutome(),
                          child: Text(
                            "Configurar autome",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  openConfigAutome() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: EditAutome(user: data),
            ),
          );
        }).then((value) {
      // if (edited) {
      //   setState(() {
      //     //   //_futureProviderData = _loadProviders(); // Actualiza el Future
      //   });
      // }
    });
  }

  Column _validate() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          width: 500,
          child: TextField(
            controller: _validar,
            decoration: InputDecoration(
                hintText: "CÓDIGO DE VALIDACÓN",
                hintStyle: TextStyle(fontWeight: FontWeight.bold)),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        SizedBox(
            width: 500,
            child: ElevatedButton(
              child: Text(
                "VALIDAR",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: () async {
                getLoadingModal(context, false);
                // if (_validar.text.toString() == data['CodigoGenerado']) {
                if (_validar.text.toString() == codigo) {
                  var update = await Connections().updateAccountStatusLaravel();
                  // var update = await Connections().updateAccountStatus();
                  await initControllers();
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  AwesomeDialog(
                    width: 500,
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.rightSlide,
                    title: 'Error',
                    desc: 'Incorrecto',
                    btnCancel: Container(),
                    btnOkText: "Aceptar",
                    btnOkColor: colors.colorGreen,
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {},
                  ).show();
                }
                var updateCode = print("Guardando");
              },
            )),
      ],
    );
  }

  _identifier() {
    return Container(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0, // Cambia el tamaño de fuente del texto de entrada
              color: Colors.black, // Cambia el color del texto de entrada
              // Puedes aplicar otros estilos aquí si es necesario
            ),
            readOnly: true,
            initialValue: '${serverUrlByShopify}/$idShopify',
            decoration: InputDecoration(
              fillColor: Colors.white, // Color del fondo del TextFormField
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
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
              label: const Text("Identificador",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  )),
              suffixIcon: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: "${serverUrlByShopify}/$idShopify"));
                  Get.snackbar('COPIADO', 'Copiado al Clipboard');
                },
                child: const Icon(
                  Icons.copy,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _referenced() {
    return Container(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0, // Cambia el tamaño de fuente del texto de entrada
              color: Colors.black, // Cambia el color del texto de entrada
              // Puedes aplicar otros estilos aquí si es necesario
            ),
            readOnly: true,
            initialValue: "$generalServeserverppweb/register/$idShopify",
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
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
              label: const Text("Link de referencia:",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  )),
              suffixIcon: Container(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PopupMenuButton<String>(
                      tooltip: 'ver referenciados',
                      icon: const Icon(
                        Icons.list,
                        color: Colors.blue,
                      ),
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'title',
                            enabled: false,
                            child: Text(
                              'Referenciados',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors
                                    .blue, // Personaliza el color del título
                              ),
                            ), // Evita que el título sea seleccionable
                          ),
                          ...referers.map((String opcion) {
                            return PopupMenuItem<String>(
                              value: opcion,
                              child: Text(opcion),
                            );
                          }).toList(),
                        ];
                      },
                      onSelected: (String seleccionada) {
                        // Maneja la opción seleccionada aquí
                        if (seleccionada != 'title') {
                          print('Opción seleccionada: $seleccionada');
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text:
                                "$generalServeserverppweb/register/$idShopify"));
                        Get.snackbar('COPIADO', 'Copiado al Clipboard');
                      },
                      child: const Icon(
                        Icons.copy,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              fillColor: Colors.white, // Color del fondo del TextFormField
              filled: true,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          TextFormField(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0, // Cambia el tamaño de fuente del texto de entrada
              color: Colors.black, // Cambia el color del texto de entrada
              // Puedes aplicar otros estilos aquí si es necesario
            ),
            readOnly: true,
            initialValue: "\$ $referCost",
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
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
              label: const Text("Comision de referenciado:",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  )),
              fillColor: Colors.white, // Color del fondo del TextFormField
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
