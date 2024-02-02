import 'dart:async';
import 'dart:convert';

import 'package:frontend/config/colors.dart';
import 'package:frontend/models/pedido_shopify_model.dart';
import 'package:frontend/ui/operator/withdrawals/printedguides.dart';
import 'package:frontend/ui/operator/withdrawals/table_orders_guides_sent.dart';
import 'package:frontend/ui/transport/withdrawals/customwidget.dart';
import 'package:frontend/ui/transport/withdrawals/printedguides.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/audit/audit_data_info.dart';
import 'package:frontend/ui/logistic/audit/generate_report_audit_data.dart';
import 'package:frontend/ui/transport/withdrawals/withdrawals_info.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/loading.dart';
import 'package:screenshot/screenshot.dart';

class WithdrawalsOperator extends StatefulWidget {
  const WithdrawalsOperator({super.key});

  @override
  State<WithdrawalsOperator> createState() => _WithdrawalsOperatorState();
}

class _WithdrawalsOperatorState extends State<WithdrawalsOperator> {
  // TextEditingController _search = TextEditingController();
  // List allData = [];
  // List data = [];
  // // var datavalue ;
  // bool sort = false;
  // ScreenshotController screenshotController = ScreenshotController();
  // ScrollController _scrollController = ScrollController();
  // bool paginate = false;
  // bool search = false;
  // String option = "";
  // String url = "";
  // int counterChecks = 0;
  // List optionsCheckBox = [];
  // int currentPage = 1;
  // int pageSize = 80;
  // int pageCount = 0;
  // bool isLoading = false;
  // int total = 0;
  // bool enabledBusqueda = true;
  // int totalRegistros = 0;
  // int generalValuetotal = 0;
  // late List<Map<String, dynamic>> notifications;
  // List<Map<String, dynamic>> notifications = [];

  // NumberPaginatorController paginatorController = NumberPaginatorController();

  // @override
  // void didChangeDependencies() {
  //   loadData();

  //   super.didChangeDependencies();
  // }

  // NotificationManager? notificationManager;

  @override
  void initState() {
    super.initState();

    // Obtén la instancia de NotificationManager utilizando Provider
    // !↓esto sirver↓
    // notificationManagerOperator =
        // Provider.of<NotificationManagerOperator>(context, listen: false);
    // ************************************************************************** 
    // Obtén el Stream desde la instancia de NotificationManager
    // notificationsStream = notificationManager!.notificationsStream;

    // loadData();
  }

  // @override
  // void dispose() {
  //   _notificationsController.close();
  //   super.dispose();
  // }
  @override
  void dispose() {
    // notificationManager?.dispose();
    super.dispose();
  }

  // loadData() async {
  //   isLoading = true;
  //   currentPage = 1;
  //   try {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       getLoadingModal(context, false);
  //     });

  //     setState(() {
  //       search = false;
  //     });
  //     var response = await Connections().getWarehousesforOperators();
  //     await Provider.of<NotificationManagerOperator>(context, listen: false)
  //         .updateNotifications();
  //     setState(() {
  //       data = [];
  //       data = response;
  //     });

  //     Future.delayed(const Duration(milliseconds: 500), () {
  //       Navigator.pop(context);
  //     });

  //     setState(() {
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Navigator.pop(context);

  //     _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
  //   }
  // }




  // ! no sirve el paginate 
  // paginateData() async {
  //   try {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       getLoadingModal(context, false);
  //     });

  //     setState(() {
  //       search = false;
  //     });
  //     var response = await Connections().getApprovedWarehouses();

  //     setState(() {
  //       data = [];
  //       data = response['data'];
  //     });

  //     Future.delayed(const Duration(milliseconds: 500), () {
  //       Navigator.pop(context);
  //     });
  //   } catch (e) {
  //     Navigator.pop(context);

  //     _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
  //   }
  // }

  void _showErrorSnackBar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: TextStyle(color: Color.fromRGBO(7, 0, 0, 1)),
        ),
        backgroundColor: Color.fromARGB(255, 253, 101, 90),
        duration: Duration(seconds: 4),
      ),
    );
  }

  TextEditingController searchController = TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: CalendarWidget(),
        body: Container(

        // Container(
        //     width: double.infinity,
        //     padding: EdgeInsets.all(15),
        //     color: Colors.grey[200],
        //     child:
        //         //  responsive(
        //         Column(children: [
        //       Padding(
        //         padding: const EdgeInsets.all(20.0),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             ElevatedButton(
        //                 style: ButtonStyle(
        //                     backgroundColor: MaterialStateColor.resolveWith(
        //                         (states) =>
        //                             ColorsSystem().colorPrincipalBrand)),
        //                 onPressed: () {
        //                   _mostrarVentanaEmergenteGuiasEnviadas(context);
        //                 },
        //                 child: const Text("Historial Retiros")),
        //             Align(
        //               alignment: Alignment.centerRight,
        //               child: GestureDetector(
        //                 onTap: () async {
        //                   getLoadingModal(context, false);

        //                   // // Actualiza las notificaciones
        //                   await loadData();
        //                   await Provider.of<NotificationManagerOperator>(
        //                           context,
        //                           listen: false)
        //                       .updateNotifications();
        //                   // await loadData();

        //                   // Cierra el diálogo de carga
        //                   Navigator.of(context).pop();
        //                 },
        //                 child: Container(
        //                   color: Colors.transparent,
        //                   child: const Row(
        //                     mainAxisAlignment: MainAxisAlignment.end,
        //                     crossAxisAlignment: CrossAxisAlignment.end,
        //                     children: [
        //                       Icon(
        //                         Icons.replay_outlined,
        //                         color: Colors.green,
        //                       ),
        //                       SizedBox(
        //                         width: 10,
        //                       ),
        //                       Text(
        //                         "Recargar Información",
        //                         style: TextStyle(
        //                             decoration: TextDecoration.underline,
        //                             color: Colors.green),
        //                       ),
        //                       SizedBox(
        //                         width: 10,
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       Expanded(
        //           child: Padding(
        //               padding: const EdgeInsets.all(20.0),
        //               child: Consumer<NotificationManagerOperator>(builder:
        //                   (context, NotificationManagerOperator, child) {
        //                 List<Map<String, dynamic>> notifications =
        //                     notificationManagerOperator!.notifications;
        //                 return DataTable2(
        //                     scrollController: _scrollController,
        //                     decoration: BoxDecoration(
        //                       color: Colors.white,
        //                       borderRadius:
        //                           const BorderRadius.all(Radius.circular(4)),
        //                       border: Border.all(color: Colors.blueGrey),
        //                     ),
        //                     headingRowHeight: 63,
        //                     headingTextStyle: const TextStyle(
        //                       fontWeight: FontWeight.bold,
        //                       color: Colors.black,
        //                     ),
        //                     dataTextStyle: const TextStyle(
        //                       fontSize: 12,
        //                       // fontWeight: FontWeight.bold,
        //                       color: Colors.black,
        //                     ),
        //                     columnSpacing: 2,
        //                     horizontalMargin: 2,
        //                     minWidth:
        //                         800, // Ajusta el ancho mínimo según tus necesidades
        //                     columns: [
        //                       DataColumn2(
        //                         label: Text("Bodega"),
        //                         size: ColumnSize.S,
        //                         onSort: (columnIndex, ascending) {},
        //                       ),
        //                       DataColumn2(
        //                         label: Text("Ciudad"),
        //                         size: ColumnSize.S,
        //                         onSort: (columnIndex, ascending) {},
        //                       ),
        //                       DataColumn2(
        //                         label: Text("Dirección"),
        //                         size: ColumnSize.S,
        //                         onSort: (columnIndex, ascending) {},
        //                       ),
        //                       DataColumn2(
        //                         label: Text("Referencia"),
        //                         size: ColumnSize.S,
        //                         onSort: (columnIndex, ascending) {},
        //                       ),
        //                       DataColumn2(
        //                         label: Text("Teléfono"),
        //                         size: ColumnSize.S,
        //                         onSort: (columnIndex, ascending) {},
        //                       ),
        //                       DataColumn2(
        //                         label: Text("Retirado Por"),
        //                         size: ColumnSize.S,
        //                         onSort: (columnIndex, ascending) {},
        //                       ),
        //                       DataColumn2(
        //                         label: Text("Días de Recolección"),
        //                         size: ColumnSize.S,
        //                         onSort: (columnIndex, ascending) {},
        //                       ),
        //                       DataColumn2(
        //                         label: Text("Horario de Recolección"),
        //                         size: ColumnSize.S,
        //                         onSort: (columnIndex, ascending) {},
        //                       ),
        //                     ],
        //                     rows: List<DataRow>.generate(data.length, (index) {
        //                       final color = Colors.blue[50];

        //                       return DataRow(
        //                         color: MaterialStateColor.resolveWith(
        //                             (states) => color!),
        //                         cells: getRows(index, notifications),
        //                       );
        //                     }));
        //               })))
        //     ]))
        ));
  
  }

  // @override
  // void dispose() {
  //   notificationManager?.dispose();
  //   super.dispose();
  // }

  // void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
  //   mapa.forEach((key, value) {
  //     if (value is Map) {
  //       reemplazarValor(value, nuevoValor);
  //     } else if (key is String && value == 'valor') {
  //       mapa[key] = nuevoValor;
  //     }
  //   });
  // }

  // getLengthArrayMap(List data) {
  //   var arraylength = data.length;
  //   return Text(
  //     arraylength.toString(),
  //     style: TextStyle(
  //         color: arraylength > 3
  //             ? Color.fromARGB(255, 185, 10, 10)
  //             : Colors.black),
  //   );
  // }

  // List<DataCell> getRows(int index, List<Map<String, dynamic>> notifications) {
  //   // print('Notifications: $notifications');
  //   // if (notifications != null && notifications.length > index) {
  //   Color rowColor = Colors.black;
  //   if (notifications.isEmpty) {
  //     for (var i = 0; i < data.length; i++) {
  //       notifications.add({"count": "0"});
  //     }
  //   }
  //   return [
  //     DataCell(
  //         CustomRowWithNotification(
  //           count: notifications.isNotEmpty
  //               ? notifications[index]['count'].toString()
  //               : "0",
  //           branchName: data[index]['branch_name'].toString(),
  //         ), onTap: () {
  //       // info(context, index);
  //       // _mostrarVentanaEmergente(
  //       //     context, data[index]['branch_name'].toString());
  //       _mostrarVentanaEmergenteGuiasImpresas(
  //           context,
  //           data[index]['warehouse_id'].toString(),
  //           data[index]['branch_name'].toString());
  //     }),
  //     DataCell(
  //         Text(
  //           data[index]['city'].toString(),
  //           style: TextStyle(
  //             color: rowColor,
  //           ),
  //         ), onTap: () {
  //       // info(context, index);
  //       // _mostrarVentanaEmergente(
  //       //     context, data[index]['branch_name'].toString());
  //     }),
  //     DataCell(
  //         Text(
  //           data[index]['address'].toString(),
  //           style: TextStyle(
  //             color: rowColor,
  //           ),
  //         ), onTap: () {
  //       // info(context, index);
  //     }),
  //     DataCell(
  //         Text(
  //           data[index]['reference'].toString(),
  //           style: TextStyle(
  //             color: rowColor,
  //           ),
  //         ), onTap: () {
  //       // info(context, index);
  //       // _mostrarVentanaEmergente(
  //       //     context, data[index]['branch_name'].toString());
  //     }),
  //     DataCell(
  //         Text(
  //           data[index]['customer_service_phone'].toString(),
  //           style: TextStyle(
  //             color: rowColor,
  //           ),
  //         ), onTap: () {
  //       // info(context, index);
  //       // _mostrarVentanaEmergente(
  //       //     context, data[index]['branch_name'].toString());
  //     }),
  //     DataCell(
  //         Text(
  //           data[index]['operatorNameWithdrawal'].toString(),
  //           style: TextStyle(
  //             color: rowColor,
  //           ),
  //         ), onTap: () {
  //       // info(context, index);
  //       // _mostrarVentanaEmergente(
  //       //     context, data[index]['branch_name'].toString());
  //     }),
  //     DataCell(
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             for (var day in data[index]['collection']['collectionDays'])
  //               Text(day),
  //           ],
  //         ), onTap: () {
  //       // info(context, index);
  //       // _mostrarVentanaEmergente(
  //       //     context, data[index]['branch_name'].toString());
  //     }),
  //     DataCell(
  //         Text(
  //           data[index]['collection']['collectionSchedule'].toString(),
  //           style: TextStyle(
  //             color: rowColor,
  //           ),
  //         ), onTap: () {
  //       // info(context, index);
  //       // _mostrarVentanaEmergente(
  //       //     context, data[index]['branch_name'].toString());
  //     }),
  //   ];
  //   // } else {
  //   // Return a row with the same number of cells as the columns
  //   // return List.generate(7, (index) => DataCell(Text('')));
  //   // }
  // }

  // SizedBox _dates(BuildContext context) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             TextButton(
  //                 onPressed: () async {
  //                   var results = await showCalendarDatePicker2Dialog(
  //                     context: context,
  //                     config: CalendarDatePicker2WithActionButtonsConfig(
  //                       dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
  //                       yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
  //                       selectedYearTextStyle:
  //                           TextStyle(fontWeight: FontWeight.bold),
  //                       weekdayLabelTextStyle:
  //                           TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                     dialogSize: const Size(325, 400),
  //                     value: [],
  //                     borderRadius: BorderRadius.circular(15),
  //                   );
  //                   setState(() {
  //                     if (results != null) {
  //                       String fechaOriginal = results![0]
  //                           .toString()
  //                           .split(" ")[0]
  //                           .split('-')
  //                           .reversed
  //                           .join('-')
  //                           .replaceAll("-", "/");
  //                       List<String> componentes = fechaOriginal.split('/');

  //                       String dia = int.parse(componentes[0]).toString();
  //                       String mes = int.parse(componentes[1]).toString();
  //                       String anio = componentes[2];

  //                       String nuevaFecha = "$dia/$mes/$anio";

  //                       sharedPrefs!
  //                           .setString("dateDesdeLogistica", nuevaFecha);
  //                     }
  //                   });
  //                 },
  //                 child: Text(
  //                   "DESDE: ${sharedPrefs!.getString("dateDesdeLogistica")}",
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 )),
  //             SizedBox(
  //               width: 10,
  //             ),
  //             TextButton(
  //                 onPressed: () async {
  //                   var results = await showCalendarDatePicker2Dialog(
  //                     context: context,
  //                     config: CalendarDatePicker2WithActionButtonsConfig(
  //                       dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
  //                       yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
  //                       selectedYearTextStyle:
  //                           TextStyle(fontWeight: FontWeight.bold),
  //                       weekdayLabelTextStyle:
  //                           TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                     dialogSize: const Size(325, 400),
  //                     value: [],
  //                     borderRadius: BorderRadius.circular(15),
  //                   );
  //                   setState(() {
  //                     if (results != null) {
  //                       String fechaOriginal = results![0]
  //                           .toString()
  //                           .split(" ")[0]
  //                           .split('-')
  //                           .reversed
  //                           .join('-')
  //                           .replaceAll("-", "/");
  //                       List<String> componentes = fechaOriginal.split('/');

  //                       String dia = int.parse(componentes[0]).toString();
  //                       String mes = int.parse(componentes[1]).toString();
  //                       String anio = componentes[2];

  //                       String nuevaFecha = "$dia/$mes/$anio";

  //                       sharedPrefs!
  //                           .setString("dateHastaLogistica", nuevaFecha);
  //                     }
  //                   });
  //                 },
  //                 child: Text(
  //                   "HASTA: ${sharedPrefs!.getString("dateHastaLogistica")}",
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 )),
  //             SizedBox(
  //               width: 10,
  //             ),
  //             ElevatedButton(
  //                 onPressed: () async {
  //                   setState(() {
  //                     _search.clear();
  //                   });
  //                   await loadData();
  //                 },
  //                 child: Text(
  //                   "BUSCAR",
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 )),
  //             SizedBox(
  //               width: 10,
  //             ),
  //             ElevatedButton(
  //               style: ButtonStyle(
  //                 backgroundColor: MaterialStateProperty.all(
  //                   Color.fromARGB(255, 167, 7, 7),
  //                 ),
  //               ),
  //               onPressed: () async {
  //                 setState(() {
  //                   limpiar();
  //                   loadData();
  //                 });
  //               },
  //               child: const Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     'Quitar Filtros',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             SizedBox(
  //               width: 10,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<String> userNametotoConfirmOrder(userId) async {
  //   if (userId == 0) {
  //     return 'Desconocido';
  //   } else {
  //     var user =
  //         await Connections().getPersonalInfoAccountforConfirmOrderPDF(userId);
  //     // Verifica si user es nulo
  //     if (user != null && user.containsKey('username')) {
  //       return user['username'].toString();
  //     } else {
  //       // Maneja el caso de usuario nulo o sin 'username'
  //       return 'Desconocido';
  //     }
  //   }
  // }

  // void limpiar() {
  //   searchController.text = "";
  //   // arrayFiltersAnd.clear();
  //   // sortFieldDefaultValue = "marca_t_i:DESC";
  //   _search.clear();
  // }

  // Future<dynamic> info(BuildContext context, int index) {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           content: Container(
  //             width: MediaQuery.of(context).size.width,
  //             height: MediaQuery.of(context).size.height,
  //             child: Column(
  //               children: [
  //                 Align(
  //                   alignment: Alignment.centerRight,
  //                   child: GestureDetector(
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Icon(Icons.close),
  //                   ),
  //                 ),
  //                 Container(
  //                     width: 300,
  //                     height: 600,
  //                     child: WithdrawalsTransportInfo(
  //                       data: data[index].values.toList(),
  //                       // function: loadData(),
  //                     ))
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  // void _mostrarVentanaEmergente(BuildContext context, String warehouseName) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Container(
  //           width: 800,
  //           height: 500,
  //           child: CalendarWidget(warehouseName: warehouseName),
  //         ),
  //       );
  //     },
  //   );
  // }

//   void _mostrarVentanaEmergenteGuiasImpresas(
//       BuildContext context, String idWarehouse, String warehouseName) {
//     double width =
//         MediaQuery.of(context).size.width * 0.9; // 80% del ancho de la pantalla
//     double height =
//         MediaQuery.of(context).size.height * 0.9; // 60% del alto de la pantalla

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Container(
//             width: width,
//             height: height,
//             child: PrintedGuidesOperator(
//                 idWarehouse: idWarehouse, warehouseName: warehouseName),
//           ),
//         );
//       },
//     );
//   }

//   void _mostrarVentanaEmergenteGuiasEnviadas(BuildContext context) {
//     double width =
//         MediaQuery.of(context).size.width * 0.8; // 80% del ancho de la pantalla
//     double height =
//         MediaQuery.of(context).size.height * 0.8; // 60% del alto de la pantalla

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Container(
//             width: width,
//             height: height,
//             child: TableOrdersGuidesSentOperator(),
//           ),
//         );
//       },
//     );
//   }
// }

// class CustomRowWithNotification extends StatelessWidget {
//   final String count;
//   final String branchName;

//   CustomRowWithNotification({required this.count, required this.branchName});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 8.0),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Icon(
//                 Icons.warehouse,
//                 size: 30.0,
//                 color: ColorsSystem()
//                     .colorBlack, // ajusta el tamaño del icono según sea necesario
//               ),
//               if (count != "0")
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   child: Container(
//                     padding: EdgeInsets.all(4.0),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Color.fromARGB(255, 6, 71, 249),
//                     ),
//                     child: Text(
//                       count.toString(),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         SizedBox(width: 4.0),
//         Text(
//           branchName,
//           style: TextStyle(
//             color: Colors.black, // ajusta el color según sea necesario
//           ),
//         ),
//       ],
//     );
//   }
// }
}