import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/image_input.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/forms/modal_row.dart';
import 'package:frontend/ui/widgets/forms/row_options.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';

class NewSalesReport extends StatefulWidget {
  const NewSalesReport({
    super.key,
  });

  @override
  State<NewSalesReport> createState() => _NewSalesReportState();
}

class _NewSalesReportState extends State<NewSalesReport> {
  bool entregado = false;
  bool noEntregado = false;
  bool novedad = false;
  bool reagendado = false;
  bool enRuta = false;
  bool pedidoProgramado = false;
  bool enOficina = false;

  bool pendiente = false;
  bool confirmado = false;
  bool noDesea = false;
  List estados = [];
  List confirmados = [];

  late AddReportControllers _controllers;
  initControllers() {
    _controllers = AddReportControllers(desde: '', hasta: '', estado: '');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  getLoadingModal(context, false);
    });
  }

  var data = {};
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context, "/layout/sellers");
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black)),
        centerTitle: true,
        title: const Text(
          "Ingresos Form",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  DateInput(
                    isEdit: true,
                    title: "Desde",
                    dateTime: DateTime.now(),
                    controller: _controllers.desdeController,
                  ),
                  DateInput(
                    isEdit: true,
                    title: "Hasta",
                    dateTime: DateTime.now(),
                    controller: _controllers.hastaController,
                  ),
                  Text(
                    "ESTADO",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 500,
                    child: Column(
                      children: [
                        _state1(),
                        _state2(),
                        _state3(),
                        _state4(),
                        _state5(),
                        _state6(),
                        _state7(),
                      ],
                    ),
                  ),
                  Text(
                    "Estado Confirmado?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 500,
                    child: Column(
                      children: [
                        _type1(),
                        _type2(),
                        _type3(),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);
                        var result = await Connections().generateReportSeller(
                            _controllers.desdeController.text,
                            _controllers.hastaController.text,
                            estados,
                            confirmados);
                        Navigator.pop(context);
                        if (!result) {
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: 'Error',
                            desc: 'No existen Resultados',
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                        } else {
                          Navigators().pushNamedAndRemoveUntil(
                              context, "/layout/sellers");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.colorGreen),
                      child: Text(
                        "GENERAR REPORTE",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Column _state1() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: entregado,
                onChanged: (value) {
                  setState(() {
                    entregado = value!;
                    if (value) {
                      estados.add("ENTREGADO");
                    } else {
                      estados.remove("ENTREGADO");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "ENTREGADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _state2() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: noEntregado,
                onChanged: (value) {
                  setState(() {
                    noEntregado = value!;
                    if (value) {
                      estados.add("NO ENTREGADO");
                    } else {
                      estados.remove("NO ENTREGADO");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "NO ENTREGADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _state3() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: novedad,
                onChanged: (value) {
                  setState(() {
                    novedad = value!;
                    if (value) {
                      estados.add("NOVEDAD");
                    } else {
                      estados.remove("NOVEDAD");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "NOVEDAD",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _state4() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: reagendado,
                onChanged: (value) {
                  setState(() {
                    reagendado = value!;
                    if (value) {
                      estados.add("REAGENDADO");
                    } else {
                      estados.remove("REAGENDADO");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "REAGENDADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _state5() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: enRuta,
                onChanged: (value) {
                  setState(() {
                    enRuta = value!;
                    if (value) {
                      estados.add("EN RUTA");
                    } else {
                      estados.remove("EN RUTA");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "EN RUTA",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _state6() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: pedidoProgramado,
                onChanged: (value) {
                  setState(() {
                    pedidoProgramado = value!;
                    if (value) {
                      estados.add("PEDIDO PROGRAMADO");
                    } else {
                      estados.remove("PEDIDO PROGRAMADO");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "PEDIDO PROGRAMADO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _state7() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: enOficina,
                onChanged: (value) {
                  setState(() {
                    enOficina = value!;
                    if (value) {
                      estados.add("EN OFICINA");
                    } else {
                      estados.remove("EN OFICINA");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "EN OFICINA",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _type1() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: pendiente,
                onChanged: (value) {
                  setState(() {
                    pendiente = value!;
                    if (value) {
                      confirmados.add("PENDIENTE");
                    } else {
                      confirmados.remove("PENDIENTE");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "Pendiente",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _type2() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: confirmado,
                onChanged: (value) {
                  setState(() {
                    confirmado = value!;
                    if (value) {
                      confirmados.add("CONFIRMADO");
                    } else {
                      confirmados.remove("CONFIRMADO");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "Confirmado",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column _type3() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Checkbox(
                value: noDesea,
                onChanged: (value) {
                  setState(() {
                    noDesea = value!;
                    if (value) {
                      confirmados.add("NO DESEA");
                    } else {
                      confirmados.remove("NO DESEA");
                    }
                  });
                }),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "No Desea",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
