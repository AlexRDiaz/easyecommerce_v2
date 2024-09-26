import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/provider/transactions/withdrawal.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/controllers/controllers.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/withdrawal_details.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/withdrawal_info_new.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/withdrawal_seller.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/helpers/server.dart';

import '../../../helpers/navigators.dart';
import 'controllers/search_controller.dart';
import '../../widgets/show_error_snackbar.dart';

class CashWithdrawalsSellers extends StatefulWidget {
  const CashWithdrawalsSellers({super.key});

  @override
  State<CashWithdrawalsSellers> createState() => _CashWithdrawalsSellersState();
}

class _CashWithdrawalsSellersState extends State<CashWithdrawalsSellers> {
  SearchCashWithdrawalsSellersControllers _controllers =
      SearchCashWithdrawalsSellersControllers();
  List data = [];
  var dataCount = {};
  bool sort = false;
  int idUser = int.parse(sharedPrefs!.getString("id").toString());

  NumberPaginatorController paginatorController = NumberPaginatorController();
  int currentPage = 1;
  int pageSize = 10;
  int pageCount = 100;
  bool isLoading = false;
  bool isFirst = true;

  String total = '0.0';
  String from = '0.0';
  String to = '0.0';

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  Future loadData() async {
    try {
      // var response;
      // var responseCount;

      setState(() {
        isLoading = true;
      });

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   getLoadingModal(context, false);
      // });

      var response =
          await Connections().getWithdrawalSellers(pageSize, currentPage);
      var responseCount = await Connections().getCountAR(idUser.toString());

      paginatorController.navigateToPage(0);

      // Future.delayed(Duration(milliseconds: 500), () {
      //   Navigator.pop(context);
      // });

      isFirst = false;
      setState(() {
        data = response['data'];
        pageCount = response['last_page'];
        total = response['total'].toString();
        from = response['from'].toString();
        to = response['to'].toString();
        dataCount = responseCount;
        isLoading = false;
      });
    } catch (e) {
      // Navigator.pop(context);
      print(e);
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    try {
      setState(() {
        isLoading = true;
      });

      var response = await Connections().getWithdrawalSellers(
          pageSize, currentPage); // Asegúrate de usar `currentPage`
      var responseCount = await Connections().getCountAR(idUser.toString());

      setState(() {
        isLoading = false;
        isFirst = false;
        data = response['data'];
        pageCount = response['last_page'];
        dataCount = responseCount;
        total = response['total'].toString();
        from = response['from'].toString();
        to = response['to'].toString();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return CustomProgressModal(
        isLoading: isLoading,
        content: Scaffold(
          body: Container(
              width: double.infinity,
              height: double.infinity,
              child: responsive(
                  webContainer(context), phoneContainer(context), context)),
        ));
  }

  Stack webContainer(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: ColorsSystem().colorInitialContainer,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: ColorsSystem().colorSection,
            ),
          ),
        ],
      ),
      Positioned(
          top: 20,
          left: 20,
          right: 20,
          height: MediaQuery.of(context).size.height,
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Retiros en Efectivo',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsSystem().colorStore,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      withdrawalInputDialog(context);
                                    },
                                    child: Text("Nuevo",
                                        style: TextStylesSystem().ralewayStyle(
                                            20, FontWeight.w500, Colors.white)),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          ColorsSystem().colorStore,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.replay_outlined,
                                      color: ColorsSystem().colorSelected,
                                    ),
                                    onPressed: () {
                                      loadData();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 15.0),
                                      child: Text(
                                        'Aprobados',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorLabels,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 5.0),
                                      child: Text(
                                        dataCount['aprobados'] != null
                                            ? '\$ ${NumberFormat("#,##0.00", "en_US").format(double.parse(dataCount['aprobados']['suma_monto'].toString()))}'
                                            : "\$ 0.00",
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorStore,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            ColorsSystem().colorInterContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          String number =
                                              dataCount['aprobados'] != null
                                                  ? dataCount['aprobados']
                                                          ['conteo']
                                                      .toString()
                                                  : "...";
                                          return Container(
                                            width: 25,
                                            height: 25,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                number,
                                                style: TextStyle(
                                                  color:
                                                      ColorsSystem().colorStore,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 30),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Row(
                            children: [
                              // Primera columna con el texto y el valor, ocupa 3/4 del espacio
                              Expanded(
                                flex: 3, // Ocupa 75% del ancho
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 15.0),
                                      child: Text(
                                        'Realizados',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorLabels,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 5.0),
                                      child: Text(
                                        dataCount['realizados'] != null
                                            ? '\$ ${NumberFormat("#,##0.00", "en_US").format(double.parse(dataCount['realizados']['suma_monto'].toString()))}'
                                            : "\$0.00",
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorStore,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    )
                                  ],
                                ),
                              ),
                              // Espacio entre las dos columnas
                              SizedBox(width: 20),
                              // Segunda columna con el número dentro de un círculo, ocupa 1/4 del espacio
                              Expanded(
                                flex: 1, // Ocupa 25% del ancho
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                          16), // Aumenta el padding para que el círculo crezca
                                      decoration: BoxDecoration(
                                        color:
                                            ColorsSystem().colorInterContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      // El tamaño se ajusta dinámicamente en función del texto
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          String number =
                                              dataCount['realizados'] != null
                                                  ? dataCount['realizados']
                                                          ['conteo']
                                                      .toString()
                                                  : "..."; // Ejemplo de número
                                          return Container(
                                            width:
                                                25, // Ajusta el tamaño del ancho en función del número
                                            height:
                                                25, // Ajusta la altura en función del número
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                number,
                                                style: TextStyle(
                                                    color: ColorsSystem()
                                                        .colorStore,
                                                    fontSize: 32,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: data.length > 0
                      ? DataTable2(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          dataRowColor:
                              MaterialStateColor.resolveWith((states) {
                            return Colors.white;
                          }),
                          dividerThickness: 1,
                          headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          dataTextStyle: const TextStyle(color: Colors.black),
                          columnSpacing: 12,
                          headingRowHeight: 70,
                          horizontalMargin: 32,
                          minWidth: 500,
                          dataRowHeight: 70,
                          columns: getColumns(),
                          rows: buildDataRows(data),
                        )
                      // ? DataTableModelPrincipal(
                      //     columnWidth: 100,
                      //     columns: getColumns(),
                      //     rows: buildDataRows(data))
                      : const Center(
                          child: Text("Sin datos"),
                        ),
                ),
                const SizedBox(height: 15),
                Flexible(
                    child: data.isNotEmpty
                        ? Container(
                            height: 30,
                            child: paginationComplete(),
                          )
                        : Container()),
              ],
            ),
          ))
    ]);
  }

  Stack phoneContainer(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: ColorsSystem().colorInitialContainer,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: ColorsSystem().colorSection,
            ),
          ),
        ],
      ),
      Positioned(
        top: 8,
        left: 20,
        right: 20,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width *
                        0.8, // Ajuste del ancho
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Retiros en Efectivo',
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ColorsSystem().colorStore,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.replay_outlined,
                                        color: ColorsSystem().colorSelected,
                                        size: 14,
                                      ),
                                      onPressed: () {
                                        loadData();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                withdrawalInputDialog(context);
                              },
                              child: Text("Nuevo",
                                  style: TextStylesSystem().ralewayStyle(
                                      12, FontWeight.w500, Colors.white)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: ColorsSystem().colorStore,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height <= 640
                                ? MediaQuery.of(context).size.height * 0.01
                                : MediaQuery.of(context).size.height * 0.03),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            color: Colors.white,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              // Primera columna con el texto y el valor, ocupa 3/4 del espacio
                              Expanded(
                                flex: 3, // Ocupa el 75% del ancho
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 15.0),
                                      child: Text(
                                        'Aprobados',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorLabels,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 5.0),
                                      child: Text(
                                        dataCount['aprobados'] != null
                                            ? '\$ ${NumberFormat("#,##0.00", "en_US").format(double.parse(dataCount['aprobados']['suma_monto'].toString()))}'
                                            : "\$ 0.00",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorStore,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                              // Espacio entre las dos columnas
                              SizedBox(width: 20),
                              // Segunda columna con el número dentro de un círculo, ocupa 1/4 del espacio
                              Expanded(
                                flex: 1, // Ocupa el 25% del ancho
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                          16), // Aumenta el padding para que el círculo crezca
                                      decoration: BoxDecoration(
                                        color:
                                            ColorsSystem().colorInterContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      // El tamaño se ajusta dinámicamente en función del texto
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          String number = dataCount[
                                                      'aprobados'] !=
                                                  null
                                              ? dataCount['aprobados']['conteo']
                                                  .toString()
                                              : "..."; // Ejemplo de número, aquí puede ser cualquier valor
                                          return Container(
                                            width:
                                                20, // Ajusta el tamaño del ancho en función del número
                                            height:
                                                20, // Ajusta la altura en función del número
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                number,
                                                style: TextStyle(
                                                  color:
                                                      ColorsSystem().colorStore,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            color: Colors.white,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              // Primera columna con el texto y el valor, ocupa 3/4 del espacio
                              Expanded(
                                flex: 3, // Ocupa 75% del ancho
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 15.0),
                                      child: Text(
                                        'Realizados',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorLabels,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 5.0),
                                      child: Text(
                                        dataCount['realizados'] != null
                                            ? '\$ ${NumberFormat("#,##0.00", "en_US").format(double.parse(dataCount['realizados']['suma_monto'].toString()))}'
                                            : "\$0.00",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorStore,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    )
                                  ],
                                ),
                              ),
                              // Espacio entre las dos columnas
                              SizedBox(width: 20),
                              // Segunda columna con el número dentro de un círculo, ocupa 1/4 del espacio
                              Expanded(
                                flex: 1, // Ocupa 25% del ancho
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                          16), // Aumenta el padding para que el círculo crezca
                                      decoration: BoxDecoration(
                                        color:
                                            ColorsSystem().colorInterContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      // El tamaño se ajusta dinámicamente en función del texto
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          String number =
                                              dataCount['realizados'] != null
                                                  ? dataCount['realizados']
                                                          ['conteo']
                                                      .toString()
                                                  : "..."; // Ejemplo de número
                                          return Container(
                                            width:
                                                20, // Ajusta el tamaño del ancho en función del número
                                            height:
                                                20, // Ajusta la altura en función del número
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                number,
                                                style: TextStyle(
                                                    color: ColorsSystem()
                                                        .colorStore,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 20),
            // SizedBox(
            //     height: MediaQuery.of(context).size.height <= 640
            //         ? MediaQuery.of(context).size.height * 0.01
            //         : MediaQuery.of(context).size.height * 0.03),
            Row(
              children: [
                dropdownPagination(),
              ],
            ),
            Expanded(
              flex: 3,
              child: data.length > 0
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var item = data[index];

                          return InkWell(
                            onTap: () {
                              // Método que se llama al dar clic en la tarjeta completa
                              // withdrawalInfo(context, item);
                            },
                            child: cardWithdrawal(item),
                          );
                        },
                      ),
                    )
                  : const Center(child: Text("Sin datos")),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height <= 640
                    ? MediaQuery.of(context).size.height * 0.01
                    : MediaQuery.of(context).size.height * 0.03),
            Flexible(
              child: data.isNotEmpty
                  ? Container(
                      height: 30,
                      child: paginationPhoneComplete(),
                    )
                  : Container(),
            ),
          ],
        ),
      )
    ]);
  }

  DropdownButton<int> dropdownPagination() {
    return DropdownButton<int>(
      value:
          pageSize, // Valor actual seleccionado (cantidad de registros por página)
      items: [
        DropdownMenuItem<int>(value: 10, child: Text('10')),
        DropdownMenuItem<int>(value: 50, child: Text('50')),
        DropdownMenuItem<int>(value: 100, child: Text('100')),
        DropdownMenuItem<int>(value: 200, child: Text('200')),
        DropdownMenuItem<int>(value: 1000, child: Text('1000')),
      ],
      onChanged: (newValue) {
        setState(() {
          pageSize = newValue!;
          paginateData(); // Llama a la función de paginación con la nueva cantidad
        });
      },
      style: TextStyle(fontSize: 12, color: Colors.black),
      dropdownColor: Colors.white,
    );
  }

  Card cardWithdrawal(item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${item['estado']}",
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: _getColorBasedOnState(item['estado']),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (item['comprobante'] != null &&
                        item['comprobante'].toString() != "null") {
                      launchUrl(Uri.parse(
                          "$generalServer${item['comprobante'].toString()}"));
                    } else {
                      print("No hay comprobante disponible.");
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: ColorsSystem().colorSelected,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Ver Detalle",
                      style: TextStylesSystem()
                          .ralewayStyle(11, FontWeight.w500, Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Monto: ",
                  style: TextStyle(
                    // fontFamily: 'Raleway',
                    fontSize: 12,
                    color: ColorsSystem().colorLabels,
                  ),
                ),
                Text(
                  "\$ ${NumberFormat("#,##0.00", "en_US").format(double.parse(item['monto'].toString()))}",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ColorsSystem().colorStore),
                )
              ],
            ),
            Text(
              "Fecha: ${item['fecha']}",
              style: TextStyle(
                // fontFamily: 'Raleway',
                fontSize: 12,
                color: ColorsSystem().colorLabels,
              ),
            ),
            Text(
              "Fecha T: ${item['fecha_transferencia']}",
              style: TextStyle(
                // fontFamily: 'Raleway',
                fontSize: 12,
                color: ColorsSystem().colorLabels,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row paginationComplete() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Distribuir los elementos
      children: [
        // Sección de resultados a la izquierda
        Text(
          '$from - $to de $total resultados',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        Center(child: Container(width: 400, child: numberPaginator())),
        // Text("aqui va el dropdown"),
        // Dropdown a la derecha
        dropdownPagination()
      ],
    );
  }

  Row paginationPhoneComplete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Distribuir los elementos
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: numberPaginator()),
      ],
    );
  }

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(
        label: Text("Fecha",
            style: TextStylesSystem()
                .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels)),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Monto a Retirar',
            style: TextStylesSystem()
                .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Fecha Transferencia',
            style: TextStylesSystem()
                .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels)),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Estado de Pago',
            style: TextStylesSystem()
                .ralewayStyle(16, FontWeight.bold, ColorsSystem().colorLabels)),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text(''),
        size: ColumnSize.M,
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    data;

    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Text(data[index]['fecha'].toString()),
            onTap: () {
              // withdrawalInfo(context, data[index]);
            },
          ),
          DataCell(
            Text(
              '\$${data[index]['monto'].toString()}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // withdrawalInfo(context, data[index]);
            },
          ),
          DataCell(
            Text(data[index]['fecha_transferencia'].toString()),
            onTap: () {
              // withdrawalInfo(context, data[index]);
            },
          ),
          DataCell(
            Text(data[index]['estado'].toString(),
                style: TextStylesSystem().ralewayStyle(
                    14,
                    FontWeight.bold,
                    _getColorBasedOnState(
                      data[index]['estado'].toString(),
                    ))),
            onTap: () {
              // withdrawalInfo(context, data[index]);
            },
          ),
          DataCell(
            TextButton(
              onPressed: data[index]['comprobante'].toString() != "null"
                  ? () {
                      launchUrl(Uri.parse(
                          "$generalServer${data[index]['comprobante'].toString()}"));
                    }
                  : null,
              style: TextButton.styleFrom(
                backgroundColor: ColorsSystem().colorSelected,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10.0), // Ajusta el radio del borde aquí
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility_outlined, // Ícono de ojo
                    color: Colors.white, // Ajusta el color según tu diseño
                  ),
                  SizedBox(width: 8), // Espacio entre el ícono y el texto
                  Text("Comprobante",
                      style: TextStylesSystem()
                          .ralewayStyle(14, FontWeight.bold, Colors.white)),
                ],
              ),
            ),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  sortFunc(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes'][name]
          .toString()
          .compareTo(a['attributes'][name].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes'][name]
          .toString()
          .compareTo(b['attributes'][name].toString()));
    }
  }

  Color _getColorBasedOnState(String estado) {
    switch (estado) {
      case 'REALIZADO':
        return Colors.green; // Color verde para "REALIZADO"
      case 'APROBADO':
        return ColorsSystem()
            .colorSelected; // Deja el fondo sin color para "APROBADO"
      case 'RECHAZADO':
        return Colors.red; // Color rojo para "RECHAZADO"
      default:
        return ColorsSystem()
            .colorLabels; // Color por defecto si el estado no coincide
    }
  }

  Future<dynamic> withdrawalInputDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(0.0), // Establece el radio del borde a 0
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.60,
            height: MediaQuery.of(context).size.height * 0.60,
            child: SellerWithdrawalDetails(),
            // child: WithdrawalSeller(),
          ),
        );
      },
    ).then((value) {
      // Aquí puedes realizar cualquier acción que necesites después de cerrar el diálogo
      // Por ejemplo, actualizar algún estado
      // setState(() {
      //   loadData(); // Actualiza el Future
      // });
    });
  }

  // Future<dynamic> withdrawalInputDialog(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Stack(
  //           children: [
  //             Container(
  //               width: MediaQuery.of(context).size.width * 0.27,
  //               height: MediaQuery.of(context).size.height * 0.45,
  //               child: WithdrawalSeller(),
  //             ),
  //             Positioned(
  //               right: 0,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   Navigator.of(context)
  //                       .pop(); // Cierra el modal al tocar el botón de cierre
  //                 },
  //                 child: Container(
  //                   padding: EdgeInsets.all(8.0),
  //                   child: Icon(Icons.close),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   ).then((value) {});
  // }

  Future<dynamic> withdrawalInfo(BuildContext context, data) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Container(
            // width: MediaQuery.of(context).size.width > 600
            //     ? MediaQuery.of(context).size.width * 0.50
            //     : MediaQuery.of(context).size.width * 0.95,
            // screenWidth > 600 ? 16 : 12;
            width: MediaQuery.of(context).size.width * 0.50,
            height: MediaQuery.of(context).size.height * 0.50,
            child: SellerWithdrawalInfoNew(data: data),
          ),
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
          // buttonSize: Size(30, 30), // Ajusta el tamaño del botón
          // buttonSelectedForegroundColor: Colors.white,
          buttonUnselectedForegroundColor: ColorsSystem().colorSection2,
          buttonSelectedBackgroundColor: ColorsSystem().colorStore,
          buttonUnselectedBackgroundColor: Colors.white,
          buttonShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          // height: 100,
          // contentPadding: EdgeInsets.only(bottom: 10),
          mainAxisAlignment: MainAxisAlignment.center,
          mode: ContentDisplayMode.numbers),
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
}
