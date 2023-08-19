import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/amount_row.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../helpers/navigators.dart';
import '../../widgets/loading.dart';

class ProofPayment extends StatefulWidget {
  const ProofPayment({super.key});

  @override
  State<ProofPayment> createState() => _ProofPaymentState();
}

class _ProofPaymentState extends State<ProofPayment> {
  final VendorInvoicesControllers _controllers = VendorInvoicesControllers();
  TextEditingController _mesController = TextEditingController();
  TextEditingController _anoController = TextEditingController();
  List<String> transportator = [];
  String? selectedValueTransportator;
  List<String> meses = [];
  String? selectedValueMonth;
  List objetosAndFechas = [];
  List totalesPrecio = [];
  List dataGeneral = [];
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  getOrders() async {
    double sumaCosto = 0;
    List temp = [];
    List daysM = [];
    var response = await Connections().getOrdersSCalendar(
        selectedValueTransportator.toString().split("-")[1].toString(),
        selectedValueMonth.toString());
    setState(() {
      if (response != null) {
        dataGeneral = response;
      }
    });
    if (response != null) {
      for (var i = 0; i < response.length; i++) {
        daysM.add({
          "dia": response[i]['Fecha_Entrega'].toString().split("/")[0],
          "id": response[i]['id'].toString(),
          "total": response[i]['PrecioTotal'].toString(),
          "Status": response[i]['Status'].toString(),
          "CostoTrans":
              response[i]['transportadora']['Costo_Transportadora'].toString()
        });
      }
      List<Map<String, dynamic>> data = [...daysM];

      data.sort((a, b) => a['dia'].compareTo(b['dia']));
// Crear un mapa para almacenar la información de cada día
      Map<String, dynamic> mapData = {};
      for (var item in data) {
        String day = item["dia"];
        double total = 0.0;
        double costoTrans = 0.0;
        String id = item["id"];

        try {
          if (item["total"].toString() == "null") {
            total = double.parse("0");
          } else {
            total = double.parse(item["total"].replaceAll(",", "."));
          }
          if (item["CostoTrans"].toString() == "null") {
            costoTrans = double.parse("0");
          } else {
            costoTrans = double.parse(item["CostoTrans"].replaceAll(",", "."));
          }
        } catch (e) {
          print(total);
          print("--------------");

          print(costoTrans);
          print("--------------");
          print(id);
        }

        String status = item["Status"];
        // Actualizar los valores del mapa si el día ya está en el mapa
        if (mapData.containsKey(day)) {
          setState(() {
            if (status == "ENTREGADO") {
              mapData[day]["Status"] = status;
              mapData[day]["total"] += total;
            }
            if (status == "ENTREGADO" || status == "NO ENTREGADO") {
              mapData[day]["CostoTrans"] += costoTrans;
            }
          });
        } else {
          if (mapData[day] == null) {
            mapData[day] = {
              "total": 0.0,
              "CostoTrans": 0.0,
              "id": id,
              "Status": status
            };
            setState(() {
              if (status == "ENTREGADO") {
                mapData[day]["Status"] = status;

                mapData[day]["total"] += total;
              }
              if (status == "ENTREGADO" || status == "NO ENTREGADO") {
                mapData[day]["CostoTrans"] += costoTrans;
              }
            });
          }
        }
      }

// Crear una nueva lista con los campos "day", "total", "CostoTrans" y "id"
      List<Map<String, dynamic>> result = [];

      mapData.forEach((key, value) {
        result.add({
          "dia": key,
          "total": value["total"],
          "CostoTrans": value["CostoTrans"],
          "id": value["id"],
          "Status": value["Status"]
        });
      });
      setState(() {
        totalesPrecio = result;
      });

      for (var i = 0; i < response.length; i++) {
        temp.add({
          "dia": response[i]['Fecha_Entrega'].toString().split("/")[0],
          "pagado": response[i]['Estado_Pago_Logistica'].toString(),
          "id": response[i]['id'].toString(),
          "comprobante": response[i]['Url_P_L_Foto'].toString(),
          "ComentarioRechazado": response[i]['ComentarioRechazado'].toString(),
        });
      }
      temp.sort((a, b) {
        var pagadoA = a["pagado"];
        var pagadoB = b["pagado"];

        // Ordenar primero los elementos con estado diferente a "PENDIENTE"
        if (pagadoA != "PENDIENTE" && pagadoB == "PENDIENTE") {
          return -1; // a debe colocarse antes que b
        } else if (pagadoA == "PENDIENTE" && pagadoB != "PENDIENTE") {
          return 1; // b debe colocarse antes que a
        }

        return 0; // No se cambia el orden entre a y b
      });
      temp = temp.fold<List<Map<String, dynamic>>>([], (list, currentItem) {
        if (!list.any((item) => item["dia"] == currentItem["dia"])) {
          list.add(currentItem);
        }
        return list;
      });

      setState(() {
        objetosAndFechas = temp;
      });
    }
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    meses.clear();

    List transportatorList = [];

    setState(() {
      transportator = [];
    });

    var response = [];
    for (var i = 1; i < 13; i++) {
      meses.add(i.toString());
      setState(() {});
    }

    transportatorList = await Connections().getAllTransportators();
    for (var i = 0; i < transportatorList.length; i++) {
      setState(() {
        if (transportatorList != null) {
          transportator.add(
              '${transportatorList[i]['attributes']['Nombre']}-${transportatorList[i]['id']}');
        }
      });
    }
    if (sharedPrefs!.getString("transportadoraComprobante") != null) {
      selectedValueTransportator =
          sharedPrefs!.getString("transportadoraComprobante");
    }
    if (sharedPrefs!.getString("mesComprobante") != null) {
      selectedValueMonth = sharedPrefs!.getString("mesComprobante");
    }
    if (sharedPrefs!.getString("mesComprobante") != null &&
        sharedPrefs!.getString("transportadoraComprobante") != null) {
      await getOrders();
    }
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {});
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: ListView(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'TRANSPORTADORA',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold),
                    ),
                    items: transportator
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item.split('-')[0],
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                    value: selectedValueTransportator,
                    onChanged: (value) async {
                      setState(() {
                        selectedValueTransportator = value as String;
                        sharedPrefs!.setString(
                            "transportadoraComprobante", value as String);
                      });
                    },

                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {}
                    },
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'MES',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold),
                    ),
                    items: meses
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item.split('-')[0],
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                    value: selectedValueMonth,
                    onChanged: (value) async {
                      setState(() {
                        selectedValueMonth = value as String;
                        sharedPrefs!
                            .setString("mesComprobante", value as String);
                      });
                    },

                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {}
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                        onPressed: selectedValueTransportator != null
                            ? () async {
                                getLoadingModal(context, false);
                                await getOrders();
                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          "Buscar",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Wrap(
                  children: [
                    ...List.generate(
                      31,
                      (index) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: GestureDetector(
                          onTap: () async {
                            var resultValidation = await getByDay(index + 1)[0]
                                    ["pagado"]
                                .toString();
                            var resultRechazado = await getByDay(index + 1)[0]
                                    ['ComentarioRechazado']
                                .toString();
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController _rechazado =
                                      TextEditingController();
                                  _rechazado.text = resultRechazado;

                                  return AlertDialog(
                                    content: Container(
                                      width: 400,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: Column(
                                        children: [
                                          resultValidation == "PENDIENTE"
                                              ? Container()
                                              : TextButton(
                                                  onPressed: () {
                                                    launchUrl(Uri.parse(
                                                        "$generalServer${getByDay(index + 1)[0]['comprobante']}"));
                                                  },
                                                  child: Text(
                                                    "VER COMPROBANTE",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Divider(),
                                          resultValidation == "PENDIENTE"
                                              ? Container()
                                              : TextButton(
                                                  onPressed: () async {
                                                    getLoadingModal(
                                                        context, false);
                                                    var valorTemporal = 0.0;
                                                    for (var i = 0;
                                                        i < dataGeneral.length;
                                                        i++) {
                                                      if (dataGeneral[i][
                                                                  'Fecha_Entrega']
                                                              .toString()
                                                              .split("/")[0]
                                                              .toString() ==
                                                          (index + 1)
                                                              .toString()) {
                                                        if (dataGeneral[i]
                                                                    ['Status']
                                                                .toString() ==
                                                            "ENTREGADO") {
                                                          var data = await Connections()
                                                              .updateOrderPayStateLogisticUser(
                                                                  dataGeneral[i]
                                                                      ['id']);
                                                        }
                                                      }
                                                    }
                                                    Navigator.pop(context);
                                                    await getOrders();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "MARCAR RECIBIDO",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.greenAccent),
                                                  )),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Divider(),
                                          resultValidation == "PENDIENTE"
                                              ? Container()
                                              : Text(
                                                  "Para marcar como rechazado primero llenar el campo de texto y luego aplastar el botón rechazado",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          resultValidation == "PENDIENTE"
                                              ? Container()
                                              : TextField(
                                                  controller: _rechazado,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          "Comentario de Rechazado"),
                                                ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          resultValidation == "PENDIENTE"
                                              ? Container()
                                              : TextButton(
                                                  onPressed: () async {
                                                    getLoadingModal(
                                                        context, false);
                                                    for (var i = 0;
                                                        i < dataGeneral.length;
                                                        i++) {
                                                      if (dataGeneral[i][
                                                                  'Fecha_Entrega']
                                                              .toString()
                                                              .split("/")[0]
                                                              .toString() ==
                                                          (index + 1)
                                                              .toString()) {
                                                        if (dataGeneral[i]
                                                                    ['Status']
                                                                .toString() ==
                                                            "ENTREGADO") {
                                                          var data = await Connections()
                                                              .updateOrderPayStateLogisticUserRechazado(
                                                                  dataGeneral[i]
                                                                      ['id'],
                                                                  _rechazado
                                                                      .text);
                                                          print(
                                                              _rechazado.text);
                                                        }
                                                      }
                                                    }
                                                    Navigator.pop(context);
                                                    await getOrders();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "RECHAZADO",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.redAccent),
                                                  )),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Divider(),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "SALIR",
                                                style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                            await loadData();
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 11,
                                    child: Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Flexible(
                                      child: Text(
                                    getByDay(index + 1)[1] == 0 ||
                                            (double.parse(getByDayPrice(
                                                            index + 1)[0]) -
                                                        double.parse(
                                                            getByDayPrice(
                                                                index + 1)[1]))
                                                    .toStringAsFixed(2) ==
                                                "0.00"
                                        ? "No Existe"
                                        : "${getByDay(index + 1)[0]["pagado"].toString()} \$${(double.parse(getByDayPrice(index + 1)[0]) - double.parse(getByDayPrice(index + 1)[1])).toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: getByDay(index + 1)[1] == 0
                                            ? generateColor("", "0.00")
                                            : generateColor(
                                                getByDay(index + 1)[0]["pagado"]
                                                    .toString(),
                                                (double.parse(getByDayPrice(
                                                            index + 1)[0]) -
                                                        double.parse(
                                                            getByDayPrice(
                                                                index + 1)[1]))
                                                    .toStringAsFixed(2))),
                                  ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ))
          ],
        ),
      ),
    ));
  }

  generateColor(String status, value) {
    if (value == "0.00") {
      return Colors.black;
    } else {
      switch (status.toLowerCase()) {
        case "pendiente":
          return Colors.red;
        case "pagado":
          return Colors.blue;
        case "recibido":
          return Colors.green;
        case "rechazado":
          return Colors.red;

        default:
          return Colors.black;
      }
    }
  }

  getByDay(day) {
    var resultado = {};
    int counter = 0;
    for (var i = 0; i < objetosAndFechas.length; i++) {
      if (objetosAndFechas[i]['dia'].toString() == day.toString()) {
        resultado = objetosAndFechas[i];
        counter += 1;
        setState(() {});
        break;
      }
    }

    return [resultado, counter];
  }

  getByDayPrice(day) {
    String resultadoP = "";
    double resultadoC = 0.0;

    int counter = 0;
    for (var i = 0; i < totalesPrecio.length; i++) {
      if (totalesPrecio[i]['dia'].toString() == day.toString()) {
        switch (totalesPrecio[i]['Status']) {
          case "NO ENTREGADO":
            resultadoP = "0.0";
            resultadoC =
                double.parse(totalesPrecio[i]['CostoTrans'].toString());

            break;
          case "ENTREGADO":
            resultadoP = totalesPrecio[i]['total'].toString();
            resultadoC =
                double.parse(totalesPrecio[i]['CostoTrans'].toString());

            break;
          case "NOVEDAD":
            resultadoP = totalesPrecio[i]['total'].toString();
            resultadoC +=
                double.parse(totalesPrecio[i]['CostoTrans'].toString());

            break;
          default:
            resultadoP = "0.0";
            resultadoC += 0.0;
            break;
        }

        counter += 1;
        setState(() {});
        break;
      }
      // if (totalesPrecio[i]['dia'].toString() == "11") {
      //   print(totalesPrecio[i]['Status']);
      //   switch (totalesPrecio[i]['Status']) {
      //     case "NO ENTREGADO":
      //       resultadoP = "0.0";
      //       resultadoC = totalesPrecio[i]['CostoTrans'].toString();

      //       break;
      //     case "ENTREGADO":
      //       resultadoP = totalesPrecio[i]['total'].toString();
      //       resultadoC = totalesPrecio[i]['CostoTrans'].toString();

      //       break;
      //     case "NOVEDAD":
      //       resultadoP = totalesPrecio[i]['total'].toString();
      //       resultadoC = totalesPrecio[i]['CostoTrans'].toString();

      //       break;
      //     default:
      //       resultadoP = "0.0";
      //       resultadoC = "0.0";
      //       break;
      //   }

      //   counter += 1;
      //   setState(() {});
      //   break;
      // }
    }

    return [resultadoP, resultadoC.toStringAsFixed(2), counter];
  }
}
