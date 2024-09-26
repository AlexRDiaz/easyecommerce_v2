import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/transactions/transactionRollback.dart';
import 'package:frontend/ui/logistic/transactions_global/custom_drawer.dart';
import 'package:frontend/ui/logistic/transactions_global/transactionRollback.dart';
import 'package:frontend/ui/sellers/my_wallet/controllers/my_wallet_controller.dart';
import 'package:frontend/ui/sellers/transactions_global_seller/transaction_details.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionsGlobalSeller extends StatefulWidget {
  @override
  _TransactionsGlobalSellerState createState() =>
      _TransactionsGlobalSellerState();
}

class _TransactionsGlobalSellerState extends State<TransactionsGlobalSeller> {
  MyWalletController walletController = MyWalletController();
  TextEditingController searchController = TextEditingController();
  final _startDateController = TextEditingController(text: "1/1/2023");
  final _endDateController = TextEditingController(
      text:
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
  NumberPaginatorController paginatorController = NumberPaginatorController();
  TextEditingController origenController = TextEditingController(text: "TODO");
  TextEditingController statusController = TextEditingController(text: "TODO");
  List<String> sellers = ['TODO'];

  String _defaultsellerController =
      sharedPrefs!.getString("idComercialMasterSeller").toString();
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

  // String total = '0.0';
  String from = '0.0';
  String to = '0.0';
  List<DateTime?> _dates = [];

  String selectedValue = '';

  List arrayFiltersDefaultAnd = [
    {
      'equals/id_seller':
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    },
  ];

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

  List arrayFiltersAnd = [];
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
          currentPage,
          populate,
          [],
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
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
        totalrecords = int.parse(response['total'].toString());
        from = response['from'].toString();
        to = response['to'].toString();
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
          currentPage,
          populate,
          [],
          arrayFiltersAnd,
          arrayFiltersDefaultAnd,
          arrayFiltersOr,
          [],
          [],
          searchController.text,
          "TransaccionGlobal",
          "admission_date",
          _startDateController.text,
          _endDateController.text,
          "id:DESC");

      setState(() {
        data = [];
        data = response['data'];

        pageCount = response['last_page'];

        totalrecords = int.parse(response['total'].toString());
        from = response['from'].toString();
        to = response['to'].toString();
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
    // double heigth = MediaQuery.of(context).size.height * 0.5;
    // double width = MediaQuery.of(context).size.width * 0.6;
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        key: _scaffoldKey,
        body: Container(
          // padding: EdgeInsets.only(left: width * 0.01, right: width * 0.01),
          width: double.infinity,
          height: double.infinity,
          child: responsive(
              webMainContainer(context), mobileMainContainer(context), context),
        ),
        // endDrawer: CustomEndDrawer(
        // customContent: _leftWidgetWeb(width, heigth, context)),
      ),
    );
  }

  Stack webMainContainer(BuildContext context) {
    return Stack(
      children: [
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
          // height: MediaQuery.of(context).size.height * 0.8,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transacciones Global',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: ColorsSystem().colorStore,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: ColorsSystem().colorStore),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              " \$ $saldoText ",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                            height:
                                10), // Espacio entre el texto y el campo de búsqueda
                        searchBarOnly(context, 40),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status",
                          style: TextStylesSystem().ralewayStyle(
                              18, FontWeight.w700, ColorsSystem().colorLabels),
                        ),
                        SizedBox(
                            height:
                                10), // Espacio entre el texto y el campo de búsqueda
                        // searchBarOnly(context),
                        dropdownStatus(context, 0),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Origen",
                          style: TextStylesSystem().ralewayStyle(
                              18, FontWeight.w700, ColorsSystem().colorLabels),
                        ),
                        SizedBox(
                            height:
                                10), // Espacio entre el texto y el campo de búsqueda
                        // searchBarOnly(context),
                        dropdownOrigin(context, 0),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fecha",
                          style: TextStylesSystem().ralewayStyle(
                              18, FontWeight.w700, ColorsSystem().colorLabels),
                        ),
                        SizedBox(height: 10),
                        // Usamos los widgets _buildDateField para las fechas
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                startDateContainer(0),
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                endDateContainer(0),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "",
                          style: TextStylesSystem().ralewayStyle(
                              18, FontWeight.w700, ColorsSystem().colorLabels),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Distribuye los botones
                                    children: [
                                      // Botón para buscar
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: ColorsSystem()
                                              .colorInitialContainer, // Color de fondo del Container
                                          borderRadius: BorderRadius.circular(
                                              10), // Bordes redondeados
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorsSystem()
                                                  .colorInitialContainer
                                                  .withOpacity(
                                                      0.1), // Color de la sombra
                                              spreadRadius:
                                                  5, // Qué tan lejos se extiende la sombra
                                              blurRadius:
                                                  10, // Suavidad de la sombra
                                              offset: Offset(5,
                                                  0), // Desplazamiento de la sombra (x, y)
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            // Lógica de búsqueda aquí
                                            loadData();
                                          },
                                          icon: Icon(Icons.filter_alt_outlined,
                                              color: ColorsSystem()
                                                  .colorStore), // Ícono de filtro
                                          label: Text(""), // Texto del botón
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: ColorsSystem()
                                                .colorInitialContainer, // Color del botón
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // Bordes redondeados
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              5), // Espacio entre los dos botones
                                      // Botón para limpiar filtros
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: ColorsSystem()
                                              .colorInitialContainer, // Color de fondo del Container
                                          borderRadius: BorderRadius.circular(
                                              10), // Bordes redondeados
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorsSystem()
                                                  .colorInitialContainer
                                                  .withOpacity(
                                                      0.1), // Color de la sombra
                                              spreadRadius:
                                                  5, // Qué tan lejos se extiende la sombra
                                              blurRadius:
                                                  10, // Suavidad de la sombra
                                              offset: Offset(5,
                                                  0), // Desplazamiento de la sombra (x, y)
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            clearFilters();
                                            // setState(() {});
                                            loadData();
                                          },
                                          icon: Icon(
                                              Icons.filter_alt_off_outlined,
                                              color: ColorsSystem()
                                                  .colorStore), // Ícono de limpiar
                                          label: Text(""), // Texto del botón
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: ColorsSystem()
                                                .colorInitialContainer, // Color del botón para limpiar
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // Bordes redondeados
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Registros: ",
                            style: TextStylesSystem().ralewayStyle(18,
                                FontWeight.w700, ColorsSystem().colorStore)),
                        SizedBox(height: 5),
                        Text(
                          "$totalrecords",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: ColorsSystem().colorStore,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: buildDataTable(
                      context, getColumns(), buildDataRows(data))),
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
        )
      ],
    );
  }

// ! mobile
  Container startDateContainerMobile(setState, isMobile) {
    return Container(
      width: isMobile == 1 ? 200 : 150,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile == 1 ? 5 : 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          GestureDetector(
            onTap: () async {
              String? selectedDate = await OpenCalendar();
              if (selectedDate != null) {
                _startDateController.text = selectedDate;
                setState(() {}); // Actualiza el estado del diálogo
              }
            },
            child: Icon(
              Icons.calendar_month,
              size: isMobile == 1 ? 18.0 : 24.0,
              color: ColorsSystem().colorSection2,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _startDateController.text.isNotEmpty
                  ? _startDateController.text
                  : "Seleccionar fecha",
              style: TextStyle(
                color: ColorsSystem().colorSection2,
                fontSize: isMobile == 1 ? 12 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Container endDateContainerMobile(setState, isMobile) {
    return Container(
      width: isMobile == 1 ? 200 : 150,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile == 1 ? 5 : 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          GestureDetector(
            onTap: () async {
              String? selectedDate = await OpenCalendar();
              if (selectedDate != null) {
                _endDateController.text = selectedDate;
                setState(() {}); // Actualiza el estado del diálogo
              }
            },
            child: Icon(
              Icons.calendar_month,
              size: isMobile == 1 ? 18.0 : 24.0,
              color: ColorsSystem().colorSection2,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _endDateController.text.isNotEmpty
                  ? _endDateController.text
                  : "Seleccionar fecha",
              style: TextStyle(
                color: ColorsSystem().colorSection2,
                fontSize: isMobile == 1 ? 12 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

// ! web
  Container startDateContainer(isMobile) {
    return Container(
      width: isMobile == 1 ? 200 : 150,
      height: isMobile == 1 ? 20 : 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile == 1 ? 5 : 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          IconButton(
            color: ColorsSystem().colorSection2,
            icon: Icon(Icons.calendar_month, size: isMobile == 1 ? 18.0 : 24.0),
            onPressed: () async {
              _startDateController.text = await OpenCalendar();
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _startDateController.text,
              style: TextStyle(
                color: ColorsSystem().colorSection2,
                fontSize: isMobile == 1 ? 12 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Container endDateContainer(isMobile) {
    return Container(
      width: isMobile == 1 ? 200 : 150,
      height: isMobile == 1 ? 20 : 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile == 1 ? 5 : 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          IconButton(
            color: ColorsSystem().colorSection2,
            icon: Icon(Icons.calendar_month, size: isMobile == 1 ? 18.0 : 24.0),
            onPressed: () async {
              _startDateController.text = await OpenCalendar();
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _endDateController.text,
              style: TextStyle(
                color: ColorsSystem().colorSection2,
                fontSize: isMobile == 1 ? 12 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Stack mobileMainContainer(BuildContext context) {
    return Stack(
      children: [
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
                                        'Transacciones G.',
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
                              Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: ColorsSystem()
                                      .colorInitialContainer, // Color de fondo del Container
                                  borderRadius: BorderRadius.circular(
                                      5), // Bordes redondeados
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorsSystem()
                                          .colorInitialContainer
                                          .withOpacity(
                                              0.1), // Color de la sombra
                                      spreadRadius:
                                          5, // Qué tan lejos se extiende la sombra
                                      blurRadius: 10, // Suavidad de la sombra
                                      offset: Offset(5,
                                          0), // Desplazamiento de la sombr (x, y)
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    filtersDialog(context);
                                  },
                                  icon: Icon(Icons.filter_alt_outlined,
                                      color: ColorsSystem().colorStore,
                                      size: 14), // Ícono de filtro
                                  label: Text(""), // Texto del botón
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorsSystem()
                                        .colorInitialContainer, // Color del botón
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Bordes redondeados
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: 5), // Espacio entre los dos botones
                              Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: ColorsSystem()
                                      .colorInitialContainer, // Color de fondo del Container
                                  borderRadius: BorderRadius.circular(
                                      5), // Bordes redondeados
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorsSystem()
                                          .colorInitialContainer
                                          .withOpacity(
                                              0.1), // Color de la sombra
                                      spreadRadius:
                                          5, // Qué tan lejos se extiende la sombra
                                      blurRadius: 10, // Suavidad de la sombra
                                      offset: Offset(5,
                                          0), // Desplazamiento de la sombra (x, y)
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    clearFilters();
                                    // setState(() {});
                                    loadData();
                                  },
                                  icon: Icon(Icons.filter_alt_off_outlined,
                                      color: ColorsSystem().colorStore,
                                      size: 14), // Ícono de limpiar
                                  label: Text(""), // Texto del botón
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorsSystem()
                                        .colorInitialContainer, // Color del botón para limpiar
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Bordes redondeados
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height <= 640
                                  ? MediaQuery.of(context).size.height * 0.001
                                  : MediaQuery.of(context).size.height * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: ColorsSystem().colorStore),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "\$ $saldoText ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Registros: ",
                                      style: TextStylesSystem().ralewayStyle(
                                          12,
                                          FontWeight.w700,
                                          ColorsSystem().colorStore)),
                                  SizedBox(height: 5),
                                  Text(
                                    "$totalrecords",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: ColorsSystem().colorStore,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Container(
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.only(
                          //         topLeft: Radius.circular(10),
                          //         topRight: Radius.circular(10)),
                          //     color: Colors.white,
                          //   ),
                          //   width: MediaQuery.of(context).size.width,
                          //   child: Row(
                          //     children: [
                          //       // Primera columna con el texto y el valor, ocupa 3/4 del espacio
                          //       Expanded(
                          //         flex: 3, // Ocupa el 75% del ancho
                          //         child: Column(
                          //           crossAxisAlignment: CrossAxisAlignment.start,
                          //           children: [
                          //             Padding(
                          //               padding: const EdgeInsets.only(
                          //                   left: 20.0, top: 15.0),
                          //               child: Text(
                          //                 'Aprobados',
                          //                 style: TextStyle(
                          //                   fontFamily: 'Raleway',
                          //                   fontSize: 12,
                          //                   fontWeight: FontWeight.bold,
                          //                   color: ColorsSystem().colorLabels,
                          //                 ),
                          //               ),
                          //             ),
                          //             Padding(
                          //               padding: const EdgeInsets.only(
                          //                   left: 20.0, top: 5.0),
                          //               child: Text(
                          //                 dataCount['aprobados'] != null
                          //                     ? '\$ ${NumberFormat("#,##0.00", "en_US").format(double.parse(dataCount['aprobados']['suma_monto'].toString()))}'
                          //                     : "\$ 0.00",
                          //                 style: TextStyle(
                          //                   fontSize: 18,
                          //                   fontWeight: FontWeight.bold,
                          //                   color: ColorsSystem().colorStore,
                          //                 ),
                          //               ),
                          //             ),
                          //             SizedBox(height: 15),
                          //           ],
                          //         ),
                          //       ),
                          //       // Espacio entre las dos columnas
                          //       SizedBox(width: 20),
                          //       // Segunda columna con el número dentro de un círculo, ocupa 1/4 del espacio
                          //       Expanded(
                          //         flex: 1, // Ocupa el 25% del ancho
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             Container(
                          //               padding: EdgeInsets.all(
                          //                   16), // Aumenta el padding para que el círculo crezca
                          //               decoration: BoxDecoration(
                          //                 color:
                          //                     ColorsSystem().colorInterContainer,
                          //                 shape: BoxShape.circle,
                          //               ),
                          //               // El tamaño se ajusta dinámicamente en función del texto
                          //               child: LayoutBuilder(
                          //                 builder: (context, constraints) {
                          //                   String number = dataCount[
                          //                               'aprobados'] !=
                          //                           null
                          //                       ? dataCount['aprobados']['conteo']
                          //                           .toString()
                          //                       : "..."; // Ejemplo de número, aquí puede ser cualquier valor
                          //                   return Container(
                          //                     width:
                          //                         20, // Ajusta el tamaño del ancho en función del número
                          //                     height:
                          //                         20, // Ajusta la altura en función del número
                          //                     child: FittedBox(
                          //                       fit: BoxFit.scaleDown,
                          //                       child: Text(
                          //                         number,
                          //                         style: TextStyle(
                          //                           color:
                          //                               ColorsSystem().colorStore,
                          //                           fontSize: 20,
                          //                           fontWeight: FontWeight.bold,
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   );
                          //                 },
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.only(
                          //         bottomLeft: Radius.circular(10),
                          //         bottomRight: Radius.circular(10)),
                          //     color: Colors.white,
                          //   ),
                          //   width: MediaQuery.of(context).size.width,
                          //   child: Row(
                          //     children: [
                          //       // Primera columna con el texto y el valor, ocupa 3/4 del espacio
                          //       Expanded(
                          //         flex: 3, // Ocupa 75% del ancho
                          //         child: Column(
                          //           crossAxisAlignment: CrossAxisAlignment.start,
                          //           children: [
                          //             Padding(
                          //               padding: const EdgeInsets.only(
                          //                   left: 20.0, top: 15.0),
                          //               child: Text(
                          //                 'Realizados',
                          //                 style: TextStyle(
                          //                   fontFamily: 'Raleway',
                          //                   fontSize: 12,
                          //                   fontWeight: FontWeight.bold,
                          //                   color: ColorsSystem().colorLabels,
                          //                 ),
                          //               ),
                          //             ),
                          //             Padding(
                          //               padding: const EdgeInsets.only(
                          //                   left: 20.0, top: 5.0),
                          //               child: Text(
                          //                 dataCount['realizados'] != null
                          //                     ? '\$ ${NumberFormat("#,##0.00", "en_US").format(double.parse(dataCount['realizados']['suma_monto'].toString()))}'
                          //                     : "\$0.00",
                          //                 style: TextStyle(
                          //                   fontSize: 18,
                          //                   fontWeight: FontWeight.bold,
                          //                   color: ColorsSystem().colorStore,
                          //                 ),
                          //               ),
                          //             ),
                          //             SizedBox(
                          //               height: 15,
                          //             )
                          //           ],
                          //         ),
                          //       ),
                          //       // Espacio entre las dos columnas
                          //       SizedBox(width: 20),
                          //       // Segunda columna con el número dentro de un círculo, ocupa 1/4 del espacio
                          //       Expanded(
                          //         flex: 1, // Ocupa 25% del ancho
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             Container(
                          //               padding: EdgeInsets.all(
                          //                   16), // Aumenta el padding para que el círculo crezca
                          //               decoration: BoxDecoration(
                          //                 color:
                          //                     ColorsSystem().colorInterContainer,
                          //                 shape: BoxShape.circle,
                          //               ),
                          //               // El tamaño se ajusta dinámicamente en función del texto
                          //               child: LayoutBuilder(
                          //                 builder: (context, constraints) {
                          //                   String number =
                          //                       dataCount['realizados'] != null
                          //                           ? dataCount['realizados']
                          //                                   ['conteo']
                          //                               .toString()
                          //                           : "..."; // Ejemplo de número
                          //                   return Container(
                          //                     width:
                          //                         20, // Ajusta el tamaño del ancho en función del número
                          //                     height:
                          //                         20, // Ajusta la altura en función del número
                          //                     child: FittedBox(
                          //                       fit: BoxFit.scaleDown,
                          //                       child: Text(
                          //                         number,
                          //                         style: TextStyle(
                          //                             color: ColorsSystem()
                          //                                 .colorStore,
                          //                             fontSize: 20,
                          //                             fontWeight:
                          //                                 FontWeight.bold),
                          //                       ),
                          //                     ),
                          //                   );
                          //                 },
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                      : Container()),
            ],
          ),
        )
      ],
    );
  }

  Future<dynamic> filtersDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.50,
                height: MediaQuery.of(context).size.height * 0.60,
                child: _leftWidgetMobile(
                    context, setState), // Pasamos setState aquí
              );
            },
          ),
        );
      },
    );
  }

  Future<dynamic> detailsDialog(BuildContext context, data) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.50,
                height: MediaQuery.of(context).size.height * 0.60,
                child: TransactionDetailsInfoNew(data:data), // Pasamos setState aquí
              );
            },
          ),
        );
      },
    );
  }

  Card cardWithdrawal(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Cambiado a Row para alinear en horizontal
          children: [
            // Primera columna con el código y monto
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "${item['code'].toString()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: ColorsSystem().colorLabels,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Monto: ",
                      style: TextStyle(
                        fontSize: 10,
                        color: ColorsSystem().colorLabels,
                      ),
                    ),
                    Text(
                      "\$ ${NumberFormat("#,##0.00", "en_US").format(double.parse(item['total_transaction'].toString()))}",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ColorsSystem().colorStore,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Segunda columna con los valores
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "\$ ${item['current_value'].toString()}",
                  style: TextStyle(
                    fontSize: 10,
                    color: ColorsSystem().colorLabels,
                  ),
                ),
                Text(
                  "\$ ${item['previous_value'].toString()}",
                  style: TextStyle(
                    fontSize: 10,
                    color: ColorsSystem().colorLabels,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // print("Detalles de ${item['code']}");
                detailsDialog(context, item);
              },
              child: Icon(
                Icons.visibility,
                color: ColorsSystem().colorStore,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ! mobile
  Container dropdownOriginMobile(BuildContext context, int isMobile, setState) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: listOrigen
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: origenController.text,
          onChanged: (String? value) {
            setState(() {
              origenController.text = value ?? "";
            });

            arrayFiltersAnd
                .removeWhere((element) => element.containsKey("equals/origin"));
            if (value != '') {
              if (value == "TODO") {
                arrayFiltersAnd.removeWhere(
                    (element) => element.containsKey("equals/origin"));
              } else {
                arrayFiltersAnd.add({"equals/origin": value});
              }
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  Container dropdownStatusMobile(BuildContext context, int isMobile, setState) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: listStatus
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: statusController.text,
          onChanged: (String? value) {
            setState(() {
              statusController.text = value ?? "";
            });

            arrayFiltersAnd
                .removeWhere((element) => element.containsKey("equals/status"));
            if (value != '') {
              if (value == "TODO") {
                arrayFiltersAnd.removeWhere(
                    (element) => element.containsKey("equals/status"));
              } else {
                arrayFiltersAnd.add({"equals/status": value});
              }
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  // ! web

  Container dropdownOrigin(BuildContext context, isMobile) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: listOrigen
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: origenController.text,
          onChanged: (String? value) {
            setState(() {
              origenController.text = value ?? "";
            });

            arrayFiltersAnd
                .removeWhere((element) => element.containsKey("equals/origin"));
            if (value != '') {
              if (value == "TODO") {
                arrayFiltersAnd.removeWhere(
                    (element) => element.containsKey("equals/origin"));
              } else {
                arrayFiltersAnd.add({"equals/origin": value});
              }
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  Container dropdownStatus(BuildContext context, isMobile) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: listStatus
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: statusController.text,
          onChanged: (String? value) {
            setState(() {
              statusController.text = value ?? "";
            });

            arrayFiltersAnd
                .removeWhere((element) => element.containsKey("equals/status"));
            if (value != '') {
              if (value == "TODO") {
                arrayFiltersAnd.removeWhere(
                    (element) => element.containsKey("equals/status"));
              } else {
                arrayFiltersAnd.add({"equals/status": value});
              }
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  Container searchBarOnly(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.20,
      child: _modelTextField(
        text: "Buscar",
        controller: searchController,
      ),
    );
  }

  Container searchBarOnlyM(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      height: height,
      width: 200,
      child: _modelTextFieldM(
        text: "Buscar",
        controller: searchController,
      ),
    );
  }

  void clearFilters() {
    arrayFiltersAnd.clear();
    statusController.text = 'TODO';
    origenController.text = 'TODO';
    _startDateController.clear();
    _endDateController.clear();
    searchController.clear();
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
      case 'NO ENTREGADO':
        return Colors.red; // Color rojo para "RECHAZADO"
      case 'ENTREGADO':
        return Colors.green;
      case 'NOVEDAD':
        return Colors.amber;
      default:
        return ColorsSystem()
            .colorLabels; // Color por defecto si el estado no coincide
    }
  }

  Future<String> OpenCalendar() async {
    String nuevaFecha = "";

    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
        yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
        selectedYearTextStyle: TextStyle(fontWeight: FontWeight.bold),
        weekdayLabelTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      dialogSize: const Size(325, 400),
      value: _dates,
      borderRadius: BorderRadius.circular(15),
    );

    setState(() {
      if (results != null) {
        String fechaOriginal = results![0]
            .toString()
            .split(" ")[0]
            .split('-')
            .reversed
            .join('-')
            .replaceAll("-", "/");
        List<String> componentes = fechaOriginal.split('/');

        String dia = int.parse(componentes[0]).toString();
        String mes = int.parse(componentes[1]).toString();
        String anio = componentes[2];

        nuevaFecha = "$dia/$mes/$anio";
      }
    });
    return nuevaFecha;
  }

  // ! old
  Widget buildDataTable(BuildContext context, columns, rows) {
    return DataTable2(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      dataRowColor: MaterialStateColor.resolveWith((states) {
        return Colors.white;
      }),
      dividerThickness: 1,
      headingTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      dataTextStyle: const TextStyle(color: Colors.black),
      columnSpacing: 12,
      headingRowHeight: 70,
      horizontalMargin: 32,
      minWidth: 7000,
      dataRowHeight: 70,
      columns: columns,
      rows: rows,
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

  // ! ******************

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

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(
        fixedWidth: 200,
        label: Text('Codigo',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 160,
        label: Text('Fecha de Ingreso',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 160,
        label: Text('Fecha de Entrega',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Estado de Entrega',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      // ! ------------------------26---------------------
      DataColumn2(
        fixedWidth: 250,
        label: Text('Estado de Devolución',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Origen',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Precio Retiro',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Precio Total',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Entrega',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo No Entregado',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Devolución',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Proveedor',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Costo Referido',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Total',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Saldo Anterior',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 250,
        label: Text('Saldo Actual',
            style: TextStylesSystem()
                .ralewayStyle(14, FontWeight.w700, ColorsSystem().colorLabels)),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        color: MaterialStateProperty.all(Colors.white),
        cells: [
          DataCell(InkWell(
              child: Text(data[index]['code'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
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
              child: Text(data[index]['status'].toString(),
                  style: TextStylesSystem()
                      .ralewayStyle(14, FontWeight.w500, Colors.black)),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['return_state'].toString(),
                  style: TextStylesSystem()
                      .ralewayStyle(14, FontWeight.w500, Colors.black)),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(
                data[index]['origin'].toString(),
                style: TextStylesSystem()
                    .ralewayStyle(14, FontWeight.w500, Colors.black),
              ),
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
                        : Colors.green,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text("\$ ${data[index]['previous_value'].toString()}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text("\$ ${data[index]['current_value'].toString()}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
        ],
      );
      rows.add(row);
    }

    return rows;
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
                  // Expanded(child: TransactionRollbackGlobal())
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

  Scaffold _leftWidgetMobile(BuildContext context, setState) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Filtros",
          style: TextStylesSystem().ralewayStyle(
            14,
            FontWeight.bold,
            ColorsSystem().colorLabels,
          ),
        ),
        iconTheme: IconThemeData(
          color: ColorsSystem().colorLabels,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
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
              top: MediaQuery.of(context).size.height * 0.02,
              left: 8,
              right: 8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: constraints.maxHeight,
                                child: SingleChildScrollView(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Busqueda",
                                          style:
                                              TextStylesSystem().ralewayStyle(
                                            11,
                                            FontWeight.w600,
                                            ColorsSystem().colorLabels,
                                          ),
                                        ),
                                        searchBarOnlyM(context, 20),
                                        SizedBox(height: 10),
                                        Text(
                                          "Status",
                                          style:
                                              TextStylesSystem().ralewayStyle(
                                            11,
                                            FontWeight.w600,
                                            ColorsSystem().colorLabels,
                                          ),
                                        ),
                                        dropdownStatusMobile(context, 1,
                                            setState), // Pasamos setState
                                        SizedBox(height: 10),
                                        Text(
                                          "Origen",
                                          style:
                                              TextStylesSystem().ralewayStyle(
                                            11,
                                            FontWeight.w600,
                                            ColorsSystem().colorLabels,
                                          ),
                                        ),
                                        dropdownOriginMobile(context, 1,
                                            setState), // Pasamos setState
                                        SizedBox(height: 10),
                                        Text(
                                          "Fecha",
                                          style:
                                              TextStylesSystem().ralewayStyle(
                                            11,
                                            FontWeight.w600,
                                            ColorsSystem().colorLabels,
                                          ),
                                        ),
                                        startDateContainerMobile(setState, 1),
                                        SizedBox(height: 5),
                                        endDateContainerMobile(setState, 1),
                                        SizedBox(height: 20),
                                        filterButton(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  SizedBox filterButton() {
    return SizedBox(
      height: 20,
      width: 200, // Ancho de 200
      child: TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStatePropertyAll(ColorsSystem().colorSelected),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Borde redondeado de 5
            ),
          ),
        ),
        onPressed: () {
          loadData();
          Navigator.pop(context);
        },
        child: Text(
          "Filtrar",
          style: TextStylesSystem().ralewayStyle(
            11,
            FontWeight.w600,
            Colors.white,
          ),
        ),
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
          // Container(
          //   width: 300,
          //   color: Color(0xFFE8DEF8),
          //   child: DropdownButtonHideUnderline(
          //     child: DropdownButton2<String>(
          //       isExpanded: true,
          //       hint: Text(
          //         'Seleccione Vendedor',
          //         style: TextStyle(
          //           fontSize: 14,
          //           color: Theme.of(context).hintColor,
          //         ),
          //       ),
          //       items: _addDividersAfterItems(sellers),
          //       value: selectedValueSeller,
          //       onChanged: (String? value) {
          //         setState(() {
          //           selectedValueSeller = value;
          //         });

          //         arrayFiltersAnd.removeWhere(
          //             (element) => element.containsKey("equals/id_seller"));
          //         if (value != '') {
          //           if (value == "TODO") {
          //             arrayFiltersAnd.removeWhere(
          //                 (element) => element.containsKey("equals/id_seller"));

          //             _defaultsellerController = "0";
          //           } else {
          //             arrayFiltersAnd
          //                 .add({"equals/id_seller": value!.split('-')[1]});

          //             _defaultsellerController = value.split('-')[1].toString();
          //           }
          //         }

          //         // loadData();
          //       },
          //       buttonStyleData: const ButtonStyleData(
          //         padding: EdgeInsets.symmetric(horizontal: 16),
          //         height: 40,
          //         width: 140,
          //       ),
          //       dropdownStyleData: const DropdownStyleData(
          //         maxHeight: 200,
          //       ),
          //       menuItemStyleData: MenuItemStyleData(
          //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         customHeights: _getCustomItemsHeights(sellers),
          //       ),
          //       iconStyleData: const IconStyleData(
          //         openMenuIcon: Icon(Icons.arrow_drop_up),
          //       ),
          //     ),
          //   ),
          // ),
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
            // Container(
            //   width: 50,
            //   child: Text(
            //     label + ":",
            //   ),
            // ),
            Container(
              width: 150,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  isDense: true, // Reduce la altura del campo
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Bordes más curvados
                    borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1), // Color y ancho del borde
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Bordes más curvados al enfocar
                    borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.5), // Color del borde cuando está enfocado
                  ),
                  hintText: "31/1/2023",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, // Reduce la altura del campo
                    horizontal: 5, // Ajusta el espaciado interior
                  ),
                  // suffixIcon: const Icon(
                  //   Icons.calendar_today, // Icono de calendario
                  //   color: Colors.grey, // Color del icono
                  // ),
                  prefixIcon: const Icon(
                    Icons.calendar_today, // Icono de calendario
                    color: Colors.grey, // Color del icono
                  ),
                ),
                style: const TextStyle(
                  fontSize:
                      12, // Ajusta el tamaño del texto según tus necesidades
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Este campo no puede estar vacío";
                  }
                  return null;
                },
              ),
            )
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

  _modelTextField({text, controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo
        borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
      ),
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
        },
        style: TextStylesSystem()
            .ralewayStyle(14, FontWeight.w500, ColorsSystem().colorSection2),
        textAlign: TextAlign.left, // Centra el texto
        decoration: InputDecoration(
          fillColor: Colors.white, // Color de fondo del campo
          // filled: true, // Asegura que el color de fondo se aplique
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.clear();
                      loadData();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          // focusColor: Color(0xFFE8DEF8),
          iconColor: ColorsSystem().colorSection2,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
            borderSide: BorderSide.none, // Elimina los bordes
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Sin borde
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Sin borde al estar enfocado
          ),
        ),
      ),
    );
  }

  _modelTextFieldM({text, controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo
        borderRadius: BorderRadius.circular(5), // Esquinas redondeadas
      ),
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // loadData();
        },
        style: TextStylesSystem()
            .ralewayStyle(11, FontWeight.w500, ColorsSystem().colorSection2),
        textAlign: TextAlign.left, // Alinea el texto a la izquierda
        decoration: InputDecoration(
          fillColor: Colors.white, // Color de fondo del campo
          prefixIcon: const Icon(
            Icons.search,
            size: 11, // Tamaño reducido del ícono
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.clear();
                      // loadData();
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    size: 11, // Tamaño reducido del ícono de cerrar
                  ),
                )
              : null,
          hintText: text,
          contentPadding:
              const EdgeInsets.only(bottom: 10), // Ajusta el padding vertical
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5), // Esquinas redondeadas
            borderSide: BorderSide.none, // Sin bordes
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none, // Sin borde
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none, // Sin borde al estar enfocado
          ),
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

  DropdownButton<int> dropdownPagination() {
    return DropdownButton<int>(
      value:
          pageSize, // Valor actual seleccionado (cantidad de registros por página)
      items: [
        // DropdownMenuItem<int>(value: 10, child: Text('10')),
        // DropdownMenuItem<int>(value: 50, child: Text('50')),
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

  Row paginationComplete() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Distribuir los elementos
      children: [
        // Sección de resultados a la izquierda
        Text(
          '$from - $to de $totalrecords resultados',
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

  // Column(
  //   children: [
  //     Container(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment
  //             .spaceBetween, // Distribuye los botones
  //         children: [
  //           // Botón para buscar
  //           Container(
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: ColorsSystem()
  //                   .colorInitialContainer, // Color de fondo del Container
  //               borderRadius: BorderRadius.circular(
  //                   10), // Bordes redondeados
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: ColorsSystem()
  //                       .colorInitialContainer
  //                       .withOpacity(
  //                           0.1), // Color de la sombra
  //                   spreadRadius:
  //                       5, // Qué tan lejos se extiende la sombra
  //                   blurRadius:
  //                       10, // Suavidad de la sombra
  //                   offset: Offset(5,
  //                       0), // Desplazamiento de la sombra (x, y)
  //                 ),
  //               ],
  //             ),
  //             child: ElevatedButton.icon(
  //               onPressed: () async {
  //                 // Lógica de búsqueda aquí
  //                 // loadData();
  //                 RollbackInputDialog(context);
  //               },
  //               icon: Icon(Icons.restore_outlined,
  //                   color: ColorsSystem()
  //                       .colorStore), // Ícono de filtro
  //               label: Text(""), // Texto del botón
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: ColorsSystem()
  //                     .colorInitialContainer, // Color del botón
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius:
  //                       BorderRadius.circular(
  //                           10), // Bordes redondeados
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ],
  // )
}
