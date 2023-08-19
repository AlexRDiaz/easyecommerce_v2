import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';

import 'package:frontend/ui/sellers/dashboard/filter_details.dart';
import 'package:frontend/ui/sellers/dashboard/storage_info_card.dart';
import 'package:frontend/ui/widgets/cartesian_chart_dashboard.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/pie_chart_dashboard.dart';

class DashBoardLogistic extends StatefulWidget {
  const DashBoardLogistic({super.key});

  @override
  State<DashBoardLogistic> createState() => _DashBoardLogisticState();
}

class _DashBoardLogisticState extends State<DashBoardLogistic> {
  bool entregado = false;
  bool noEntregado = false;
  bool novedad = false;
  bool reagendado = false;
  bool enRuta = false;
  bool enOficina = false;
  bool programado = false;
  bool openStatus = false;
  bool changeGraphicOptions = false;
  List checks = [];
  List<Map<String, dynamic>> routeSelected = [];
  TextEditingController _search = TextEditingController();
  List sections = [];
  List routes = [];
  List<String> sellers = [];
  Map data = {};
  List subData = [];
  List tableData = [];
  List subFilters = [];
  String? selectValueTransport = null;
  String? selectValueSeller = null;

  String startDate = "";
  String endDate = "";

  String idTransport = "";

  List<String> transports = [];
  String? selectValueOperator = null;
  List<String> operators = [];
  List<Map<String, dynamic>> dataChart = [];
  List<DateTime?> _datesDesde = [];
  List<DateTime?> _datesHasta = [];
  List counters = [];
  List dataRoutes = [];
  bool sort = false;
  String currentValue = "";
  int total = 0;
  int entregados = 0;
  int noEntregados = 0;
  int conNovedad = 0;
  int reagendados = 0;
  int regEnRuta = 0;
  int regEnOficina = 0;
  int regPedidoProgramado = 0;
  double totalValoresRecibidos = 0;
  double costoTransportadora = 0;
  double costoDevoluciones = 0;
  double utilidades = 0;
  List<Map<String, dynamic>> routeCounter = [];
  bool isFirst = true;
  int counterLoad = 0;
  String transporterOperator = 'TODO';
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;
  List<String> listOperators = [];
  Color currentColor = Color.fromARGB(255, 108, 108, 109);
  List<Map<dynamic, dynamic>> arrayFiltersAndEq = [];
  var arrayDateRanges = [];
  List<FilterCheckModel> filters = [
    FilterCheckModel(
        color: Colors.red,
        numOfFiles: 0,
        percentage: 0,
        svgSrc: "assets/icons/Documents.svg",
        title: "Entregados",
        filter: "ENTREGADO",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 2, 51, 22),
        numOfFiles: 0,
        percentage: 0,
        svgSrc: "assets/icons/Documents.svg",
        title: "No entregado",
        filter: "NO ENTREGADO",
        check: false),
    FilterCheckModel(
        color: const Color.fromARGB(255, 76, 54, 244),
        numOfFiles: 0,
        percentage: 0,
        svgSrc: "assets/icons/Documents.svg",
        title: "Novedad",
        filter: "NOVEDAD",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 42, 163, 67),
        numOfFiles: 0,
        percentage: 0,
        svgSrc: "assets/icons/Documents.svg",
        title: "Reagendado",
        filter: "REAGENDADO",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 146, 76, 29),
        numOfFiles: 0,
        percentage: 0,
        svgSrc: "assets/icons/Documents.svg",
        title: "En ruta",
        filter: "EN RUTA",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 11, 6, 123),
        numOfFiles: 0,
        percentage: 0,
        svgSrc: "assets/icons/Documents.svg",
        title: "En oficina",
        filter: "EN OFICINA",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 146, 18, 73),
        numOfFiles: 0,
        percentage: 0,
        svgSrc: "assets/icons/Documents.svg",
        title: "Pedido programado",
        filter: "PEDIDO PROGRAMADO",
        check: false),
  ];

  List arrayFiltersAnd = [];

  List populate = [
    'pedido_fecha',
    'transportadora',
    'ruta',
    'sub_ruta',
    'operadore',
    "operadore.user",
    "users",
    "users.vendedores"
  ];

  @override
  Future<void> didChangeDependencies() async {
    initializeDates();
    loadRoutes();

    loadConfigs();
    //  await loadData();
    super.didChangeDependencies();
  }

  loadRoutes() async {
    routes = await Connections().getRoutes();
    for (var route in routes) {
      route['check'] = false;
    }
  }

  initializeDates() {
    if (sharedPrefs!.getString("dateDesdeLogistica") == null) {
      sharedPrefs!.setString("dateDesdeLogistica",
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
    }
    if (sharedPrefs!.getString("dateHastaLogistica") == null) {
      sharedPrefs!.setString("dateHastaLogistica",
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
    }
  }

  String capitalize(String input) {
    if (input == null || input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  loadConfigs() async {
    isLoading = true;

    var responseOperator = [];
    setState(() {
      sellers = [];
      transports = [];
      operators = [];
    });

    var responseSellers = await Connections().getAllSellers();
    var responseTransports = await Connections().getAllTransportators();
    if (selectValueTransport != null) {
      responseOperator =
          await Connections().getAllOperatorsAndByTransport(idTransport);
    } else {
      responseOperator = await Connections().getAllOperators();
    }

    for (var i = 0; i < responseSellers.length; i++) {
      if (!sellers.contains(
          '${responseSellers[i]['vendedores'] != null && responseSellers[i]['vendedores'].toString() != "[]" ? responseSellers[i]['vendedores'][0]['Nombre_Comercial'] : ""}-${responseSellers[i]['vendedores'] != null && responseSellers[i]['vendedores'].toString() != "[]" ? responseSellers[i]['vendedores'][0]['Id_Master'] : ""}')) {
        setState(() {
          sellers.add(
              '${responseSellers[i]['vendedores'] != null && responseSellers[i]['vendedores'].toString() != "[]" ? responseSellers[i]['vendedores'][0]['Nombre_Comercial'] : ""}-${responseSellers[i]['vendedores'] != null && responseSellers[i]['vendedores'].toString() != "[]" ? responseSellers[i]['vendedores'][0]['Id_Master'] : ""}');
        });
      }
    }

    for (var i = 0; i < responseTransports.length; i++) {
      setState(() {
        transports.add(
            '${responseTransports[i]['attributes']['Nombre']}-${responseTransports[i]['id']}');
      });
    }
    for (var i = 0; i < responseOperator.length; i++) {
      setState(() {
        operators.add(
            '${responseOperator[i]['username']}-${responseOperator[i]['operadore'] != null ? responseOperator[i]['operadore']['id'] : '0'}');
      });
    }

    isLoading = false;
    setState(() {});
  }

  loadData() async {
    isLoading = true;
    setState(() {
      subFilters = [];
      sections = [];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = await Connections()
        .getOrdersDashboardLogistic(populate, arrayFiltersAnd);
    var responseRoutes = await Connections()
        .getOrdersDashboardLogisticRoutes(populate, arrayFiltersAnd);
    setState(() {
      data = response;
      dataRoutes = responseRoutes;

      loadCounterStates();
      loadCounterRoute();
    });

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    isLoading = false;
  }

  bool _isMenuOpen = true;
  final double _menuWidth = 270.0; // Ancho del menú lateral

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  loadCounterStates() {
    entregados = int.parse(data['ENTREGADO'].toString()) ?? 0;
    noEntregados = int.parse(data['NO ENTREGADO'].toString()) ?? 0;
    conNovedad = int.parse(data['NOVEDAD'].toString()) ?? 0;
    reagendados = int.parse(data['REAGENDADO'].toString()) ?? 0;
    regEnRuta = int.parse(data['EN RUTA'].toString()) ?? 0;
    regEnOficina = int.parse(data['EN OFICINA'].toString()) ?? 0;
    regPedidoProgramado = int.parse(data['PEDIDO PROGRAMADO'].toString()) ?? 0;

    List arrayVals = [
      entregados,
      noEntregados,
      conNovedad,
      reagendados,
      regEnRuta,
      regEnOficina,
      regPedidoProgramado
    ];

    List<FilterCheckModel> auxFilter = List.from(filters);

    for (var i = 0; i < auxFilter.length; i++) {
      auxFilter[i].numOfFiles = arrayVals[i];
    }

    setState(() {
      filters = auxFilter;
      routeCounter = routeCounter;
    });
  }

  loadCounterRoute() {
    int rutaId = -1;
    int rutaEntregado = 0;
    int rutaNoEntregado = 0;
    int rutaReagendado = 0;
    int rutaNovedad = 0;
    int rutaEnRuta = 0;
    int rutaEnOficina = 0;
    int rutaPedidoProgramado = 0;
    Color colors = Colors.black;
    for (var mapa in dataRoutes) {
      rutaId = mapa["rutaId"];
      rutaEntregado = mapa["ENTREGADO"];
      rutaNoEntregado = mapa["NO ENTREGADO"];
      rutaReagendado = mapa["REAGENDADO"];
      rutaNovedad = mapa["NOVEDAD"];
      rutaEnRuta = mapa["EN RUTA"];
      rutaEnOficina = mapa["EN OFICINA"];
      rutaPedidoProgramado = mapa["PEDIDO PROGRAMADO"];

      Map<String, dynamic> newMap = {
        'x': rutaId,
        'y1': {
          "title": "entregado",
          "value": rutaEntregado,
          "color": Colors.red
        },
        'y2': {
          "title": "No Entregado",
          "value": rutaNoEntregado,
          "color": Color.fromARGB(255, 2, 51, 22)
        },
        'y3': {
          "title": "Novedad",
          "value": rutaNovedad,
          "color": Color.fromARGB(255, 76, 54, 244)
        },
        'y4': {
          "title": "Reagendado",
          "value": rutaReagendado,
          "color": Color.fromARGB(255, 42, 163, 67)
        },
        'y5': {
          "title": "En Ruta",
          "value": rutaEnRuta,
          "color": Color.fromARGB(255, 146, 76, 29)
        },
        'y6': {
          "title": "En Oficina",
          "value": rutaEnOficina,
          "color": Color.fromARGB(255, 11, 6, 123)
        },
        'y7': {
          "title": "Programado",
          "value": rutaEntregado,
          "color": Color.fromARGB(255, 146, 18, 73)
        },
        // 'color': colors
      };

      routeCounter.add(newMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Row(
      children: [
        // Contenido principal de la página
        Expanded(
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Column(
              children: [
                _dates(context),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: DefaultTabController(
                      length:
                          2, // Cambia el número de pestañas según tus necesidades
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: Colors.black,
                            tabs: [
                              GestureDetector(
                                  onTap: () {
                                    changeGraphicOptions = true;
                                  },
                                  child: Tab(icon: Icon(Icons.pie_chart))),
                              GestureDetector(
                                  onTap: () {
                                    changeGraphicOptions = false;
                                  },
                                  child: Tab(icon: Icon(Icons.bar_chart))),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(3)),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 200,
                                    child: DynamicPieChart(
                                      filters: filters,
                                    )),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(3)),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 200,
                                    child: isLoading
                                        ? CustomCircularProgressIndicator()
                                        : DynamicStackedColumnChart(
                                            dataList: routeSelected)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Expanded(
                //   child: Container(
                //       decoration: BoxDecoration(
                //           border: Border.all(color: Colors.grey),
                //           borderRadius: BorderRadius.circular(3)),
                //       width: MediaQuery.of(context).size.width * 0.8,
                //       height: 200,
                //       child: isLoading
                //           ? CustomCircularProgressIndicator()
                //           : DynamicPieChart(
                //               filters: filters,
                //             )),
                // ),
                // Expanded(
                //   child: Container(
                //       decoration: BoxDecoration(
                //           border: Border.all(color: Colors.grey),
                //           borderRadius: BorderRadius.circular(3)),
                //       width: MediaQuery.of(context).size.width * 0.8,
                //       height: 200,
                //       child: isLoading
                //           ? CustomCircularProgressIndicator()
                //           : DynamicStackedColumnChart(dataList: routeSelected)),
                // ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: _isMenuOpen ? false : true,
          child: IconButton(
            icon: Icon(Icons.arrow_left_outlined),
            onPressed: _toggleMenu,
          ),
        ),

        // Menú lateral desplegable
        responsive(
            Visibility(
              visible: _isMenuOpen,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.black)),
                  color: Colors.white,
                ),
                width: _isMenuOpen ? _menuWidth : 0,
                child: _isMenuOpen
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Configuraciones',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _isMenuOpen = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              child: ExpansionTile(
                                title: Text("Entidades"),
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Container(
                                            width: 100,
                                            child: Text("Vendedores: ")),
                                        _sellers(context)
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Container(
                                            width: 100,
                                            child: Text("Transportistas: ")),
                                        _sellersTransport(context)
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Container(
                                            width: 100,
                                            child: Text("Operadores: ")),
                                        _operators(context)
                                      ],
                                    ),
                                  ),
                                  //  _sellers(context),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              child: ExpansionTile(
                                title: Text("Ciudades"),
                                children: routes
                                    .map((route) => Container(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 200,
                                                child: Text(
                                                  capitalize(route['attributes']
                                                          ['Titulo']
                                                      .toString()),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              Checkbox(
                                                value: route['check'],
                                                onChanged: (value) {
                                                  setState(() {
                                                    route['check'] = value;
                                                  });
                                                  addCounterRoute(
                                                      route['id'],
                                                      route['attributes']
                                                          ['Titulo'],
                                                      value);
                                                },
                                              )
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ),
            ),
            Container(
                child: IconButton(
                    onPressed: () {
                      showModal(context);
                    },
                    icon: Icon(Icons.settings))),
            context),

        // Container(
        //   width: 1235,
        // ),
        // Positioned(
        // RightSideWidget(),
        //   bottom: 0.0,
        //   top: 0.0,
        //   right: 0.0,
        // )
        // Container(
        //   padding: EdgeInsets.only(left: 20, right: 15, top: 20, bottom: 20),
        //   child: InputDecorator(
        //     decoration: InputDecoration(
        //       labelText: 'Configuraciones',
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(10.0),
        //       ),
        //     ),
        //     child: Column(children: [
        //       _dates(context),
        //       _sellers(context),
        //       _sellersTransport(context),
        //       _operators(context),
        //     ]),
        //   ),
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Container(
        //       child: Expanded(
        //         child: GridView.count(
        //           crossAxisCount:
        //               2, // Puedes cambiar a 3 si quieres tres columnas
        //           crossAxisSpacing: 8.0,
        //           mainAxisSpacing: 8.0,
        //           shrinkWrap: true,
        //           children: filters
        //               .map((elemento) => FilterStatus(
        //                     svgSrc: elemento.svgSrc!,
        //                     title: elemento.title!,
        //                     filter: elemento.filter!,
        //                     color: elemento.color!,
        //                     details: addTableRows,
        //                     percentage: elemento.percentage!,
        //                     numOfFiles: elemento.numOfFiles!,
        //                     function: changeValue,
        //                   ))
        //               .toList(),
        //         ),
        //       ),
        //     ),
        //   ],
        // )
      ],
    )));
  }

  addCounterRoute(routeId, title, value) {
    var route = routeCounter.firstWhere((route) => route['x'] == routeId);
    if (value) {
      setState(() {
        route['title'] = title;
        routeSelected.add(route);
      });
    } else {
      route['title'] = title;
      routeSelected.removeWhere((route) => route['x'] == routeId);
    }
  }

  Widget _expansionPanel() {
    final List _data = [
      ['1', '2', '3', '4']
    ];

    return ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            openStatus = !openStatus;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Expanded(child: Text("fvdvd"));
            },
            body: Expanded(child: Text("fvdvd")),
            isExpanded: openStatus,
          )
        ]);
  }

  Container dataTableDetails() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.48,
      width: 690,
      padding: EdgeInsets.only(left: 15, right: 15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Datos',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Future<void> applyDateFilter() async {
    if (startDate != '' && endDate != '') {
      if (compareDates(startDate, endDate)) {
        var aux = endDate;

        setState(() {
          endDate = startDate;

          startDate = aux;
        });
      }
    }
    arrayDateRanges.add({
      'body_param': 'start',
      'value': startDate != "" ? startDate : '1/1/1991'
    });

    arrayDateRanges.add(
        {'body_param': 'end', 'value': endDate != "" ? endDate : '1/1/2200'});

    await loadData();
  }

  bool compareDates(String string1, String string2) {
    List<String> parts1 = string1.split('/');
    List<String> parts2 = string2.split('/');

    int day1 = int.parse(parts1[0]);
    int month1 = int.parse(parts1[1]);
    int year1 = int.parse(parts1[2]);

    int day2 = int.parse(parts2[0]);
    int month2 = int.parse(parts2[1]);
    int year2 = int.parse(parts2[2]);

    if (year1 > year2) {
      return true;
    } else if (year1 < year2) {
      return false;
    } else {
      if (month1 > month2) {
        return true;
      } else if (month1 < month2) {
        return false;
      } else {
        if (day1 > day2) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Container _dates(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () async {
                var results = await showCalendarDatePicker2Dialog(
                  context: context,
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    selectedYearTextStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                    weekdayLabelTextStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                  ),
                  dialogSize: const Size(325, 400),
                  value: _datesDesde,
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

                    String nuevaFecha = "$dia/$mes/$anio";

                    sharedPrefs!.setString("dateDesdeLogistica", nuevaFecha);
                  }
                });
              },
              child: Text(
                "${sharedPrefs!.getString("dateDesdeLogistica")}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue, // Cambia el color según tus preferencias
                  fontFamily:
                      'Roboto', // Cambia la fuente según tus preferencias
                ),
              )),
          Text("-"),
          TextButton(
              onPressed: () async {
                var results = await showCalendarDatePicker2Dialog(
                  context: context,
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    selectedYearTextStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                    weekdayLabelTextStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                  ),
                  dialogSize: const Size(325, 400),
                  value: _datesHasta,
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

                    String nuevaFecha = "$dia/$mes/$anio";

                    sharedPrefs!.setString("dateHastaLogistica", nuevaFecha);
                  }
                });
              },
              child: Text(
                "${sharedPrefs!.getString("dateHastaLogistica")}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue, // Cambia el color según tus preferencias
                  fontFamily:
                      'Roboto', // Cambia la fuente según tus preferencias
                ),
              )),
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
              onPressed: () async {
                await loadData();
              },
              child: Text(
                "BUSCAR",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }

  // addCounts() {
  //   for (var filter in filters) {
  //     subData = [];
  //     for (var element in data) {
  //       if (element['Status'] == filter.filter) {
  //         subData.add(element);
  //       }
  //     }
  //     setState(() {
  //       filter.numOfFiles = subData.length;
  //     });
  //     subFilters.add({
  //       "title": filter.filter,
  //       "total": subData.length,
  //       "color": filter.color
  //     });
  //   }
  // }

  calculatetotal() {
    int total = 0;
    for (var section in sections) {
      total += int.parse(section['value'].toString());
    }
    return total;
  }

  changeValue(value) {
    if (value['value']) {
      for (var subFilter in subFilters) {
        if (value['filter'] == subFilter['title']) {
          var sec = {
            'color': subFilter['color'],
            'value': subFilter["total"],
            'showTitle': true,
            'title': subFilter["title"],
            'radius': 20,
          };

          if (!sections.contains(sec)) {
            var color = subFilter['color'] as Color;
            setState(() {
              sections.add({
                'color': color.withOpacity(0.7),
                'value': subFilter["total"],
                'showTitle': true,
                'title': subFilter["title"],
                'radius': 20,
              });
            });
          }
        }
      }
    } else {
      setState(() {
        sections.removeWhere((element) => element['title'] == value['filter']);
      });
    }
  }

  _sellersTransport(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        dropdownWidth: 200,
        buttonWidth: 100,
        isExpanded: true,
        hint: Text(
          'Transporte',
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.bold),
        ),
        items: transports
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.split('-')[0],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectValueTransport = null;
                              selectValueOperator = null;
                            });
                            arrayFiltersAnd.removeWhere((element) =>
                                element.containsKey("transportadora"));
                            await loadConfigs();
                            loadData();
                          },
                          child: Icon(Icons.close))
                    ],
                  ),
                ))
            .toList(),
        value: selectValueTransport,
        onChanged: (value) async {
          arrayFiltersAnd
              .removeWhere((element) => element.containsKey("transportadora"));
          arrayFiltersAnd
              .removeWhere((element) => element.containsKey("operadore"));
          setState(() {
            selectValueTransport = value as String;
            idTransport = value.split('-')[1];
            selectValueOperator = null;
            arrayFiltersAnd.add({
              "transportadora": {"id": idTransport}
            });
          });
          await loadConfigs();
          loadData();
        },

        //This to clear the search value when you close the menu
        onMenuStateChange: (isOpen) {
          if (!isOpen) {}
        },
      ),
    );
  }

  DropdownButtonHideUnderline _operators(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        dropdownWidth: 200,
        buttonWidth: 100,
        isExpanded: true,
        hint: Text(
          'Operadores',
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.bold),
        ),
        items: operators
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.split('-')[0],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectValueOperator = null;
                            });
                            arrayFiltersAnd.removeWhere(
                                (element) => element.containsKey("operadore"));
                            await loadData();
                          },
                          child: Icon(Icons.close))
                    ],
                  ),
                ))
            .toList(),
        value: selectValueOperator,
        onChanged: (value) async {
          setState(() {
            selectValueOperator = value as String;
          });
          arrayFiltersAnd
              .removeWhere((element) => element.containsKey("operadore"));
          arrayFiltersAnd.add({
            "operadore": {"id": selectValueOperator!.split("-")[1]}
          });
          loadData();
        },

        //This to clear the search value when you close the menu
        onMenuStateChange: (isOpen) {
          if (!isOpen) {}
        },
      ),
    );
  }

  DropdownButtonHideUnderline _sellers(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        dropdownWidth: 200,
        buttonWidth: 100,
        isExpanded: true,
        hint: Text(
          'Vendedores',
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.bold),
        ),
        items: sellers
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.split('-')[0],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectValueSeller = null;
                            });
                            arrayFiltersAnd.removeWhere((element) =>
                                element.containsKey("IdComercial"));

                            await loadData();
                          },
                          child: Icon(Icons.close))
                    ],
                  ),
                ))
            .toList(),
        value: selectValueSeller,
        onChanged: (value) async {
          setState(() {
            //   print("id comercial:" + value!.split("-")[1]);//
            arrayFiltersAnd
                .removeWhere((element) => element.containsKey("IdComercial"));
            arrayFiltersAnd.add({"IdComercial": value!.split("-")[1]});
            selectValueSeller = value as String;
          });
          loadData();
        },

        //This to clear the search value when you close the menu
        onMenuStateChange: (isOpen) {
          if (!isOpen) {}
        },
      ),
    );
  }

  void setRouteCounter(int id) {}

  showModal(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext modalContext) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: ExpansionTile(
                    title: Text("Entidades"),
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Container(width: 100, child: Text("Vendedores: ")),
                            _sellers(context)
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Container(
                                width: 100, child: Text("Transportistas: ")),
                            _sellersTransport(context)
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Container(width: 100, child: Text("Operadores: ")),
                            _operators(context)
                          ],
                        ),
                      ),
                      //  _sellers(context),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: ExpansionTile(
                    title: Text("Ciudades"),
                    children: routes
                        .map((route) => Container(
                              padding: EdgeInsets.only(left: 20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 200,
                                    child: Text(
                                      capitalize(route['attributes']['Titulo']
                                          .toString()),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Checkbox(
                                    value: route['check'],
                                    onChanged: (value) {
                                      setState(() {
                                        route['check'] = value;
                                      });
                                      addCounterRoute(route['id'],
                                          route['attributes']['Titulo'], value);
                                    },
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // sendFilter(String selectedFilter, bool currentValue) {
  //   for (var filter in filters) {
  //     if (filter.filter == selectedFilter) {
  //       setState(() {
  //         filter.check = currentValue;
  //       });
  //     }
  //   }
  // }
}

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 6, // Grosor de la línea
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.blue, // Color de la animación
        ),
        // Puedes agregar más propiedades de estilo aquí
      ),
    );
  }
}
