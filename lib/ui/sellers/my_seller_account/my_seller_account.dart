import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/connections/connections.dart';

import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/sellers/my_seller_account/edit_autome.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/get.dart';

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
      correo: '',
    );
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
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.all(17),
        child: loading == true
            ? Container()
            : Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: 1200,
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
                          icon: Icon(Icons.home),
                          iconSize: 30,
                        ),
                        // ... (otros widgets)
                        ProfileHeader(),
                        // Sección 1
                        _buildSection(
                          'Información Personal',
                          [
                            _buildRow(
                                'Nombre Comercial',
                                _controllers.nombreComercialController.text,
                                "El nombre de como se va a llamar tu tienda"),
                            Divider(),
                            _buildRow(
                                'Correo',
                                _controllers.correoController.text,
                                "El email es necesario para poder recibir notificaciones de easyecommerce"),
                            Divider(),
                            _buildRow(
                                'Usuario',
                                _controllers.usuarioController.text,
                                "Es el nombre del propietario de la cuenta de easyecommerce"),
                            Divider(),
                            _buildRow(
                                'Número de Teléfono',
                                _controllers.numeroTelefonoController.text,
                                "El numero de telefono servirá para llamarte en caso de emergencias"),
                            Divider(),
                            _buildRow(
                                'Teléfono Dos',
                                _controllers.telefonoDosController.text,
                                "El numero de telefono de respaldo en caso de no funcionar el segundo"),
                            Divider(),
                            _buildRow(
                                'Fecha Alta',
                                _controllers.fechaAltaController.text,
                                "Cecha en que se validotu usuario dentro de la plataforma"),
                          ],
                        ),

                        // Sección 2
                        _buildSection(
                          'Identificación y Referencia',
                          [
                            _buildRow(
                                'Identificador',
                                '${serverUrlByShopify}/$idShopify',
                                "Con este webhook podras conectar easyecommerce a tu tienda de shopify"),
                            Divider(),
                            _buildRow(
                                'Link de Referencia',
                                '$generalServeserverppweb/register/$idShopify',
                                "Este link es para aplicar como referenciado, por cada referenciado recibiras algunas ventajas"),
                            Divider(),
                            _buildRow(
                                'Comisión de Referenciado',
                                '\$ $referCost',
                                "esta es la comision que puedes conseguir como referenciador")
                          ],
                        ),

                        // Sección 3
                        _buildSection(
                          'Costos y Validación',
                          [
                            _buildRow(
                                'Costo Entrega',
                                'Costo Entrega: $costoEntrega',
                                "Este costo se te cobrará en cada pedido de easyecommerce"),
                            Divider(),
                            _buildRow(
                                'Costo Devolución',
                                'Costo Devolución: $costoDevolucion',
                                "este es el costo de penalizacion por devolucion de un pedido"),
                            Divider(),
                            _buildRow('Validar', _validate(),
                                "usa este boton para validar tu cuenta y poder usar todas las funcionalidades de la app"),
                            Divider(),
                            _buildRow(
                                'Autome',
                                ElevatedButton(
                                  onPressed: () => openConfigAutome(),
                                  child: Text(
                                    'Configurar autome',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                "Configura tu cuenta con chatby de autome"),
                          ],
                        ),
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
                    btnOkColor: Colors.green,
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

  // Métodos auxiliares
  Widget _buildSection(String title, List<Widget> rows) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Color de la sombra
            spreadRadius: 5, // Cuánto se extiende la sombra
            blurRadius: 7, // Qué tan difuminada está la sombra
            offset:
                Offset(0, 3), // La posición de la sombra (horizontal, vertical)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          ...rows
        ],
      ),
    );
  }

  Widget _buildRow(String title, dynamic content, description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 300,
            padding: EdgeInsets.only(left: 30),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content is Widget
              ? Container(width: 300, child: content)
              : Container(
                  width: 300,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    content.toString(),
                  ),
                ),
          Container(
            width: 300,
            child: Text(
              description,
            ),
          ),
        ],
      ),
    );
  }

  // ... (resto del código)
}

class ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(
              'assets/profile_picture.jpg'), // Reemplaza con la ruta de tu imagen
        ),
        SizedBox(height: 8),
        Text(
          'John Doe',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Software Developer',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }
}
