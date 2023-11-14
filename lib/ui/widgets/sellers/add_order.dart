import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/main.dart';

class AddOrderSellers extends StatefulWidget {
  const AddOrderSellers({super.key});

  @override
  State<AddOrderSellers> createState() => _AddOrderSellersState();
}

class _AddOrderSellersState extends State<AddOrderSellers> {
  List<DateTime?> _dates = [];
  TextEditingController _cantidad = TextEditingController();
  TextEditingController _codigo = TextEditingController();
  TextEditingController _nombre = TextEditingController();
  TextEditingController _direccion = TextEditingController();
  TextEditingController _ciudad = TextEditingController();
  TextEditingController _telefono = TextEditingController();
  TextEditingController _producto = TextEditingController();
  TextEditingController _productoE = TextEditingController();
  TextEditingController _precioTotalEnt = TextEditingController();
  TextEditingController _precioTotalDec = TextEditingController();

  TextEditingController _observacion = TextEditingController();
  bool pendiente = true;
  bool confirmado = false;
  bool noDesea = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> routes = [];
  String? selectedValueRoute;
  String numeroOrden = "";
  List<String> transports = [];
  var routesList = [];
  String? selectedValueTransport;
  String? comercial = sharedPrefs!.getString("NameComercialSeller");

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  @override
  void didChangeDependencies() {
    getRoutes();
    super.didChangeDependencies();
  }

  getRoutes() async {
    try {
      routesList = await Connections().getRoutesLaravel();
      setState(() {
        routes = routesList
            .where((route) => route['titulo'] != "[Vacio]")
            .map<String>((route) => '${route['titulo']}-${route['id']}')
            .toList();
        //'${route['titulo']}'
      });
    } catch (error) {
      print('Error al cargar rutas: $error');
    }
  }

  getTransports() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      var transportList = [];

      setState(() {
        transports = [];
      });

      transportList = await Connections().getTransportsByRouteLaravel(
          selectedValueRoute.toString().split("-")[1]);

      for (var i = 0; i < transportList.length; i++) {
        setState(() {
          transports
              .add('${transportList[i]['nombre']}-${transportList[i]['id']}');
        });
      }

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {});
    } catch (error) {
      print('Error al cargar rutas: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 500,
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Destino:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Seleccione una Ciudad',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold),
                      ),
                      items: routes
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.split('-')[0],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                      value: selectedValueRoute,
                      onChanged: (value) async {
                        setState(() {
                          selectedValueRoute = value as String;
                          transports.clear();
                          selectedValueTransport = null;
                        });
                        await getTransports();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Seleccione una Transportadora',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold),
                      ),
                      items: transports
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.split('-')[0],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                      value: selectedValueTransport,
                      onChanged: selectedValueRoute == null
                          ? null
                          : (value) {
                              setState(() {
                                selectedValueTransport = value as String;
                              });
                            },

                      //This to clear the search value when you close the menu
                      // onMenuStateChange: (isOpen) {
                      //   if (!isOpen) {
                      //     textEditingController.clear();
                      //   }
                      // },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _nombre,
                    decoration: const InputDecoration(
                      labelText: "Nombre Cliente",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                      // else if (containsEmoji(value)) {
                      //   return "No se permiten emojis en este campo";
                      // }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _direccion,
                    decoration: const InputDecoration(
                      labelText: "Dirección",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                      // else if (containsEmoji(value)) {
                      //   return "No se permiten emojis en este campo";
                      // }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _telefono,
                    decoration: const InputDecoration(
                      labelText: "Teléfono",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _cantidad,
                    decoration: const InputDecoration(
                      labelText: "Cantidad (Enteros)",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _producto,
                    decoration: const InputDecoration(
                      labelText: "Producto",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                      // else if (containsEmoji(value)) {
                      //   return "No se permiten emojis en este campo";
                      // }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _productoE,
                    decoration: const InputDecoration(
                      labelText: "Producto Extra",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        controller: _precioTotalEnt,
                        decoration: const InputDecoration(
                          labelText: "Precio Total (Entero)",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Campo requerido";
                          }
                        },
                      ),
                    ),
                    const Text("  .  ", style: TextStyle(fontSize: 35)),
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        controller: _precioTotalDec,
                        decoration: const InputDecoration(
                          labelText: "(Decimal)",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Campo requerido";
                          }
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  TextField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _observacion,
                    decoration: const InputDecoration(
                      labelText: "Observación",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  /*
                  Row(
                    children: [
                      Checkbox(
                          value: pendiente,
                          onChanged: (v) {
                            setState(() {
                              pendiente = true;
                              confirmado = false;
                              noDesea = false;
                            });
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                      const Flexible(
                          child: Text(
                        "Pendiente",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: confirmado,
                          onChanged: (v) {
                            setState(() {
                              pendiente = false;
                              confirmado = true;
                              noDesea = false;
                            });
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                      const Flexible(
                          child: Text(
                        "Confirmado",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: noDesea,
                          onChanged: (v) {
                            setState(() {
                              pendiente = false;
                              confirmado = false;
                              noDesea = true;
                            });
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                      const Flexible(
                          child: Text(
                        "No Desea",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                    ],
                  ),
                  */
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "CANCELAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            // print(selectedValueRoute.toString());
                            // print(selectedValueTransport.toString());

                            if (selectedValueRoute == null ||
                                selectedValueTransport == null) {
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Error de selección',
                                desc:
                                    'Debe seleccionar una ciudad y una transportadora.',
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: colors.colorGreen,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {},
                              ).show();
                            } else {
                              // print("ciudad else ");
                              if (formKey.currentState!.validate()) {
                                getLoadingModal(context, false);
                                String valueState = "";
                                String fechaC = "";
                                // if (pendiente) {
                                //   valueState = "PENDIENTE";
                                // }
                                // if (confirmado) {
                                valueState = "CONFIRMADO";
                                fechaC =
                                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
                                // }
                                // if (noDesea) {
                                //   valueState = "NO DESEA";
                                // }
                                var dateC = await Connections().createDateOrder(
                                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
                                String priceTotal = _precioTotalEnt.text +
                                    "." +
                                    _precioTotalDec.text;
                                numeroOrden = await generateNumeroOrden();

                                var response = await Connections().createOrder(
                                    // _codigo.text,
                                    numeroOrden,
                                    _direccion.text,
                                    _nombre.text,
                                    _telefono.text,
                                    priceTotal,
                                    _observacion.text,
                                    // _ciudad.text,
                                    selectedValueRoute.toString().split("-")[0],
                                    valueState,
                                    _producto.text,
                                    _productoE.text,
                                    _cantidad.text,
                                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                                    fechaC,
                                    dateC[1]);

                                // print("res de crear new order: ${response}");
                                var resUpdateRT = await Connections()
                                    .updateOrderRouteAndTransportLaravel(
                                        selectedValueRoute
                                            .toString()
                                            .split("-")[1],
                                        selectedValueTransport
                                            .toString()
                                            .split("-")[1],
                                        response[1]);

                                var response3 = await Connections()
                                    .updateOrderWithTime(
                                        response[1].toString(),
                                        "estado_interno:CONFIRMADO",
                                        sharedPrefs!.getString("id"),
                                        "",
                                        "");

                                var _url = Uri.parse(
                                    """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, te saludo de la tienda ${comercial}, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? ' y ${_productoE.text}' : ''}, por un valor total de: ${priceTotal}. Su dirección de entrega será: ${_direccion.text} Es correcto...? Desea mas información del producto?""");
                                if (!await launchUrl(_url)) {
                                  throw Exception('Could not launch $_url');
                                }

                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: const Text(
                            "GUARDAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String> generateNumeroOrden() async {
    final random = Random();
    int numeroAleatorio = random.nextInt(900000) + 100000;
    String codeRandom = "E${numeroAleatorio.toString()}";
    return codeRandom;
  }
}
