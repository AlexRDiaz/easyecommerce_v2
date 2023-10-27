import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/transport/payment_vouchers_transport/create_report_transport.dart';
import 'package:frontend/ui/transport/payment_vouchers_transport/info_payment_voucher.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class PaymentVouchersTransport2 extends StatefulWidget {
  const PaymentVouchersTransport2({super.key});

  @override
  State<PaymentVouchersTransport2> createState() =>
      _PaymentVouchersTransportState2();
}

class _PaymentVouchersTransportState2 extends State<PaymentVouchersTransport2> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();
  List<DateTime?> _dates = [];
  bool sort = false;
  List dataGeneral = [];
  double totalProceeds = 0.0;
  double totalShippingCost = 0.0;
  double total = 0.0;
  String statusTransportadoraShipping = '';
  var idTSC;
  bool exists = false;

//
  List data = [];
  List daysM = [];
  int numDays = 31;
  List<String> meses = [];
  List<String> years = [];
  String? selectedValueYear = DateTime.now().year.toString();
  String? selectedValueMonth = DateTime.now().month.toString();
  List<Map> selectedChecks = [];
  int counterChecks = 0;
  // List data = [];
  var selectedItem;
  List ordersByDate = [];
  int idTransp = 0;
  bool isToday = false;
  String? currentDayDate = DateTime.now().day.toString(); //
  List dataTodayTSC = [];
  var getReport = CreateReportTransport();

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    // print("today day: $currentDayDate");

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
      if (partes.length == 2 && partes[1] == selectedValueMonth) {
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

    setState(() {
      idTSC = 0;
      totalProceeds = 0.0;
      totalShippingCost = 0.0;
      total = 0.0;
      statusTransportadoraShipping = 'PENDIENTE';
    });

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  getOrders() async {
    selectedChecks = [];

    idTransp = int.parse(sharedPrefs!.getString("idTransportadora").toString());
    // var fecha = sharedPrefs!.getString("dateOperatorState");
    var fecha =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    var fechaFormatted =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

    //TSC:transportadoras_shipping_cost
    //TPT:transaccion_pedido_transportadora

    //for todayData
    var responseTodayTSC =
        await Connections().getTrasportadoraShippingCostByDate(idTransp, fecha);

    dataTodayTSC = responseTodayTSC;
    if (dataTodayTSC.isNotEmpty) {
      // print("YA existen TSC para hoy");
      idTSC = dataTodayTSC[0]['id'];
    } else {
      // print("NO existen TSC para hoy");
    }

    //no lo se, creo que hay que hacer que esto funcione para que si existe no hacer el data.add y ni la consulta de ordersDate

    List<String> dayDate = [];
    dayDate.add(fechaFormatted);
    var ordersDate = await Connections()
        .getTransaccionesOrdersByTransportadorasDates(idTransp, dayDate);

    if (ordersDate.isNotEmpty) {
      // print("Transacciones NO esta vacio");

      var dataOrders = ordersDate['data'];
      totalShippingCost = ordersDate['total'];

      for (var pedido in dataOrders) {
        if (pedido["status"] == "ENTREGADO") {
          double precioTotal = double.parse(pedido["precio_total"].toString());
          totalProceeds += precioTotal;
        }
      }
      totalProceeds = double.parse((totalProceeds).toStringAsFixed(2));
      totalShippingCost = double.parse((totalShippingCost).toStringAsFixed(2));
      total = totalProceeds - totalShippingCost;
      total = double.parse((total).toStringAsFixed(2));
    } else {
      // print("Transacciones esta vacio");
    }

    var responseTSC = await Connections().getOrdersSCalendarLaravel(
        idTransp,
        selectedValueMonth.toString().split("-")[1].toString(),
        selectedValueYear.toString());

    setState(() {
      if (responseTSC != null) {
        dataGeneral = responseTSC;
      } else {
        dataGeneral = [];
      }
    });

    data = responseTSC;

    data.add({
      // "day": currentDayDate,
      "id": "new123id",
      "fecha": fechaFormatted,
      "status": statusTransportadoraShipping,
      "daily_proceeds": totalProceeds,
      "daily_shipping_cost": totalShippingCost,
      "daily_total": total,
      "rejected_reason": "",
      "url_proof_payment": "",
    });

    if (data.isNotEmpty) {
      //

      for (Map pedido in responseTSC) {
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

      for (var i = 0; i < responseTSC.length; i++) {
        daysM.add({
          "day": responseTSC[i]['fecha']
              .toString()
              .split("-")[2]
              .replaceAll(RegExp('^0+'), ''),
          "id": responseTSC[i]['id'],
          "fecha": responseTSC[i]['fecha'],
          "status": responseTSC[i]['status'],
          "daily_proceeds": responseTSC[i]['daily_proceeds'],
          "daily_shipping_cost": responseTSC[i]['daily_shipping_cost'],
          "daily_total": responseTSC[i]['daily_total'],
          "rejected_reason": responseTSC[i]['rejected_reason'],
          "url_proof_payment": responseTSC[i]['url_proof_payment'],
          "check": check,
        });
      }
    }

    // print(daysM);
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
                  height: 5,
                ),
                const Text(
                  "Seleccione los filtros:",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
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
                  height: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: selectedValueMonth != null
                              ? () async {
                                  getLoadingModal(context, false);
                                  daysM = [];
                                  selectedChecks = [];
                                  counterChecks = 0;
                                  await getOrders();
                                  // await getTodayOrders();
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
                                      setState(() {
                                        selectedItem = [];
                                        counterChecks = 0;
                                      });
                                      // loadData();
                                      getLoadingModal(context, false);
                                      daysM = [];
                                      selectedChecks = [];
                                      counterChecks = 0;
                                      // await getOrders();
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
                                  onPressed: () {
                                    // showSelectFilterReportDialog(context);
                                    getOrdersPerDay(idTransp, selectedChecks);
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
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Wrap(
                  children: [
                    ...List.generate(numDays, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: GestureDetector(
                          onTap: () async {
                            showInfoDetails(
                                context, getByDay2(index + 1)[0]["id"]);
                          },
                          child: Container(
                            width: 180,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              // color: const Color(0xFFEAF1FB),
                              color: const Color.fromARGB(255, 255, 255, 255),
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

                                          //delete later
                                          print("selecteds: $selectedChecks");
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
                                            text: getByDay2(index + 1)[0]
                                                        ["status"]
                                                    ?.toString() ??
                                                "No existe",
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
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
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

  generateColor(String status) {
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
    day_dates.add(dataDay);

    var orders = await Connections()
        .getTransaccionesOrdersByTransportadorasDates(
            transportadora, day_dates);
    if (orders.isNotEmpty && orders.containsKey('data')) {
      var ordersData = orders['data'];

      for (int i = 0; i < ordersData.length; i++) {
        int idOrder =
            int.parse(ordersData[i]["pedidos_shopify"]["id"].toString());
        // print("to update: $idOrder");

        if (statusR == "PAGADO") {
          // print("PAGADO");
          var updateState = await Connections().updatenueva(idOrder.toString(),
              {"estado_pago_logistica": "PAGADO", "url_p_l_foto": comment});
        } else if (statusR == "PENDIENTE") {
          // print("PENDIENTE");
          var updateState = await Connections().updatenueva(idOrder.toString(),
              {"estado_pago_logistica": "PENDIENTE", "url_p_l_foto": ""});
        }
      }
    } else {
      print("No existen orders to update");
    }
  }

  Future<bool> checkFileExistence(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      // Maneja cualquier error, por ejemplo, si no se puede conectar al servidor.
      return false;
    }
  }

  void showInfoDetails(context, id) async {
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
      var fechaSelect = dataDay[0]['fecha'];
      var status = dataDay[0]['status'].toString();
      TextEditingController _rechazado = TextEditingController();

      _rechazado.text = comentario;
      var proof = "";
      if (await checkFileExistence(
          '$generalServerApiLaravel${dataDay[0]['url_proof_payment']}')) {
        proof =
            "$generalServerApiLaravel${dataDay[0]['url_proof_payment'].toString()}";
        // print("Imagen encontrada en Laravel");
      } else if (await checkFileExistence(
          '$generalServer${dataDay[0]['url_proof_payment']}')) {
        proof = "$generalServer${dataDay[0]['url_proof_payment'].toString()}";
        // print("Imagen no encontrada en Laravel, usando el servidor general");
      }
      // try {
      //   // Intenta cargar la imagen desde el servidor Laravel
      //   proof =
      //       "$generalServerApiLaravel${dataDay[0]['url_proof_payment'].toString()}";
      //   print("Imagen encontrada en Laravel");
      // } catch (e) {
      //   // Si falla, carga la imagen desde el servidor general
      //   proof = "$generalServer${dataDay[0]['url_proof_payment'].toString()}";
      //   print("Imagen no encontrada en Laravel, usando el servidor general");
      // }

      print("URL de la imagen: $proof");

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: 700,
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
                  Text("Estado Pago Logistica: $status"),
                  const Divider(),
                  const Text(
                    "Comprobante:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ((status == "PAGADO" ||
                              status == "PENDIENTE" ||
                              status == "RECHAZADO") &&
                          (dataDay[0]['url_proof_payment'] != null &&
                              dataDay[0]['url_proof_payment'] != ""))
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              iconSize: 20,
                              onPressed: () async {
                                getLoadingModal(context, false);

                                var responseUptDelete = await Connections()
                                    .updateGeneralTransportadoraShippingCostLaravel(
                                        id, {
                                  "status": "PENDIENTE",
                                  "url_proof_payment": ""
                                });

                                daysM = [];
                                selectedChecks = [];
                                counterChecks = 0;
                                await getOrders();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.restore_from_trash_outlined,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  (dataDay[0]['url_proof_payment'] == null ||
                          dataDay[0]['url_proof_payment'] == "")
                      ? Container()
                      : SizedBox(
                          width: 650,
                          height: 500,
                          child: ListView(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    proof,
                                    // "$generalServer${dataDay[0]['url_proof_payment'].toString()}",
                                    //generalServerApiLaravel
                                    // "$generalServerApiLaravel/storage${dataDay[0]['url_proof_payment'].toString()}",

                                    fit: BoxFit.fill,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  ((status == "PAGADO" ||
                              status == "PENDIENTE" ||
                              status == "RECHAZADO") &&
                          (dataDay[0]['url_proof_payment'] == null ||
                              dataDay[0]['url_proof_payment'] == ""))
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery);

                                if (image!.path.isNotEmpty &&
                                    image!.path.toString() != "null") {
                                  getLoadingModal(context, false);

                                  // var responseI =
                                  //     await Connections().postDoc(image);
                                  // print("responseILaravel: $responseI[1]");

                                  var responseIL =
                                      await Connections().postDocLaravel(image);
                                  print("responseILaravel: $responseIL");
                                  //create o update EN LA NUEVA TABLA
                                  if (id == "new123id") {
                                    //createTraspShippingCost
                                    // print("createTraspShippingCost");

                                    var response = await Connections()
                                        .createTraspShippingCost(
                                      idTransp,
                                      totalShippingCost,
                                      totalProceeds,
                                      total,
                                      // responseI[1]
                                      responseIL,
                                    );
                                  } else {
                                    //update
                                    // print("TSC to update");
                                    // print(
                                    //     "totalShippingCost: $totalShippingCost; totalProceeds: $totalProceeds; total: $total");
                                    var responseUpt = await Connections()
                                        .updateGeneralTransportadoraShippingCostLaravel(
                                            id, {
                                      "status": "PAGADO",
                                      "daily_shipping_cost": totalShippingCost,
                                      "daily_proceeds": totalProceeds,
                                      "daily_total": total,
                                      "rejected_reason": "",
                                      // "url_proof_payment": responseI[1]
                                      "url_proof_payment": responseIL
                                    });
                                    //
                                  }

                                  // updateOrdersPerDay(idTransp, fechaSelect,
                                  //     "PAGADO", responseI[1]);
                                  updateOrdersPerDay(idTransp, fechaSelect,
                                      "PAGADO", responseIL);

                                  daysM = [];
                                  selectedChecks = [];
                                  counterChecks = 0;
                                  await getOrders();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  print("No img");
                                }
                              },
                              //#4355B9
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4355B9),
                              ),
                              child: const Text(
                                "REALIZAR PAGO",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
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
      // }
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
