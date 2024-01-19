// import 'package:data_table_2/data_table_2.dart';
// import 'package:flutter/material.dart';
// import 'package:frontend/connections/connections.dart';
// import 'package:frontend/helpers/responsive.dart';
// import 'package:frontend/ui/logistic/transactions/transactionRollback.dart';
// import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
// import 'package:frontend/ui/widgets/transport/data_table_model.dart';
// import 'dart:async';

// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// class Transactions extends StatefulWidget {
//   const Transactions({super.key});

//   @override
//   State<Transactions> createState() => _TransactionsState();
// }

// class _TransactionsState extends State<Transactions> {
//   List data = [];
//   String start = "";
//   String end = "";
//   List arrayFiltersAnd = [];

//   List<String> listOrigen = [
//     'TODO',
//     'RECAUDO',
//     'ENVIO',
//     'REFERENCIADO',
//     'DEVOLUCION',
//     'REEMBOLSO'
//   ];
//   List<Map> listToRollback = [];
//   TextEditingController searchController = TextEditingController();
//   TextEditingController idRollbackTransaction = TextEditingController();

//   TextEditingController origenController = TextEditingController(text: "TODO");

//   loadData() async {
//     try {
//       var response = await Connections().last30rows();

//       setState(() {
//         data = response;
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Future<void> didChangeDependencies() async {
//     loadData();
//     super.didChangeDependencies();
//   }

//   filterData() async {
//     try {
//       var response = await Connections().getTransactionsByDate(
//           start, end, searchController.text, arrayFiltersAnd);

//       setState(() {
//         data = response;
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//           width: double.infinity,
//           child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(children: [
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   color: Colors.grey.withOpacity(0.3),
//                   padding: EdgeInsets.all(10),
//                   child: responsive(
//                       Row(
//                         children: [
//                           Container(
//                             width: MediaQuery.of(context).size.width * 0.3,
//                             child: _modelTextField(
//                                 text: "Buscar por codigo",
//                                 controller: searchController),
//                           ),
//                           SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: () {
//                               _showDatePickerModal(context);
//                             },
//                             child: Text('Seleccionar fechas'),
//                           ),
//                           SizedBox(width: 10),
//                           Container(
//                             padding: const EdgeInsets.only(left: 15, right: 5),
//                             child: Text(
//                               "Registros: ${data.length}",
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black),
//                             ),
//                           ),
//                           TextButton(
//                               onPressed: () => RollbackInputDialog(context),
//                               child: Text("Restaurar")),
//                           Spacer(),
//                           refreshButton(),
//                         ],
//                       ),
//                       Container(),
//                       context),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: DataTableModelPrincipal(
//                         columnWidth: 1200,
//                         columns: getColumns(),
//                         rows: buildDataRows(data)),
//                   ),
//                 ),
//               ]))),
//     );
//   }

//   Align refreshButton() {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: GestureDetector(
//         onTap: () async {
//           await loadData();
//         },
//         child: Container(
//           height: 45,
//           margin: const EdgeInsets.only(right: 10.0),
//           padding: const EdgeInsets.only(bottom: 15.0),
//           width: 180,
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadius.all(Radius.circular(10.0)),
//             border: Border.all(
//                 width: 1, color: const Color.fromARGB(255, 165, 173, 156)),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: const Color.fromARGB(255, 165, 173, 156),
//                 blurRadius: 5,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           // color: Colors.transparent,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Icon(
//                 Icons.replay_outlined,
//                 color: Colors.green,
//               ),
//               SizedBox(
//                 width: 7,
//               ),
//               Row(
//                 children: [
//                   Text(
//                     "Recargar Información",
//                     style: TextStyle(color: Colors.green),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 width: 10,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<dynamic> RollbackInputDialog(BuildContext context) {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             content: Container(
//               width: MediaQuery.of(context).size.width / 2,
//               height: MediaQuery.of(context).size.height / 2,
//               child: Column(
//                 children: [
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Icon(Icons.close),
//                     ),
//                   ),
//                   Expanded(child: TransactionRollback())
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   void _showDatePickerModal(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Seleccionar Rango de Fechas'),
//           content: Container(
//             width: MediaQuery.of(context).size.width * 0.4,
//             child: SfDateRangePicker(
//               selectionMode: DateRangePickerSelectionMode.range,
//               onSelectionChanged: _onSelectionChanged,
//             ),
//           ),
//           actions: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cerrar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
//     if (args.value is PickerDateRange) {
//       final PickerDateRange dateRange = args.value;
//       print('Fecha de inicio: ${dateRange.startDate}');
//       print('Fecha de fin: ${dateRange.endDate}');
//       start = dateRange.startDate.toString();
//       end = dateRange.endDate.toString();
//       if (dateRange.endDate != null) {
//         Navigator.of(context).pop();
//         filterData();
//       }
//     }
//   }

//   Column SelectFilterNoId(String title, filter,
//       TextEditingController controller, List<String> listOptions) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title),
//         Expanded(
//           child: Container(
//             margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(5.0),
//               border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
//             ),
//             height: 50,
//             child: DropdownButtonFormField<String>(
//               isExpanded: true,
//               value: controller.text,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   controller.text = newValue ?? "";
//                   arrayFiltersAnd
//                       .removeWhere((element) => element.containsKey(filter));

//                   if (newValue != 'TODO') {
//                     arrayFiltersAnd.add({filter: newValue});
//                   } else {}

//                   filterData();
//                 });
//               },
//               decoration: InputDecoration(
//                   border: UnderlineInputBorder(
//                       borderRadius: BorderRadius.circular(10))),
//               items: listOptions.map<DropdownMenuItem<String>>((String value) {
//                 // var nombre = value.split('-')[0];
//                 // print(nombre);
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value.split('-')[0],
//                       style: const TextStyle(fontSize: 15)),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   _modelTextField({text, controller}) {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Color.fromARGB(255, 245, 244, 244),
//       ),
//       child: TextField(
//         controller: controller,
//         onSubmitted: (value) {
//           filterData();
//           //  paginatorController.navigateToPage(0);
//         },
//         style: const TextStyle(fontWeight: FontWeight.bold),
//         decoration: InputDecoration(
//           fillColor: Colors.grey[500],
//           prefixIcon: const Icon(Icons.search),
//           suffixIcon: searchController.text.isNotEmpty
//               ? GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       searchController.clear();
//                     });

//                     Navigator.pop(context);
//                   },
//                   child: Icon(Icons.close))
//               : null,
//           hintText: text,
//           border: const OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey),
//           ),
//           focusColor: Colors.black,
//           iconColor: Colors.black,
//         ),
//       ),
//     );
//   }

//   List<DataColumn2> getColumns() {
//     return [
//       DataColumn2(
//         label: // Espacio entre iconos
//             Text('Id'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("marca_tiempo_envio", changevalue);
//         },
//       ),
//       DataColumn2(
//         label: Text('Tipo Transacción.'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("fecha_entrega", changevalue);
//         },
//       ),
//       DataColumn2(
//         label: Text('Monto'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("numero_orden", changevalue);
//         },
//       ),
//       DataColumn2(
//         label: Text('Valor Actual'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("Marca de Tiempo", changevalue);
//         },
//       ),
//       DataColumn2(
//         label: Text('Marca de Tiempo'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("Marca de Tiempo", changevalue);
//         },
//       ),
//       DataColumn2(
//         label: Text('Id Origen'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("ciudad_shipping", changevalue);
//         },
//       ),
//       DataColumn2(
//         label: Text('Codigo'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("ciudad_shipping", changevalue);
//         },
//       ),
//       DataColumn2(
//         label:
//             SelectFilterNoId('Origen', 'origen', origenController, listOrigen),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("direccion_shipping", changevalue);
//         },
//       ),
//       DataColumn2(
//         label: Text('Id Vendedor'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("telefono_shipping", changevalue);
//         },
//       ),
//       DataColumn2(
//         label: Text('Comentario'),
//         size: ColumnSize.S,
//         onSort: (columnIndex, ascending) {
//           // sortFunc3("telefono_shipping", changevalue);
//         },
//       ),
//     ];
//   }

//   setColor(transaccion) {
//     final color = transaccion == "credit"
//         ? Color.fromARGB(255, 202, 236, 162)
//         : Color.fromARGB(255, 236, 176, 175);
//     return color;
//   }

//   List<DataRow> buildDataRows(List data) {
//     List<DataRow> rows = [];
//     for (int index = 0; index < data.length; index++) {
//       DataRow row = DataRow(
//         color: MaterialStateColor.resolveWith(
//             (states) => setColor(data[index]['tipo'])!),
//         cells: [
//           DataCell(InkWell(
//               child: Text(data[index]['id'].toString()),
//               onTap: () {
//                 // OpenShowDialog(context, index);
//               })),
//           DataCell(InkWell(
//               child: Text(data[index]['tipo'].toString()),
//               onTap: () {
//                 // OpenShowDialog(context index);
//               })),
//           DataCell(InkWell(
//               child: Text(
//                 data[index]['tipo'] == 'debit'
//                     ? "\$ - ${data[index]['monto'].toString()}"
//                     : "\$ + ${data[index]['monto'].toString()}",
//               ),
//               onTap: () {
//                 // OpenShowDialog(context index);
//               })),
//           DataCell(InkWell(
//               child: Text("\$ ${data[index]['valor_actual'].toString()}"),
//               onTap: () {
//                 // OpenShowDialog(context, index);
//               })),
//           DataCell(InkWell(
//               child: Text(
//                   "${data[index]['marca_de_tiempo'].toString().split(" ")[0]}   ${data[index]['marca_de_tiempo'].toString().split(" ")[1]}"),
//               onTap: () {
//                 // OpenShowDialog(context, index);
//               })),
//           DataCell(InkWell(
//               child: Text(data[index]['id_origen'].toString()),
//               onTap: () {
//                 // OpenShowDialog(context, index);
//               })),
//           DataCell(InkWell(
//               child: Text(data[index]['codigo'].toString()),
//               onTap: () {
//                 // OpenShowDialog(context, index);
//               })),
//           DataCell(InkWell(
//               child: Text(data[index]['origen'].toString()),
//               onTap: () {
//                 // OpenShowDialog(context, index);
//               })),
//           DataCell(InkWell(
//               child: Text(data[index]['id_vendedor'].toString()),
//               onTap: () {
//                 // OpenShowDialog(context, index);
//               })),
//           DataCell(InkWell(
//               child: Text(data[index]['comentario'].toString()),
//               onTap: () {
//                 // OpenShowDialog(context, index);
//               })),
//         ],
//       );
//       rows.add(row);
//     }

//     return rows;
//   }
// }

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/transactions/transactionRollback.dart';
import 'package:frontend/ui/provider/transactions/controllers/transactions_controller.dart';
import 'package:frontend/ui/sellers/my_wallet/controllers/my_wallet_controller.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Transaction {
  final String title;
  final double amount;

  Transaction(this.title, this.amount);
}

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  TransactionsController walletController = TransactionsController();
  TextEditingController searchController = TextEditingController();
  final _startDateController = TextEditingController(
      text:
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}");
  final _endDateController = TextEditingController(
      text:
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}");
  NumberPaginatorController paginatorController = NumberPaginatorController();
  TextEditingController origenController = TextEditingController(text: "TODO");

  int currentPage = 1;
  int pageSize = 100;
  int pageCount = 0;
  String saldo = '0';
  List data = [];
  bool isLoading = false;
  String start = "";
  String end = "";
  List<String> sellers = ['TODO'];
  List arrayFiltersAnd = [];
  List arrayFiltersDefaultAnd = [];
  List<String> listOrigen = [
    'TODO',
    'RECAUDO',
    'ENVIO',
    'REFERENCIADO',
    'DEVOLUCION',
    'REEMBOLSO',
  ];

  List<String> listTipo = [
    'TODO',
    'CREDIT',
    'DEBIT',
  ];

  String? selectedValueOrigen;
  String? selectedValueTipo;
  String? selectedValueSeller;

  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    final List<DropdownMenuItem<String>> menuItems = [];
    for (final String item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights(array) {
    final List<double> itemsHeights = [];
    for (int i = 0; i < (array.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  // Saldo

  @override
  void initState() {
    loadData();
    loadSellers();
    super.initState();
  }

  loadSellers() async {
    var responseSellers = await Connections().getVendedores();
    for (var vendedor in responseSellers["vendedores"]) {
      sellers.add(vendedor);
    }
    setState(() {
      sellers = sellers;
    });
  }

  loadData() async {
    isLoading = true;
    currentPage = 1;

    try {
      var response = await Connections().getTransactionsBySeller(
          _startDateController.text,
          _endDateController.text,
          [],
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
          [],
          currentPage,
          pageSize,
          searchController.text);

      setState(() {
        data = response["data"];
        pageCount = response['last_page'];
        paginatorController.navigateToPage(0);

        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  paginateData() async {
    // paginatorController.navigateToPage(0);
    try {
      setState(() {
        // search = false;
      });

      var response = await Connections().getTransactionsBySeller(
          _startDateController.text,
          _endDateController.text,
          [],
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
          [],
          currentPage,
          pageSize,
          searchController.text);

      setState(() {
        data = [];
        data = response['data'];

        pageCount = response['last_page'];
      });
    } catch (e) {
      _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
    }
  }

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

  filterData() async {
    arrayFiltersAnd.add({
      "id_vendedor":
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    });

    try {
      var response = await Connections().getTransactionsByDate(
          start, end, searchController.text, arrayFiltersAnd);

      setState(() {
        data = response;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left: width * 0.01, right: width * 0.01),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Mi Billetera',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _leftWidget(width, heigth, context),
                  Expanded(
                    child: Column(
                      children: [
                        _searchBar(width, heigth, context),
                        SizedBox(height: 10),
                        _dataTableTransactions(),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _dataTableTransactions() {
    return Container(
      height: 700,
      child: Expanded(
        child: DataTableModelPrincipal(
            columnWidth: 400, columns: getColumns(), rows: buildDataRows(data)),
      ),
    );
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonUnselectedForegroundColor: const Color.fromARGB(255, 67, 67, 67),
        buttonSelectedBackgroundColor: const Color.fromARGB(255, 67, 67, 67),
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      onPageChange: (index) async {
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await paginateData();
        }
      },
    );
  }

  Container _searchBar(double width, double heigth, BuildContext context) {
    return Container(
      color: Colors.white,
      child: responsive(
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: _modelTextField(
                    text: "Buscar", controller: searchController),
              ),

              Container(
                padding: const EdgeInsets.only(left: 15, right: 5),
                child: Text(
                  "Registros: ${data.length}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              TextButton(
                  onPressed: () => RollbackInputDialog(context),
                  child: Text("Restaurar")),
              Spacer(),
              Expanded(child: numberPaginator()),
              SizedBox(width: 10),

              Spacer(),
              TextButton(
                  onPressed: () => loadData(), child: Text("Actualizar")),

              //   Expanded(child: numberPaginator()),
            ],
          ),
          Container(),
          context),
    );
  }

  Future<dynamic> RollbackInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close),
                    ),
                  ),
                  Expanded(child: TransactionRollback())
                ],
              ),
            ),
          );
        });
  }

  Container _leftWidget(double width, double heigth, BuildContext context) {
    return Container(
      width: width * 0.15,
      height: heigth * 0.85,
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Color de la sombra
              spreadRadius: 5, // Radio de dispersión de la sombra
              blurRadius: 7, // Radio de desenfoque de la sombra
              offset: Offset(
                  0, 3), // Desplazamiento de la sombra (horizontal, vertical)
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
          width: width * 0.2,
          height: heigth * 0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${formatNumber(double.parse(saldo))}',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              Text(
                'Saldo de Cuenta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        _dateButtons(width, context),
        SizedBox(
          height: 20,
        ),
        _optionButtons(width, heigth),
      ]),
    );
  }

  Container _dateButtons(double width, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Color de la sombra
          spreadRadius: 5, // Radio de dispersión de la sombra
          blurRadius: 7, // Radio de desenfoque de la sombra
          offset: Offset(
              0, 3), // Desplazamiento de la sombra (horizontal, vertical)
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      width: width * 0.2,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: width * 0.2,
                padding: EdgeInsets.only(bottom: 10),
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    _showDatePickerModal(context);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Ajusta el valor según sea necesario
                      ),
                    ),
                  ),
                  label: Text('Seleccionar'),
                  icon: Icon(Icons.calendar_month_outlined),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                width: width * 0.2,
                child: FilledButton.tonalIcon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Ajusta el valor según sea necesario
                      ),
                    ),
                  ),
                  onPressed: () {
                    loadData();
                  },
                  label: Text('Consultar'),
                  icon: Icon(Icons.search),
                ),
              ),
            ],
          ),
          Container(
            width: 300,
            child: Column(
              children: [
                _buildDateField("Fecha Inicio", _startDateController),
                SizedBox(height: 16),
                _buildDateField("Fecha Fin", _endDateController),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatNumber(double number) {
    var formatter =
        NumberFormat('###,###.##', 'es'); // 'es' para formato en español
    return formatter.format(number);
  }

  Container _optionButtons(double width, double height) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Color de la sombra
          spreadRadius: 5, // Radio de dispersión de la sombra
          blurRadius: 7, // Radio de desenfoque de la sombra
          offset: Offset(
              0, 3), // Desplazamiento de la sombra (horizontal, vertical)
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      width: width * 0.2,
      height: height * 0.33,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 300,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Seleccione Origen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(listOrigen),
                value: selectedValueOrigen,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueOrigen = value;
                  });

                  arrayFiltersAnd.removeWhere(
                      (element) => element.containsKey("equals/origen"));
                  if (value != '') {
                    arrayFiltersAnd.add({"equals/origen": value});
                  } else {
                    arrayFiltersAnd.removeWhere(
                        (element) => element.containsKey("equals/origen"));
                  }
                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 140,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  customHeights: _getCustomItemsHeights(listOrigen),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
          Container(
            width: 300,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Seleccione Tipo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(listTipo),
                value: selectedValueTipo,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueTipo = value;
                  });

                  arrayFiltersAnd.removeWhere(
                      (element) => element.containsKey("equals/tipo"));
                  if (value != '') {
                    arrayFiltersAnd.add({"equals/tipo": value});
                  } else {
                    arrayFiltersAnd.removeWhere(
                        (element) => element.containsKey("equals/tipo"));
                  }
                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 140,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  customHeights: _getCustomItemsHeights(listTipo),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
          Container(
            width: 300,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Seleccione Vendedor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(sellers),
                value: selectedValueSeller,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueSeller = value;
                  });

                  arrayFiltersAnd.removeWhere(
                      (element) => element.containsKey("equals/id_vendedor"));
                  if (value != '') {
                    arrayFiltersAnd
                        .add({"equals/id_vendedor": value!.split('-')[1]});
                  } else {
                    arrayFiltersAnd.removeWhere(
                        (element) => element.containsKey("equals/id_vendedor"));
                  }
                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 140,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  customHeights: _getCustomItemsHeights(sellers),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _showDatePickerModal(BuildContext context) {
    return openDialog(
        context,
        400,
        400,
        SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          onSelectionChanged: _onSelectionChanged,
        ),
        () {});
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 120,
              child: Text(
                label + ":",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "2023-01-31",
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12), // Ajusta la altura aquí
                ),
                validator: (value) {
                  // Puedes agregar validaciones adicionales según tus necesidades
                  if (value == null || value.isEmpty) {
                    return "Este campo no puede estar vacío";
                  }
                  // Aquí podrías validar el formato de la fecha
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange dateRange = args.value;

      print('Fecha de inicio: ${dateRange.startDate}');
      print('Fecha de fin: ${dateRange.endDate}');
      _startDateController.text =
          "${dateRange.startDate!.year}-${dateRange.startDate!.month}-${dateRange.startDate!.day}";
      _endDateController.text =
          "${dateRange.endDate!.year}-${dateRange.endDate!.month}-${dateRange.endDate!.day}";

      // start = dateRange.startDate.toString();
      // end = dateRange.endDate.toString();
      // if (dateRange.endDate != null) {
      //   Navigator.of(context).pop();
      //  // filterData();
      // }
    }
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
          //  paginatorController.navigateToPage(0);
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      searchController.clear();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  Column SelectFilterNoId(String title, filter,
      TextEditingController controller, List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
            ),
            height: 50,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.text,
              onChanged: (String? newValue) {
                setState(() {
                  controller.text = newValue ?? "";
                  arrayFiltersAnd
                      .removeWhere((element) => element.containsKey(filter));

                  if (newValue != 'TODO') {
                    arrayFiltersAnd.add({filter: newValue});
                  } else {}

                  filterData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                // var nombre = value.split('-')[0];
                // print(nombre);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.split('-')[0],
                      style: const TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(
        label: Text('Tipo Transacción.'),
        fixedWidth: 100,
        onSort: (columnIndex, ascending) {
          // sortFunc3("fecha_entrega", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Monto'),
        fixedWidth: 120,
        onSort: (columnIndex, ascending) {
          // sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Valor Anterior'),
        fixedWidth: 160,
        onSort: (columnIndex, ascending) {
          // sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Valor Actual'),
        fixedWidth: 130,
        onSort: (columnIndex, ascending) {
          // sortFunc3("Marca de Tiempo", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Marca de Tiempo'),
        fixedWidth: 200,
        onSort: (columnIndex, ascending) {
          // sortFunc3("Marca de Tiempo", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 110,
        label: Text('Id Origen'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 160,
        label: Text('Codigo'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 100,
        label: Text('Origen'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Text('Vendedor'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Comentario'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
    ];
  }

  setColor(transaccion) {
    final color = transaccion == "credit"
        ? Color.fromARGB(255, 148, 230, 54)
        : Color.fromARGB(255, 209, 13, 10);
    return color;
  }

  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(InkWell(
              child: Text(data[index]['tipo'].toString(),
                  style: TextStyle(color: setColor(data[index]['tipo']))),
              onTap: () {
                // OpenShowDialog(context index);
              })),
          DataCell(InkWell(
              child: Text(
                data[index]['tipo'] == 'debit'
                    ? "\$ - ${data[index]['monto'].toString()}"
                    : "\$ + ${data[index]['monto'].toString()}",
              ),
              onTap: () {
                // OpenShowDialog(context index);
              })),
          DataCell(InkWell(
              child: Text("\$ ${data[index]['valor_anterior']}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text("\$ ${data[index]['valor_actual']}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(
                  "${data[index]['marca_de_tiempo'].toString().split(" ")[0]}   ${data[index]['marca_de_tiempo'].toString().split(" ")[1]}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['id_origen'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['codigo'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['origen'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['user']['email'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['comentario'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
        ],
      );
      rows.add(row);
    }

    return rows;
  }
}
