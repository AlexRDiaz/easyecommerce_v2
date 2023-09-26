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

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      var routesList = await Connections().getRoutesLaravel();
      setState(() {
        routes = routesList
            .map<String>((route) => '${route['titulo']}-${route['id']}')
            .toList();
        //'${route['titulo']}'
      });
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
                      'Ciudad:',
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
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _codigo,
                    decoration: const InputDecoration(
                      labelText: "Código",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z0-9\-]+$'),
                      ),
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      } else if (containsEmoji(value)) {
                        return "No se permiten emojis en este campo";
                      }
                    },
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
                      } else if (containsEmoji(value)) {
                        return "No se permiten emojis en este campo";
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
                      } else if (containsEmoji(value)) {
                        return "No se permiten emojis en este campo";
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
                      } else if (containsEmoji(value)) {
                        return "No se permiten emojis en este campo";
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
                            if (selectedValueRoute == null) {
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Error de selección',
                                desc: 'Debe seleccionar una ciudad.',
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
                                if (pendiente) {
                                  valueState = "PENDIENTE";
                                }
                                if (confirmado) {
                                  valueState = "CONFIRMADO";
                                  fechaC =
                                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
                                }
                                if (noDesea) {
                                  valueState = "NO DESEA";
                                }
                                var dateC = await Connections().createDateOrder(
                                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
                                String priceTotal = _precioTotalEnt.text +
                                    "." +
                                    _precioTotalDec.text;
                                var response = await Connections().createOrder(
                                    _codigo.text,
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
}
