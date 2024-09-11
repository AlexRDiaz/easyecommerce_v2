import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/transactions/transactionRollback.dart';
import 'package:frontend/ui/logistic/transactions_global/custom_drawer.dart';
import 'package:frontend/ui/logistic/transactions_global/transactionRollback.dart';
import 'package:frontend/ui/sellers/my_wallet/controllers/my_wallet_controller.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TransactionsGlobal extends StatefulWidget {
  @override
  _TransactionsGlobalState createState() => _TransactionsGlobalState();
}

class _TransactionsGlobalState extends State<TransactionsGlobal> {
  MyWalletController walletController = MyWalletController();
  TextEditingController searchController = TextEditingController();
  final _startDateController = TextEditingController(text: "1/1/2023");
  final _endDateController = TextEditingController(
      text:
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
  NumberPaginatorController paginatorController = NumberPaginatorController();
  TextEditingController origenController = TextEditingController(text: "TODO");
  List<String> sellers = ['TODO'];

  String _defaultsellerController = "0";
  var saldoText = "0";

  int currentPage = 1;
  int pageSize = 100;
  int pageCount = 0;
  int totalrecords = 0;
  String saldo = '0';
  List data = [];
  bool isLoading = false;
  String start = "";
  String end = "";

  List arrayFiltersAnd = [];

  List arrayFiltersOr = [
    "admission_date",
    "delivery_date",
    "status",
    "return_state",
    "id_order",
    "code",
    "origin",
    "withdrawal_price",
    "value_order",
    "return_cost",
    "delivery_cost",
    "notdelivery_cost",
    "provider_cost",
    "referer_cost",
    "total_transaction",
    "previous_value",
    "current_value",
    "state",
    "id_seller",
    "internal_transportation_cost",
    "external_transportation_cost",
    "external_return_cost"
  ];

  List arrayFiltersDefaultAnd = [];
  List<String> listOrigen = [
    'TODO',
    'Retiro de Efectivo',
    'Referenciado',
    'Pedido ENTREGADO',
    'Pedido NO ENTREGADO',
    'Pedido NOVEDAD'
  ];

  List<String> listStatus = [
    'TODO',
    // 'PEDIDO PROGRAMADO',
    'NOVEDAD',
    // 'NOVEDAD RESUELTA',
    'NO ENTREGADO',
    'ENTREGADO',
    // 'REAGENDADO',
    // 'EN OFICINA',
    // 'EN RUTA'
  ];

  // List<String> listTipo = [
  //   'TODO',
  //   'CREDIT',
  //   'DEBIT',
  // ];

  List populate = ['user', 'order'];

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    loadData();
    loadSellers();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

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
    currentPage = 1;
    // var res = await walletController.getSaldo();
    setState(() {
      isLoading = true;

      //  saldo = res;
    });

    try {
      var response = await Connections().generalDataTransactionsGlobal(
          pageSize,
          // pageCount,
          currentPage,
          populate,
          [],
          arrayFiltersAnd,
          arrayFiltersOr,
          [],
          [],
          searchController.text,
          "TransaccionGlobal",
          "admission_date",
          _startDateController.text,
          _endDateController.text,
          "id:DESC");

      var responseSaldo =
          await Connections().getLastSaldoSellerTg(_defaultsellerController);

      saldoText = responseSaldo['current_value'].toString();

      setState(() {
        data = response["data"];
        pageCount = response['last_page'];
        totalrecords = response['total'];
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

      var response = await Connections().generalDataTransactionsGlobal(
          pageSize,
          // pageCount,
          currentPage,
          populate,
          [],
          arrayFiltersAnd,
          arrayFiltersOr,
          [],
          [],
          searchController.text,
          "TransaccionGlobal",
          "admission_date",
          _startDateController.text,
          _endDateController.text,
          "admission_date:DESC");

      setState(() {
        data = [];
        data = response['data'];

        pageCount = response['last_page'];
      });
    } catch (e) {
      _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
    }
  }

  void _toggleDrawer() {
    double heigth = MediaQuery.of(context).size.height * 0.6;
    double width = MediaQuery.of(context).size.width * 0.6;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 300, // Ajusta el ancho según lo necesites
            color: Colors.white,
            child: CustomEndDrawer(
                customContent: _leftWidgetWeb(width, heigth,
                    context)), // Usa tu drawer personalizado aquí
          ),
        );
      },
    );
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
    double heigth = MediaQuery.of(context).size.height * 0.5;
    double width = MediaQuery.of(context).size.width * 0.6;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        key: _scaffoldKey,
        body: Center(
          child: Container(
            padding: EdgeInsets.only(left: width * 0.01, right: width * 0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Padding(
                //   padding: EdgeInsets.all(10),
                //   child: Text(
                //     'Mi Billetera',
                //     style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                //   ),
                // ),
                responsive(webMainContainer(width, heigth, context),
                    mobileMainContainer(width, heigth, context), context)
              ],
            ),
          ),
        ),
        endDrawer: CustomEndDrawer(
            customContent: _leftWidgetWeb(width, heigth, context)),
      ),
    );
  }

  Row webMainContainer(double width, double heigth, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _leftWidgetWeb(width, heigth, context),
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 20),
              _searchBar(width, heigth, context),
              SizedBox(height: 20),
              _dataTableTransactions(heigth),
            ],
          ),
        ),
      ],
    );
  }

  mobileMainContainer(double width, double heigth, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _leftWidgetMobile(width, heigth, context),
          Divider(),
          _searchBar(width, heigth, context),
          _dataTableTransactionsMobile(heigth),
        ],
      ),
    );
  }

  Widget buildDataTable(BuildContext context, columns, rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Color de la sombra
            spreadRadius: 5, // Radio de dispersión de la sombra
            blurRadius: 7, // Radio de desenfoque de la sombra
            offset: Offset(
                0, 3), // Desplazamiento de la sombra (horizontal, vertical)
          ),
        ],
      ),
      child: DataTable2(
        // dividerThickness: 1,
        // dataRowColor: MaterialStateColor.resolveWith((states) {
        //   if (states.contains(MaterialState.selected)) {
        //     return Colors.blue.withOpacity(0.5); // Color para fila seleccionada
        //   } else if (states.contains(MaterialState.hovered)) {
        //     return const Color.fromARGB(255, 234, 241, 251);
        //   }
        //   return const Color.fromARGB(0, 173, 233, 231);
        // }),
        headingTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        dataTextStyle: const TextStyle(color: Colors.black),
        columnSpacing: 12,
        headingRowHeight: 80,
        horizontalMargin: 32,
        minWidth: 7000,
        dataRowHeight: 60,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(12.0),
        //   border: Border.all(color: Colors.grey, width: 1),
        // ),
        columns: columns,
        rows: rows,
      ),
    );
  }

  Container _dataTableTransactions(height) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: data.length > 0
          ? buildDataTable(context, getColumns(), buildDataRows(data))
          : Center(
              child: Text("Sin datos"),
            ),
    );
  }

  _dataTableTransactionsMobile(height) {
    return data.length > 0
        ? Container(
            height: height * 0.52,
            child: buildDataTable(context, getColumns(), buildDataRows(data)),
          )
        : Center(
            child: Text("Sin datos"),
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

  _searchBar(double width, double heigth, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: responsive(
          Column(
            children: [
              Row(
                children: [
                  // Primera columna
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                            margin: EdgeInsets.all(2.0),
                            padding: EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1.0, color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Text(
                              " \$ $saldoText ",
                              style: TextStyle(
                                  fontSize: 40.0,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  // Segunda columna
                  Flexible(
                    child: Column(
                      children: [
                        // Primera fila de la segunda columna
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: _modelTextField(
                                text: "Buscar",
                                controller: searchController,
                              ),
                            ),
                            SizedBox(
                                width:
                                    8), // Espacio entre el TextField y el ElevatedButton
                            // ElevatedButton(
                            //   style: ButtonStyle(
                            //     backgroundColor: MaterialStateProperty.all(
                            //         ColorsSystem().colorPrincipalBrand),
                            //   ),
                            //   onPressed: () {
                            //     print("carga de filtros");
                            //     // showMyDialog(context);
                            //     _toggleDrawer;
                            //   },
                            //   child: Text(
                            //     "Filtrar",
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            // ),
                            TextButton(
                              child: (selectedValueSeller == null &&
                                      selectedValueSeller == "TODO")
                                  ? const Row(children: [
                                      Icon(Icons.filter_alt_outlined,
                                          color: Colors.green),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                        "Filtros",
                                        style: TextStyle(color: Colors.green),
                                      )
                                    ])
                                  : const Row(children: [
                                      Icon(Icons.filter_alt_outlined,
                                          color: Colors.red),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                        "Filtros",
                                        style: TextStyle(color: Colors.red),
                                      )
                                    ]),
                              onPressed: () {
                                // Abre el endDrawer cuando se presiona el botón
                                _scaffoldKey.currentState?.openEndDrawer();
                              },
                            ),
                            TextButton(
                              onPressed: () => RollbackInputDialog(context),
                              child: Text("Restaurar"),
                            ),
                            IconButton(
                              onPressed: () => loadData(),
                              icon: Icon(Icons.replay_outlined),
                            ),
                            Text("Registros: ${totalrecords}"),
                          ],
                        ),
                        // SizedBox(
                        //     height:
                        //         2), // Espacio entre la primera y la segunda fila

                        // Segunda fila de la segunda columna
                        Row(
                          children: [
                            // TextButton(
                            //   onPressed: () => RollbackInputDialog(context),
                            //   child: Text("Restaurar"),
                            // ),
                            // IconButton(
                            //   onPressed: () => loadData(),
                            //   icon: Icon(Icons.replay_outlined),
                            // ),
                            // Text("Registros: ${totalrecords}"),
                            // Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: numberPaginator(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ],
          // ),
          // ! falta editar esta parte para la version móvil
          Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: _modelTextField(
                        text: "Buscar", controller: searchController),
                  ),
                  TextButton(
                      onPressed: () => RollbackInputDialog(context),
                      child: Text("Restaurar")),
                  IconButton(
                      onPressed: () => loadData(),
                      icon: Icon(Icons.replay_outlined)),
                ],
              ),
              Row(children: [
                Expanded(child: numberPaginator()),
              ]),

              //   Expanded(child: numberPaginator()),
            ],
          ),
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
                  // Expanded(child: TransactionRollbackGlobal())
                  Expanded(child: TransactionRollback())
                ],
              ),
            ),
          );
        });
  }

  Container _leftWidgetWeb(double width, double heigth, BuildContext context) {
    return Container(
      width: width * 0.15,
      padding: EdgeInsets.only(left: 10, right: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        // Container(
        //   decoration: BoxDecoration(boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.5), // Color de la sombra
        //       spreadRadius: 5, // Radio de dispersión de la sombra
        //       blurRadius: 7, // Radio de desenfoque de la sombra
        //       offset: const Offset(
        //           0, 3), // Desplazamiento de la sombra (horizontal, vertical)
        //     ),
        //   ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
        //   width: width * 0.2,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Text(
        //         '\$${formatNumber(double.parse(saldo))}',
        //         style: const TextStyle(
        //             fontSize: 34,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.blueAccent),
        //       ),
        //       const Padding(
        //         padding: EdgeInsets.only(left: 10, right: 20),
        //         child: Text(
        //           'Saldo de Cuenta',
        //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        // SizedBox(
        //   height: 2,
        // ),
        _dateButtons(width, context),
        SizedBox(
          height: 10,
        ),
        _optionButtons(width, heigth),
        SizedBox(
          height: 15,
        ),
        Container(
          padding: EdgeInsets.only(bottom: 10),
          width: width * 0.3,
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
              _scaffoldKey.currentState?.closeEndDrawer();
              loadData();
            },
            label: Text('Consultar'),
            icon: Icon(Icons.search),
          ),
        ),
      ]),
    );
  }

  Container _leftWidgetMobile(
      double width, double height, BuildContext context) {
    return Container(
      height: height * 0.18,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _saldoDeCuentaMobile(width),
              Container(
                width: 1, // Ancho de la línea divisoria
                height: height * 0.08, // Altura de la línea divisoria
                color: Colors.grey, // Color de la línea divisoria
              ),
              _dateButtonsMobile(width, context),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [_optionButtonsMobile(width, height)],
          ),
        ],
      ),
    );
  }

  Container _dateButtonsMobile(double width, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: width * 0.60,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: FilledButton.tonal(
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
                  child: Icon(Icons.calendar_month_outlined),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: FilledButton.tonal(
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
                  child: Icon(Icons.search),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateFieldMobile("Desde", _startDateController),
              const SizedBox(width: 5),
              _buildDateFieldMobile("Hasta", _endDateController),
            ],
          ),
        ],
      ),
    );
  }

  Container _saldoDeCuenta(double width) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Color de la sombra
          spreadRadius: 5, // Radio de dispersión de la sombra
          blurRadius: 7, // Radio de desenfoque de la sombra
          offset: Offset(
              0, 3), // Desplazamiento de la sombra (horizontal, vertical)
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      width: width * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${formatNumber(double.parse(saldo))}',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
          Text(
            'Saldo de Cuenta',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Container _saldoDeCuentaMobile(double width) {
    return Container(
      width: width * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${formatNumber(double.parse(saldo))}',
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
          const Text(
            'Saldo de Cuenta',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Container _dateButtons(double width, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
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
      width: width * 0.3,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              // Container(
              //   padding: EdgeInsets.only(bottom: 10),
              //   width: width * 0.2,
              //   child: FilledButton.tonalIcon(
              //     style: ButtonStyle(
              //       shape: MaterialStateProperty.all<OutlinedBorder>(
              //         RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(
              //               5), // Ajusta el valor según sea necesario
              //         ),
              //       ),
              //     ),
              //     onPressed: () {
              //       loadData();
              //     },
              //     label: Text('Consultar'),
              //     icon: Icon(Icons.search),
              //   ),
              // ),
            ],
          ),
          Container(
            width: 300,
            child: Column(
              children: [
                _buildDateField("Fecha Inicio", _startDateController),
                SizedBox(height: 10),
                _buildDateField("Fecha Fin", _endDateController),
                SizedBox(height: 10),
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
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Color de la sombra
          spreadRadius: 5, // Radio de dispersión de la sombra
          blurRadius: 7, // Radio de desenfoque de la sombra
          offset: Offset(
              0, 3), // Desplazamiento de la sombra (horizontal, vertical)
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      width: width * 0.3,
      height: height * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 300,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Origen',
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
                      (element) => element.containsKey("equals/origin"));
                  if (value != '') {
                    if (value == "TODO") {
                      arrayFiltersAnd.removeWhere(
                          (element) => element.containsKey("equals/origin"));
                    } else {
                      arrayFiltersAnd.add({"equals/origin": value});
                    }
                  }

                  // loadData();
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
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(listStatus),
                value: selectedValueTipo,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueTipo = value;
                  });

                  arrayFiltersAnd.removeWhere(
                      (element) => element.containsKey("equals/status"));
                  if (value != '') {
                    if (value == "TODO") {
                      arrayFiltersAnd.removeWhere(
                          (element) => element.containsKey("equals/status"));
                    } else {
                      arrayFiltersAnd.add({"equals/status": value});
                    }
                  }

                  // loadData();
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
                  customHeights: _getCustomItemsHeights(listStatus),
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
                      (element) => element.containsKey("equals/id_seller"));
                  if (value != '') {
                    if (value == "TODO") {
                      arrayFiltersAnd.removeWhere(
                          (element) => element.containsKey("equals/id_seller"));

                      _defaultsellerController = "0";
                    } else {
                      arrayFiltersAnd
                          .add({"equals/id_seller": value!.split('-')[1]});

                      _defaultsellerController = value.split('-')[1].toString();
                    }
                  }

                  // loadData();
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

  Container _optionButtonsMobile(double width, double height) {
    return Container(
      // padding: EdgeInsets.all(10),
      // width: width * 0.3,
      // height: height * 0.28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: width * 0.25,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Origen',
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
                      (element) => element.containsKey("equals/origin"));
                  if (value != '') {
                    if (value == "TODO") {
                      arrayFiltersAnd.removeWhere(
                          (element) => element.containsKey("equals/origin"));
                    } else {
                      arrayFiltersAnd.add({"equals/origin": value});
                    }
                  }

                  // loadData();
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
          const SizedBox(width: 10),
          Container(
            width: width * 0.25,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(listStatus),
                value: selectedValueTipo,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueTipo = value;
                  });

                  arrayFiltersAnd.removeWhere(
                      (element) => element.containsKey("equals/status"));
                  if (value != '') {
                    if (value == "TODO") {
                      arrayFiltersAnd.removeWhere(
                          (element) => element.containsKey("equals/status"));
                    } else {
                      arrayFiltersAnd.add({"equals/status": value});
                    }
                  }

                  // loadData();
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
                  customHeights: _getCustomItemsHeights(listStatus),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: width * 0.30,
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
                    if (value == "TODO") {
                      arrayFiltersAnd.removeWhere((element) =>
                          element.containsKey("equals/id_vendedor"));

                      _defaultsellerController = "0";
                    } else {
                      arrayFiltersAnd
                          .add({"equals/id_vendedor": value!.split('-')[1]});

                      _defaultsellerController = value.split('-')[1].toString();
                    }
                  }

                  // loadData();
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
              width: 50,
              child: Text(
                label + ":",
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: "31/1/2023",
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12), // Ajusta la altura aquí
                ),
                style: TextStyle(
                  fontSize:
                      12, // Ajusta el tamaño del texto según tus necesidades
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

  Widget _buildDateFieldMobile(String label, TextEditingController controller) {
    return Container(
      width: 100,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          label: Text(label),
          isDense: true,
          border: OutlineInputBorder(),
          hintText: "31/1/2023",
          contentPadding: EdgeInsets.symmetric(
              vertical: 9, horizontal: 10), // Ajusta la altura aquí
        ),
        style: TextStyle(
          fontSize: 11, // Ajusta el tamaño del texto según tus necesidades
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
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange dateRange = args.value;

      print('Fecha de inicio: ${dateRange.startDate}');
      print('Fecha de fin: ${dateRange.endDate}');
      _startDateController.text =
          // "${dateRange.startDate!.year}-${dateRange.startDate!.month}-${dateRange.startDate!.day}";
          "${dateRange.startDate!.day}/${dateRange.startDate!.month}/${dateRange.startDate!.year}";
      _endDateController.text =
          // "${dateRange.endDate!.year}-${dateRange.endDate!.month}-${dateRange.endDate!.day}";
          "${dateRange.endDate!.day}/${dateRange.endDate!.month}/${dateRange.endDate!.year}";

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
        borderRadius: BorderRadius.circular(15.0),
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
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15)),
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
        fixedWidth: 110,
        label: Text('Id Order'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 160,
        label: Text('Fecha de Ingreso'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 160,
        label: Text('Fecha de Entrega'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Text('Codigo'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Estado de Entrega'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      // ! ------------------------26---------------------
      DataColumn2(
        fixedWidth: 250,
        label: Text('Estado de Devolución'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Origen'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Precio Retiro'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Precio Total'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Entrega'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo No Entregado'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Devolución'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Proveedor'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Referido'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Total'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Saldo Anterior'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Saldo Actual'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Id Vendedor(nc)'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Transporte Interno'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Transporte Externo(se)'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Devolucion Externo(se)'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
    ];
  }

  // setColor(transaccion) {
  //   final color = transaccion == "credit"
  //       ? Color.fromARGB(255, 148, 230, 54)
  //       : Color.fromARGB(255, 209, 13, 10);
  //   return color;
  // }

  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        color: MaterialStateProperty.all(Colors.white),
        cells: [
          DataCell(
              InkWell(
                  child: Text(data[index]['id_order'].toString(),
                      style: TextStyle(color: ColorsSystem().colorSelectMenu))),
              onTap: () {
            // OpenShowDialog(context index);
          }),
          DataCell(InkWell(
              child: Text(data[index]['admission_date'].toString()),
              onTap: () {
                // OpenShowDialog(context index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['delivery_date'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['code'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['status'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['return_state'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['origin'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['withdrawal_price'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['value_order'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['delivery_cost'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['notdelivery_cost'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['return_cost'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['provider_cost'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['referer_cost'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(
                data[index]['total_transaction'].toString(),
                style: TextStyle(
                    color: double.parse(
                                data[index]['total_transaction'].toString()) <
                            0
                        ? Colors.red
                        : Colors.green),
              ),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['previous_value'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['current_value'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['user']['nombre_comercial'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child:
                  Text(data[index]['internal_transportation_cost'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child:
                  Text(data[index]['external_transportation_cost'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['external_return_cost'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  List<ExampleDestination> destinations = [
    ExampleDestination(
      label: 'Home',
      icon: Icon(Icons.home),
      selectedIcon: Icon(Icons.home_filled),
    ),
    ExampleDestination(
      label: 'Profile',
      icon: Icon(Icons.person),
      selectedIcon: Icon(Icons.person_outline),
    ),
    // Agrega más destinos según tus necesidades
  ];
}

class ExampleDestination {
  final String label;
  final Icon icon;
  final Icon selectedIcon;

  ExampleDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
