import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/proof_payment/create_report_proof.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/amount_row.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../helpers/navigators.dart';
import '../../widgets/loading.dart';

class ProofPayment2 extends StatefulWidget {
  const ProofPayment2({super.key});

  @override
  State<ProofPayment2> createState() => _ProofPaymentState2();
}

class _ProofPaymentState2 extends State<ProofPayment2> {
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
  List daysM = [];
  int numDays = 31;
  List<String> years = [];
  String? selectedValueYear = DateTime.now().year.toString();
  String? selectedValueMonth2 = DateTime.now().month.toString();
  List<Map> selectedChecks = [];
  List data = [];
  int counterChecks = 0;
  var selectedItem;
  var getReport = CreateReportProof();
  List ordersByDate = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  getOrders() async {
    selectedChecks = [];

    var responseL = await Connections().getOrdersSCalendarLaravel(
        selectedValueTransportator.toString().split("-")[1].toString(),
        selectedValueMonth.toString().split("-")[1].toString(),
        selectedValueYear.toString());

    setState(() {
      if (responseL != null) {
        dataGeneral = responseL;
      } else {
        dataGeneral = [];
      }
    });
    data = responseL;
    if (data.isNotEmpty) {
      for (Map pedido in responseL) {
        selectedItem = selectedChecks
            .where((elemento) => elemento["id"] == pedido["id"])
            .toList();
        if (selectedItem.isNotEmpty) {
          pedido['check'] = true;
        } else {
          pedido['check'] = false;
        }
      }
      bool check = selectedItem.isNotEmpty;

      for (var i = 0; i < responseL.length; i++) {
        daysM.add({
          "day": responseL[i]['fecha']
              .toString()
              .split("-")[2]
              .replaceAll(RegExp('^0+'), ''),
          "id": responseL[i]['id'],
          "fecha": responseL[i]['fecha'],
          "status": responseL[i]['status'],
          "daily_proceeds": responseL[i]['daily_proceeds'],
          "daily_shipping_cost": responseL[i]['daily_shipping_cost'],
          "daily_total": responseL[i]['daily_total'],
          "rejected_reason": responseL[i]['rejected_reason'],
          "url_proof_payment": responseL[i]['url_proof_payment'],
          "check": check,
        });
      }
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

    meses = [
      "Enero-1",
      "Febrero-2",
      "Marzo-3",
      "Abril-4",
      "Mayo-5",
      "Junio-6",
      "Julio-7",
      "Agosto-8",
      "Septiembre-9",
      "Octubre-10",
      "Noviembre-11",
      "Diciembre-12",
    ];

    for (String mes in meses) {
      List<String> partes = mes.split('-');
      if (partes.length == 2 && partes[1] == selectedValueMonth2) {
        selectedValueMonth = mes;
        break;
      }
    }

    years.clear();
    var selectedYear = int.parse(selectedValueYear ?? '');
    var startYear = 2023;
    var endYear = 0;

    if (selectedYear != null) {
      endYear = selectedYear + 5;

      for (int i = startYear; i <= endYear; i++) {
        years.add(i.toString());
      }
    }

    var responsetransportadoras = await Connections().getTransportadoras();
    transportatorList = responsetransportadoras['transportadoras'];
    for (var i = 0; i < transportatorList.length; i++) {
      setState(() {
        if (transportatorList != null) {
          transportator.add('${transportatorList[i]}');
        }
      });
    }
/*
    transportatorList = await Connections().getAllTransportators();
    for (var i = 0; i < transportatorList.length; i++) {
      setState(() {
        if (transportatorList != null) {
          transportator.add(
              '${transportatorList[i]['attributes']['Nombre']}-${transportatorList[i]['id']}');
        }
      });
    }
*/
    Future.delayed(const Duration(milliseconds: 500), () {
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
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Seleccione los filtros:",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonHideUnderline(
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
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ))
                                .toList(),
                            value: selectedValueTransportator,
                            onChanged: (value) async {
                              setState(() {
                                selectedValueTransportator = value as String;
                              });
                            },
                            //This to clear the search value when you close the menu
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {}
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonHideUnderline(
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
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ))
                                .toList(),
                            value: selectedValueMonth,
                            onChanged: (value) async {
                              setState(() {
                                selectedValueMonth = value as String;
                              });
                            },
                            //This to clear the search value when you close the menu
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {}
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'AÑO',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.bold),
                          ),
                          items: years
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))
                              .toList(),
                          value: selectedValueYear,
                          onChanged: (value) async {
                            setState(() {
                              selectedValueYear = value as String;
                            });
                            // print('selectedValueYear: $selectedValueYear');
                          },
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {}
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: selectedValueTransportator != null
                              ? () async {
                                  getLoadingModal(context, false);
                                  daysM = [];
                                  selectedChecks = [];
                                  counterChecks = 0;
                                  await getOrders();
                                  Navigator.pop(context);
                                }
                              : null,
                          child: const Text(
                            "Buscar",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Text(
                          counterChecks > 0
                              ? "Seleccionados: $counterChecks"
                              : "",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        counterChecks > 0
                            ? Visibility(
                                visible: true,
                                child: IconButton(
                                  iconSize: 20,
                                  onPressed: () async {
                                    {
                                      // setState(() {
                                      //   selectedItem = [];
                                      //   counterChecks = 0;
                                      // });
                                      // loadData();
                                      getLoadingModal(context, false);
                                      daysM = [];
                                      selectedChecks = [];
                                      counterChecks = 0;
                                      await getOrders();
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          width: 10,
                        ),
                        counterChecks > 0
                            ? Visibility(
                                visible: true,
                                child: ElevatedButton(
                                  onPressed: counterChecks > 0
                                      ? () async {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Atención'),
                                                content:
                                                    const SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          '¿Está seguro de actualizar el estado de los comprobantes?'),
                                                      Text(''),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child:
                                                        const Text('Cancelar'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child:
                                                        const Text('Aceptar'),
                                                    onPressed: () async {
                                                      for (var i = 0;
                                                          i <
                                                              selectedChecks
                                                                  .length;
                                                          i++) {
                                                        if (selectedChecks[i]
                                                                ['id']
                                                            .toString()
                                                            .isNotEmpty) {
                                                          // print(
                                                          //     selectedChecks[i]
                                                          //         ['id']);
                                                          var response = await Connections()
                                                              .updateTransportadorasShippingCostLaravel(
                                                                  "DEPOSITO REALIZADO",
                                                                  selectedChecks[
                                                                              i]
                                                                          ['id']
                                                                      .toString());

                                                          //update estado_pago_logistica  a todos los pedidos en estas fechas
                                                          updateOrdersPerDay(
                                                              selectedValueTransportator
                                                                  .toString()
                                                                  .split("-")[1]
                                                                  .toString(),
                                                              selectedChecks,
                                                              "DEPOSITO REALIZADO",
                                                              "");

                                                          counterChecks = 0;
                                                        }
                                                      }

                                                      daysM = [];
                                                      selectedChecks = [];
                                                      counterChecks = 0;
                                                      await getOrders();
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 27, 47, 88),
                                  ),
                                  child: const Text(
                                    "DEPOSITO REALIZADO",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          width: 20,
                        ),
                        counterChecks > 0
                            ? Visibility(
                                visible: true,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // showSelectFilterReportDialog(context);
                                    getOrdersPerDay(
                                        selectedValueTransportator
                                            .toString()
                                            .split("-")[1]
                                            .toString(),
                                        selectedChecks);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 58, 163, 81),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        IconData(0xf6df,
                                            fontFamily: 'MaterialIcons'),
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Descargar reporte",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Wrap(
                  children: [
                    ...List.generate(
                      numDays,
                      (index) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: GestureDetector(
                          onTap: () async {
                            showInfoDetails(
                                context, getByDay2(index + 1)[0]["id"]);
                            // print(getByDay2(index + 1)[0]["id"]);
                          },
                          child: Container(
                            width: 180,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              // color: const Color(0xFFEAF1FB),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        child: Text(
                                          (index + 1).toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Checkbox(
                                        value: getByDay2(index + 1)[0]
                                                ['check'] ??
                                            false,
                                        onChanged: (value) {
                                          setState(() {
                                            getByDay2(index + 1)[0]['check'] =
                                                value;
                                          });
                                          if (getByDay2(index + 1)[0]['id'] !=
                                              null) {
                                            if (value!) {
                                              selectedChecks.add({
                                                "id": getByDay2(index + 1)[0]
                                                    ['id']
                                              });
                                              counterChecks++;
                                            } else {
                                              selectedChecks.removeWhere(
                                                  (element) =>
                                                      element['id'] ==
                                                      getByDay2(index + 1)[0]
                                                          ['id']);
                                              counterChecks--;
                                            }
                                          }
                                          // print("selecteds: $selectedChecks");
                                        },
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                "${getByDay2(index + 1)[0]["status"]?.toString() ?? "No existe"}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: generateColor(
                                                  getByDay2(index + 1)[0]
                                                              ["status"]
                                                          ?.toString() ??
                                                      "No existe"),
                                            ),
                                          ),
                                          const TextSpan(text: "\n"),
                                          if (getByDay2(index + 1)[0]
                                                  ["daily_proceeds"] !=
                                              null)
                                            TextSpan(
                                              text:
                                                  "Valores Recibidos: \$${getByDay2(index + 1)[0]["daily_proceeds"].toString()}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          const TextSpan(text: "\n"),
                                          if (getByDay2(index + 1)[0]
                                                  ["daily_shipping_cost"] !=
                                              null)
                                            TextSpan(
                                              text:
                                                  "Costo Entrega: \$${getByDay2(index + 1)[0]["daily_shipping_cost"].toString()}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          const TextSpan(text: "\n"),
                                          if (getByDay2(index + 1)[0]
                                                  ["daily_total"] !=
                                              null)
                                            TextSpan(
                                              text:
                                                  "Total: \$${getByDay2(index + 1)[0]["daily_total"].toString()}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 7, 1, 181),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    /*
                                      child: Text(
                                    // "${getByDay2(index + 1)[0]["status"].toString()} \n \$${getByDay2(index + 1)[0]["total"].toString()}",
                                    "${getByDay2(index + 1)[0]["status"]?.toString() ?? "No existe"} \n${getByDay2(index + 1)[0]["daily_proceeds"] != null ? "Valores Recibidos: \$${getByDay2(index + 1)[0]["daily_proceeds"].toString()}" : ""} \n${getByDay2(index + 1)[0]["daily_shipping_cost"] != null ? "Costo Entrega: \$${getByDay2(index + 1)[0]["daily_shipping_cost"].toString()} " : ""} \n${getByDay2(index + 1)[0]["daily_total"] != null ? "Total: \$${getByDay2(index + 1)[0]["daily_total"].toString()}" : ""}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  */
                                  )
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

  getByDay2(day) {
    var resultado = {};
    for (var i = 0; i < daysM.length; i++) {
      if (daysM[i]['day'].toString() == day.toString()) {
        resultado = daysM[i];
        setState(() {});
        break;
      }
    }
    //print("getByDay2: $resultado");
    return [resultado];
  }

  getInfoDay(id) {
    var resultado = {};
    for (var i = 0; i < daysM.length; i++) {
      if (daysM[i]['id'].toString() == id.toString()) {
        resultado = daysM[i];
        setState(() {});
        break;
      }
    }
    //print("getByDay2: $resultado");
    return [resultado];
  }

  // generateColor(String status, value) {
  generateColor(String status) {
    // if (value == "0.00") {
    //   return Colors.black;
    // } else {
    switch (status.toLowerCase()) {
      case "pendiente":
        return Colors.red;
      case "pagado":
        return Colors.blue;
      case "recibido":
        return Colors.green;
      case "rechazado":
        return Colors.red;
      case "deposito realizado":
        return const Color.fromARGB(255, 186, 171, 35);

      default:
        return Colors.black;
    }
    // }
  }

  getOrdersPerDay(transportadora, selectedIds) async {
    var dataDay;
    List<String> dayDates = [];
    for (var element in selectedIds) {
      dataDay = getInfoDay(element["id"]);
      if (dataDay != null && dataDay.isNotEmpty) {
        dayDates.add(dataDay[0]['fecha']);
      }
    }
    var orders = await Connections()
        .getTransaccionesOrdersByTransportadorasDates(transportadora, dayDates);
    if (dataDay != null && orders.isNotEmpty) {
      getReport.generateExcelFileWithData(orders);
    } else {
      // print("No existen datos con este filtro");
    }
  }

  updateOrdersPerDay(transportadora, fecha, statusR, comment) async {
    var dataDay = fecha;
    ordersByDate = [];
    List<String> day_dates = [];

    if (statusR == "DEPOSITO REALIZADO") {
      for (var element in fecha) {
        dataDay = getInfoDay(element["id"]);
        if (dataDay != null && dataDay.isNotEmpty) {
          day_dates.add(dataDay[0]['fecha']);
        }
      }
    } else {
      day_dates.add(dataDay);
    }
    var orders = await Connections()
        .getTransaccionesOrdersByTransportadorasDates(
            transportadora, day_dates);
    orders = orders['data'];

    for (int i = 0; i < orders.length; i++) {
      int idOrder = int.parse(orders[i]["pedidos_shopify"]["id"].toString());
      if (statusR == "RECIBIDO") {
        var updateState = await Connections()
            .updateOrderStatusPagoLogisticaLaravel(idOrder, statusR);
      } else if (statusR == "RECHAZADO") {
        var updateState = await Connections()
            .updateOrderStatusPagoLogisticaRechazadoLaravel(
                idOrder, statusR, comment);
      } else if (statusR == "DEPOSITO REALIZADO") {
        var updateState = await Connections()
            .updateOrderStatusPagoLogisticaLaravel(idOrder, statusR);
      }
    }
  }

  void showInfoDetails(context, id) {
    // print("id income: $id");

    if (id != null) {
      List<Map<String, dynamic>> dataDay;

      dataDay = getInfoDay(id).cast<Map<String, dynamic>>();
      // print("dataDay: $dataDay");
      var valoresRecibidos =
          double.parse(dataDay[0]['daily_proceeds'].toString());
      var costoEntrega =
          double.parse(dataDay[0]['daily_shipping_cost'].toString());
      var total = double.parse(dataDay[0]['daily_total'].toString());
      var comentario = dataDay[0]['rejected_reason'] == null
          ? ""
          : dataDay[0]['rejected_reason'].toString();
      var fecha = dataDay[0]['fecha'];
      var status = dataDay[0]['status'].toString();
      TextEditingController _rechazado = TextEditingController();

      _rechazado.text = comentario;

      if (status == "PENDIENTE" && dataDay[0]['url_proof_payment'] == null) {
        AwesomeDialog(
          width: 500,
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Se requiere que el Comprobante se encuentre en estado Pagado',
          desc: '',
          btnCancel: Container(),
          btnOkText: "Aceptar",
          btnOkColor: colors.colorGreen,
          btnCancelOnPress: () {},
          btnOkOnPress: () {},
        ).show();
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Container(
                width: 500,
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: [
                    const Text(
                      "Detalles",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text("Valores Recibidos: \$$valoresRecibidos"),
                    Text("Costo Entrega: \$$costoEntrega"),
                    Text("Total: \$$total"),
                    const Divider(),
                    status != "DEPOSITO REALIZADO"
                        ? Visibility(
                            visible: true,
                            child: Column(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    getLoadingModal(context, false);
                                    var data = await Connections()
                                        .updateTransportadorasShippingCostLaravel(
                                            "RECIBIDO", id);

                                    //update estado_pago_logistica  a todos los pedidos en estas fechas
                                    updateOrdersPerDay(
                                        selectedValueTransportator
                                            .toString()
                                            .split("-")[1]
                                            .toString(),
                                        fecha,
                                        "RECIBIDO",
                                        "");

                                    daysM = [];
                                    selectedChecks = [];
                                    counterChecks = 0;
                                    await getOrders();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "MARCAR RECIBIDO",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 72, 186, 131),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Divider(),
                                const Text(
                                  "Para marcar como rechazado primero llenar el campo de texto y luego aplastar el botón rechazado",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  controller: _rechazado,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    hintText: "Comentario de Rechazado",
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextButton(
                                  onPressed: () async {
                                    getLoadingModal(context, false);
                                    var data = await Connections()
                                        .updateTransportadorasShippingCostRechazadoLaravel(
                                            id, _rechazado.text);

                                    //update estado_pago_logistica  a todos los pedidos en estas fechas
                                    updateOrdersPerDay(
                                        selectedValueTransportator
                                            .toString()
                                            .split("-")[1]
                                            .toString(),
                                        fecha,
                                        "RECHAZADO",
                                        _rechazado.text);

                                    daysM = [];
                                    selectedChecks = [];
                                    counterChecks = 0;
                                    await getOrders();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "RECHAZADO",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    const Divider(),
                    const Text(
                      "Comprobante:",
                      style: TextStyle(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    dataDay[0]['url_proof_payment'] == null
                        ? Container()
                        : SizedBox(
                            width: 430,
                            height: 400,
                            child: ListView(
                              children: [
                                Image.network(
                                  "$generalServer${dataDay[0]['url_proof_payment'].toString()}",
                                  // fit: BoxFit.none,
                                  fit: BoxFit.fill,
                                ),
                              ],
                            ),
                          ),
                    const Divider(),
                    const SizedBox(
                      height: 5,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "SALIR",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            );
          },
        );
      }
    } else {
      // print("No existen datos");
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'No existen datos',
        desc: '',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: colors.colorGreen,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
    }
  }
}
