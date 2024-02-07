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
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class AddOrderSellersLaravel extends StatefulWidget {
  const AddOrderSellersLaravel({super.key});

  @override
  State<AddOrderSellersLaravel> createState() => _AddOrderSellersLaravelState();
}

class _AddOrderSellersLaravelState extends State<AddOrderSellersLaravel> {
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
                  const Align(
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  // const Divider(
                  //   height: 1.0,
                  //   color: Color(0xFF031749),
                  // ),
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
                  Row(
                    children: [
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _observacion,
                    decoration: const InputDecoration(
                      labelText: "Observación",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            //
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
                              if (formKey.currentState!.validate()) {
                                getLoadingModal(context, false);

                                String priceTotal =
                                    "${_precioTotalEnt.text}.${_precioTotalDec.text}";

                                //createOrder
                                var response =
                                    await Connections().createOrderLaravel(
                                  _nombre.text,
                                  selectedValueRoute.toString().split("-")[0],
                                  _direccion.text,
                                  _telefono.text,
                                  _producto.text,
                                  _productoE.text,
                                  _cantidad.text,
                                  priceTotal,
                                  _observacion.text,
                                  selectedValueRoute.toString().split("-")[1],
                                  selectedValueTransport
                                      .toString()
                                      .split("-")[1],
                                );

                                // print(response);
                                if (response == 0) {
                                  var _url = Uri.parse(
                                      """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda ${comercial}, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? ' y ${_productoE.text}' : ''}, por un valor total de: \$${priceTotal}. Su dirección de entrega será: ${_direccion.text} Es correcto...? Desea mas información del producto?""");
                                  if (!await launchUrl(_url)) {
                                    throw Exception('Could not launch $_url');
                                  }

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  // ignore: use_build_context_synchronously
                                  AwesomeDialog(
                                    width: 500,
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.rightSlide,
                                    title: "Error al crear el pedido",
                                    //  desc: 'Vuelve a intentarlo',
                                    btnCancel: Container(),
                                    btnOkText: "Aceptar",
                                    btnOkColor: Colors.green,
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      Navigator.pop(context);
                                    },
                                  ).show();
                                }
                              }
                            }

                            //
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
}
