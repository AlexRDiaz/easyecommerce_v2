import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class WithdrawalsTransportInfo extends StatefulWidget {
  // final String id;
  final List data;
  // final Function function;

  const WithdrawalsTransportInfo({
    super.key,
    // required this.id,
    required this.data,
    // required this.function
  });

  @override
  State<WithdrawalsTransportInfo> createState() => _WithdrawalsTransportInfo();
}

class _WithdrawalsTransportInfo extends State<WithdrawalsTransportInfo> {
  var data = {};
  bool loading = true;
  // OrderInfoOperatorControllers _controllers = OrderInfoOperatorControllers();
  // final TextEditingController _statusController =
  // TextEditingController(text: "NOVEDAD RESUELTA");
  // final TextEditingController _comentarioController = TextEditingController();
  var idUser = sharedPrefs!.getString("id");
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    print(widget.data);
    // var order = widget.data;
    // // .firstWhere(
    // //     (item) => item['id'].toString() == widget.id,
    // //     orElse: () => null);

    // if (order != null) {
    //     // data = widget.data as Map ;
    //   data = order as Map;
    //     // print("data> $data");
    //     // _comentarioController.text = safeValue(data['comentario']);
    // } else {
    //   print("Error: No se encontró el pedido con el ID proporcionado.");
    // }

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    });
    setState(() {});
  }

  String safeValue(dynamic value, [String defaultValue = '']) {
    return (value ?? defaultValue).toString();
  }

  String formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -5);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    // String transportadoraNombre =
    //     data['transportadora'] != null && data['transportadora'].isNotEmpty
    //         ? data['transportadora'][0]['nombre']
    //         : 'No disponible';
    // String operadorUsername = data['operadore'] != null &&
    //         data['operadore'].isNotEmpty &&
    //         data['operadore'][0]['up_users'] != null &&
    //         data['operadore'][0]['up_users'].isNotEmpty
    //     ? data['operadore'][0]['up_users'][0]['username']
    //     : 'No disponible';

    return SizedBox.expand(
      child: Container(
        child:   Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // leading: Container(),
        centerTitle: true,
        title: Text(
          // "Historial Retiros ${widget.data['branch_name'].toString()}",
          "Historial Retiros ${widget.data[1]}",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: loading == true
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TableCalendar(
                          firstDay: DateTime(2020),
                          lastDay: DateTime(2030),
                          focusedDay: DateTime.now(),
                          calendarFormat: _calendarFormat,
                          rangeSelectionMode: _rangeSelectionMode,
                          onDaySelected: (date, focusedDay) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            // Handle page change
                          },
                          calendarBuilders: CalendarBuilders(
                            selectedBuilder: (context, date, focusedDay) {
                              return buildCell(date, focusedDay, Colors.blue);
                            },
                            todayBuilder: (context, date, focusedDay) {
                              return buildCell(date, focusedDay, Colors.red);
                            },
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                            ),
                            itemBuilder: (context, index) {
                              DateTime currentDate =
                                  _selectedDate.add(Duration(days: index));

                              return DayCard(
                                date: currentDate,
                                selectedDate: _selectedDate,
                                onTap: () {
                                  print('Día seleccionado: ${currentDate.day}');
                                },
                              );
                            },
                            itemCount: 7,
                          ),
                        ),

                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Código: ${data['users'][0]['vendedores'][0]['nombre_comercial']}-${safeValue(data['numero_orden'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Fecha Ingreso Pedido: ${extractDateFromBrackets(safeValue(data['marca_t_i'].toString()))}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Fecha de Confirmación: ${safeValue(data['fecha_confirmacion'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Marca Tiempo Envio: ${safeValue(data['marca_tiempo_envio'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Fecha Entrega: ${safeValue(data['fecha_entrega'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // // ! ***********
                        // Divider(
                        //   height: 1.0,
                        //   color: Colors.grey[200],
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.person,
                        //       color: ColorsSystem().colorSelectMenu,
                        //     ),
                        //     Text(
                        //       "  Datos Cliente ",
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 18,
                        //           color: ColorsSystem().colorSelectMenu),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Nombre Cliente: ${safeValue(data['nombre_shipping'])}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Ciudad: ${safeValue(data['ciudad_shipping'])}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // ! **********
                        // FutureBuilder<String>(
                        //   future: userNametotoConfirmOrder(
                        //       data['confirmed_by'] != null
                        //           ? data['confirmed_by']
                        //           : 0),
                        //   builder: (BuildContext context,
                        //       AsyncSnapshot<String> snapshot) {
                        //     if (snapshot.connectionState ==
                        //         ConnectionState.done) {
                        //       // Cuando el Future se complete, muestra el resultado
                        //       return Text(
                        //         "  Usuario de Confirmación: ${snapshot.data}",
                        //         style: TextStyle(
                        //             fontWeight: FontWeight.normal,
                        //             fontSize: 18),
                        //       );
                        //     } else {
                        //       // Mientras el Future se está resolviendo, muestra un indicador de carga
                        //       return CircularProgressIndicator();
                        //     }
                        //   },
                        // ),
                        // ! aqui va el ususario que confirma
                        // Text("Usuario de Confirmación:"),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Divider(
                        //   height: 1.0,
                        //   color: Colors.grey[200],
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.list,
                        //       color: ColorsSystem().colorSelectMenu,
                        //     ),
                        //     Text(
                        //       "  Detalle Pedido ",
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 18,
                        //           color: ColorsSystem().colorSelectMenu),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Status: ${safeValue(data['status'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Transportadora: ${safeValue(transportadoraNombre)}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   data['ruta'] != null &&
                        //           data['ruta'].toString() != "[]"
                        //       ? "  Ruta: ${data['ruta'][0]['titulo'].toString()}"
                        //       : "",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   data['sub_ruta'] != null &&
                        //           data['sub_ruta'].toString() != "[]"
                        //       ? "  Sub-Ruta: ${data['sub_ruta'][0]['titulo'].toString()}"
                        //       : "  Sub-Ruta: No Disponible",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Operador: ${safeValue(operadorUsername)}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Observación: ${safeValue(data['observacion'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Comentario: ${safeValue(data['comentario'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),

                        // Divider(
                        //   height: 1.0,
                        //   color: Colors.grey[200],
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.info,
                        //       color: ColorsSystem().colorSelectMenu,
                        //     ),
                        //     Text(
                        //       "  Datos Adicionales ",
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 18,
                        //           color: ColorsSystem().colorSelectMenu),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Estado Interno: ${safeValue(data['estado_interno'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   "  Estado Logístico: ${safeValue(data['estado_logistico'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),

                        // Text(
                        //   "  Estado Devolución: ${safeValue(data['estado_devolucion'].toString())}",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.normal, fontSize: 18),
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // Divider(
                        //   height: 1.0,
                        //   color: Colors.grey[200],
                        // ),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.folder,
                        //       color: ColorsSystem().colorSelectMenu,
                        //     ),
                        //     Text(
                        //       "  Archivo ",
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 18,
                        //           color: ColorsSystem().colorSelectMenu),
                        //     ),
                        //   ],
                        // ),
                        // Container(
                        //   height: 500,
                        //   width: 500,
                        //   child: Column(
                        //     children: [
                        //       data['archivo'].toString().isEmpty ||
                        //               data['archivo'].toString() == "null"
                        //           ? Container()
                        //           : Container(
                        //               margin: EdgeInsets.only(top: 20.0),
                        //               child: Image.network(
                        //                 "$generalServer${data['archivo'].toString()}",
                        //                 fit: BoxFit.fill,
                        //               )),
                        //     ],
                        //   ),
                        // ),
                        // // Otros widgets adicionales para cada elemento

                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Divider(
                        //   height: 1.0,
                        //   color: Colors.grey[200],
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),

                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.warning,
                        //       color: ColorsSystem().colorSelectMenu,
                        //     ),
                        //     Text(
                        //       "  Novedades ",
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 18,
                        //           color: ColorsSystem().colorSelectMenu),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Container(
                        //   height: 500,
                        //   width: 500,
                        //   child: ListView.builder(
                        //     itemCount: data['novedades'].length,
                        //     itemBuilder: (context, index) {
                        //       return ListTile(
                        //         title: Container(
                        //           decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(10),
                        //               color: Color.fromARGB(255, 172, 169, 169),
                        //               border: Border.all(color: Colors.black)),
                        //           child: Container(
                        //             margin: EdgeInsets.all(10),
                        //             child: Column(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.start,
                        //               crossAxisAlignment:
                        //                   CrossAxisAlignment.start,
                        //               children: [
                        //                 Text(
                        //                     style: const TextStyle(
                        //                       color: Colors.white,
                        //                     ),
                        //                     "Intento: ${data['novedades'][index]['m_t_novedad']}"),
                        //                 Text(
                        //                     style: const TextStyle(
                        //                       color: Colors.white,
                        //                     ),
                        //                     "Intento: ${data['novedades'][index]['try']}"),
                        //                 data['novedades'][index]['url_image']
                        //                             .toString()
                        //                             .isEmpty ||
                        //                         data['novedades'][index]
                        //                                     ['url_image']
                        //                                 .toString() ==
                        //                             "null"
                        //                     ? Container()
                        //                     : Container(
                        //                         margin: EdgeInsets.all(30),
                        //                         child: Image.network(
                        //                           "$generalServer${data['novedades'][index]['url_image'].toString()}",
                        //                           fit: BoxFit.fill,
                        //                         )),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //         // Otros widgets adicionales para cada elemento
                        //       );
                        //     },
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                      ],
                    ),
            ),
          ),
        ),
      ),
      // floatingActionButton: data['status'] != "NOVEDAD RESUELTA"
      //     ? FloatingActionButton.extended(
      //         onPressed: _showResolveModal,
      //         label: const Text('Resolver Novedad'),
      //         icon: const Icon(Icons.check_circle),
      //       )
      //     : null,
    )
  
      ),
    );
  }

  String extractDateFromBrackets(String input) {
    int startIndex = input.indexOf('[');
    int endIndex = input.indexOf(']');

    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      return input.substring(startIndex + 1, endIndex);
    }

    return input; // Retorna la entrada original si no hay corchetes o el formato es incorrecto
  }

  // Future<String> userNametotoConfirmOrder(userId) async {
  //   if (userId == 0) {
  //     return 'Desconocido';
  //   } else {
  //     var user =
  //         await Connections().getPersonalInfoAccountforConfirmOrderPDF(userId);
  //     if (user != null && user.containsKey('username')) {
  //       return user['username'].toString();
  //     } else {
  //       return 'Desconocido';
  //     }
  //   }
  // }

  // void _showErrorSnackBar(BuildContext context, String errorMessage) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         errorMessage,
  //         style: TextStyle(color: Color.fromRGBO(7, 0, 0, 1)),
  //       ),
  //       backgroundColor: Color.fromARGB(255, 253, 101, 90),
  //       duration: Duration(seconds: 4),
  //     ),
  //   );
  // }
  Widget buildCell(DateTime date, DateTime focusedDay, Color color) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  final DateTime date;
  final DateTime selectedDate;
  final Function onTap;

  DayCard(
      {required this.date, required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDisabled = date.isAfter(DateTime.now());

    return GestureDetector(
      onTap: isDisabled ? null : onTap as void Function()?,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
          color: isDisabled ? Colors.grey : Colors.white,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
              ),
            ),
            Positioned(
              top: 5.0,
              right: 5.0,
              child: Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Text(
                  'Notif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
