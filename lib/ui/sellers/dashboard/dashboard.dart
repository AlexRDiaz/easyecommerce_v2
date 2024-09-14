import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/sellers/dashboard/chart.dart';
import 'package:frontend/ui/sellers/dashboard/filter_details.dart';
import 'package:frontend/ui/sellers/dashboard/storage_info_card.dart';
import 'package:frontend/ui/widgets/loading.dart';

class DashBoardSellers extends StatefulWidget {
  const DashBoardSellers({super.key});

  @override
  State<DashBoardSellers> createState() => _DashBoardSellersState();
}

class _DashBoardSellersState extends State<DashBoardSellers> {
  bool entregado = false;
  bool noEntregado = false;
  bool novedad = false;
  bool reagendado = false;
  bool enRuta = false;
  bool enOficina = false;
  bool programado = false;
  List checks = [];
  TextEditingController _search = TextEditingController();
  List sections = [];

  List data = [];
  List subData = [];
  List tableData = [];
  List subFilters = [];
  // String dateDesde = "";
  // String dateHasta = "";
  String startDate = "";
  String endDate = "";
  String selectedDateFilter = "FECHA ENTREGA";

  String idTransport = "";

  String? selectValueOperator = null;
  List<String> operators = [];
  List<Map<String, dynamic>> dataChart = [];
  List<DateTime?> _datesDesde = [];
  List<DateTime?> _datesHasta = [];
  List counters = [];

  bool sort = false;
  String currentValue = "";
  // int total = 0;
  // int entregados = 0;
  // int noEntregados = 0;
  // int conNovedad = 0;
  // int reagendados = 0;
  // double totalValoresRecibidos = 0;
  // double costoTransportadora = 0;
  // double costoDevoluciones = 0;
  // double utilidades = 0;

// ! usando
  List newdata = [];
  double totalValoresRecibidosLaravel = 0;
  double costoDeEntregasLaravel = 0;
  double devolucionesLaravel = 0;
  double utilidadLaravel = 0;

  int entregadosLaravel = 0;
  int noEntregadosLaravel = 0;
  int conNovedadLaravel = 0;
  int reagendadosLaravel = 0;
  int enRutaLaravel = 0;
  int enOficinaLaravel = 0;
  int pedidoProgramadoLaravel = 0;
// ! ************************
  bool isFirst = true;
  int counterLoad = 0;
  String transporterOperator = 'TODO';
  int currentPage = 1;
  int pageSize = 0;
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
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "Entregados",
        filter: "ENTREGADO",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 2, 51, 22),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "NO ENTREGADO",
        filter: "NO ENTREGADO",
        check: false),
    FilterCheckModel(
        color: const Color.fromARGB(255, 76, 54, 244),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "NOVEDAD",
        filter: "NOVEDAD",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 42, 163, 67),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "REAGENDADO",
        filter: "REAGENDADO",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 146, 76, 29),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "EN RUTA",
        filter: "EN RUTA",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 11, 6, 123),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "EN OFICINA",
        filter: "EN OFICINA",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 146, 18, 73),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "PEDIDO PROGRAMADO",
        filter: "PEDIDO PROGRAMADO",
        check: false),
  ];

  List arrayFiltersAnd = [
    {
      'IdComercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    }
  ];
  // !nuevo uso
  List<FilterCheckModel> filters2 = [
    FilterCheckModel(
        color: Colors.red,
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "Entregados",
        filter: "ENTREGADO",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 2, 51, 22),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "NO ENTREGADO",
        filter: "NO ENTREGADO",
        check: false),
    FilterCheckModel(
        color: const Color.fromARGB(255, 76, 54, 244),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "NOVEDAD",
        filter: "NOVEDAD",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 42, 163, 67),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "REAGENDADO",
        filter: "REAGENDADO",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 146, 76, 29),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "EN RUTA",
        filter: "EN RUTA",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 11, 6, 123),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "EN OFICINA",
        filter: "EN OFICINA",
        check: false),
    FilterCheckModel(
        color: Color.fromARGB(255, 146, 18, 73),
        numOfFiles: 0,
        percentage: 14,
        svgSrc: "assets/icons/Documents.svg",
        title: "PEDIDO PROGRAMADO",
        filter: "PEDIDO PROGRAMADO",
        check: false),
  ];

  Map dataCounters = {};
  Map valuesTransporter = {};
  var arrayFiltersDefaultAnd = [
    {
      'id_comercial':
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    }
  ];
  List<String> listDateFilter = [
    'FECHA ENVIO',
    'FECHA ENTREGA',
  ];

  // List populate = [
  //   "pedido_fecha",
  //   "transportadora",
  //   "ruta",
  //   "sub_ruta",
  //   "operadore",
  //   "operadore.user",
  //   "users",
  //   "users.vendedores",
  //   "novedades"
  // ];
  List populate = [
    'operadore.up_users',
    'transportadora',
    'users.vendedores',
    'novedades',
    'pedidoFecha',
    'ruta',
    'subRuta'
  ];

// ! ********************************
  @override
  void didChangeDependencies() {
    // loadConfigs();
    super.didChangeDependencies();
  }

  loadData() async {
    isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    setState(() {
      subFilters = [];
      sections = [];
      filters = [];
    });

    for (FilterCheckModel filter in filters) {
      setState(() {
        filter.check = false;
      });
    }

    // counters
    var responseCounters = await Connections().getOrdersCountersSeller(
        populate, arrayFiltersDefaultAnd, [], [], selectedDateFilter);

    pageSize = responseCounters['TOTAL'];

    // data table
    var responseLaravel = await Connections()
        .getOrdersForSellerStateSearchForDateSellerLaravel(
            populate,
            selectedDateFilter,
            "",
            [],
            arrayFiltersDefaultAnd,
            [],
            currentPage,
            pageSize,
            "",
            [],
            "marca_tiempo_envio:DESC");

    // caltulated values
    var responseValues = await Connections()
        .getValuesSellerLaravel(arrayFiltersDefaultAnd, selectedDateFilter, sharedPrefs!.getString("idComercialMasterSeller").toString());

    // var response =s
    //     await Connections().getOrdersDashboard(populate, arrayFiltersAnd);
    setState(() {
      // data = response;
      newdata = responseLaravel['data'];
      valuesTransporter = responseValues['data'];
      // total = data.length;
      dataCounters = responseCounters;
    });

    // totallast = dataCounters[''];

    setState(() {
      entregadosLaravel = int.parse(dataCounters['ENTREGADO'].toString()) ?? 0;
      noEntregadosLaravel =
          int.parse(dataCounters['NO ENTREGADO'].toString()) ?? 0;
      conNovedadLaravel = int.parse(dataCounters['NOVEDAD'].toString()) ?? 0;
      reagendadosLaravel =
          int.parse(dataCounters['REAGENDADO'].toString()) ?? 0;
      enRutaLaravel = int.parse(dataCounters['EN RUTA'].toString()) ?? 0;
      enOficinaLaravel = int.parse(dataCounters['EN OFICINA'].toString()) ?? 0;
      pedidoProgramadoLaravel =
          int.parse(dataCounters['PEDIDO PROGRAMADO'].toString()) ?? 0;
    });

    // print(dataCounters);

    filters2 = [
      FilterCheckModel(
          color: Colors.red,
          numOfFiles: 0,
          percentage: 14,
          svgSrc: "assets/icons/Documents.svg",
          title: "Entregados",
          filter: "ENTREGADO",
          check: false),
      FilterCheckModel(
          color: Color.fromARGB(255, 2, 51, 22),
          numOfFiles: 0,
          percentage: 14,
          svgSrc: "assets/icons/Documents.svg",
          title: "NO ENTREGADO",
          filter: "NO ENTREGADO",
          check: false),
      FilterCheckModel(
          color: const Color.fromARGB(255, 76, 54, 244),
          numOfFiles: 0,
          percentage: 14,
          svgSrc: "assets/icons/Documents.svg",
          title: "NOVEDAD",
          filter: "NOVEDAD",
          check: false),
      FilterCheckModel(
          color: Color.fromARGB(255, 42, 163, 67),
          numOfFiles: 0,
          percentage: 14,
          svgSrc: "assets/icons/Documents.svg",
          title: "REAGENDADO",
          filter: "REAGENDADO",
          check: false),
      FilterCheckModel(
          color: Color.fromARGB(255, 146, 76, 29),
          numOfFiles: 0,
          percentage: 14,
          svgSrc: "assets/icons/Documents.svg",
          title: "EN RUTA",
          filter: "EN RUTA",
          check: false),
      FilterCheckModel(
          color: Color.fromARGB(255, 11, 6, 123),
          numOfFiles: 0,
          percentage: 14,
          svgSrc: "assets/icons/Documents.svg",
          title: "EN OFICINA",
          filter: "EN OFICINA",
          check: false),
      FilterCheckModel(
          color: Color.fromARGB(255, 146, 18, 73),
          numOfFiles: 0,
          percentage: 14,
          svgSrc: "assets/icons/Documents.svg",
          title: "PEDIDO PROGRAMADO",
          filter: "PEDIDO PROGRAMADO",
          check: false),
    ];

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });

    addCounts();

    // updateChartValues();
    // calculateValues();

    // ! nuevo usando

    setState(() {
      totalValoresRecibidosLaravel =
          double.parse(valuesTransporter['totalValoresRecibidos'].toString());
      costoDeEntregasLaravel =
          double.parse(valuesTransporter['totalShippingCost'].toString());
      devolucionesLaravel =
          double.parse(valuesTransporter['totalCostoDevolucion'].toString());
      utilidadLaravel = (valuesTransporter['totalValoresRecibidos']) -
          (valuesTransporter['totalShippingCost'] +
              valuesTransporter['totalCostoDevolucion']);
      utilidadLaravel = double.parse(utilidadLaravel.toString());
    });
  }

  // updateChartValues() {
  //   subData =
  //       newdata.where((elemento) => elemento['status'] == 'ENTREGADO').toList();
  //   var m = subData;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 20, right: 15, top: 20, bottom: 20),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Configuraciones',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Column(children: [
              _dates(context),
              // _sellersTransport(context),
              // _operators(context),
            ]),
          ),
        ),
        responsive(
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.73,
                    padding: EdgeInsets.only(left: 20),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Estados de entrega',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: filters2
                                    .map((elemento) => FilterInfoCard(
                                          svgSrc: elemento.svgSrc!,
                                          title: elemento.title!,
                                          filter: elemento.filter!,
                                          color: elemento.color!,
                                          details: addTableRows2,
                                          percentage: elemento.percentage!,
                                          numOfFiles: elemento.numOfFiles!,
                                          function: changeValue,
                                        ))
                                    .toList(),
                              ),
                            ),
                            Chart(
                              sections: sections,
                              total: calculatetotal(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Column(
                  children: [
                    FilterDetails(
                        total: totalValoresRecibidosLaravel,
                        costoEntregas: costoDeEntregasLaravel,
                        costoDevoluciones: devolucionesLaravel,
                        utilidades: utilidadLaravel),
                    dataTableDetails()
                  ],
                )),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 14, bottom: 20),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Estados de entrega',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: filters2
                                    .map((elemento) => FilterInfoCard(
                                          svgSrc: elemento.svgSrc!,
                                          title: elemento.title!,
                                          filter: elemento.filter!,
                                          color: elemento.color!,
                                          details: addTableRows2,
                                          percentage: elemento.percentage!,
                                          numOfFiles: elemento.numOfFiles!,
                                          function: changeValue,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.53,
                          padding:
                              EdgeInsets.only(left: 18, right: 13, bottom: 20),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Porcentajes por estado',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: StreamBuilder<Object>(
                                stream: null,
                                builder: (context, snapshot) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Chart(
                                        sections: sections,
                                        total: calculatetotal(),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                  FilterDetails(
                      total: totalValoresRecibidosLaravel,
                      costoEntregas: costoDeEntregasLaravel,
                      costoDevoluciones: devolucionesLaravel,
                      utilidades: utilidadLaravel),
                  dataTableDetails()
                ],
              ),
            ),
            context)
      ],
    )));
  }

  Container dataTableDetails() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.51,
      width: MediaQuery.of(context).size.width * 0.50,
      padding: EdgeInsets.only(left: 15, right: 15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Datos',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: DataTable2(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 223, 218, 218),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.blueGrey),
            ),
            headingRowHeight: 63,
            headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
            dataTextStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 200,
            columns: [
              DataColumn2(
                label: Text('Fecha Entrega'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Código'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Precio'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Status'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Comentario'),
                size: ColumnSize.S,
              ),
            ],
            rows: List<DataRow>.generate(tableData.length, (index) {
              Color rowColor = Colors.black;

              return DataRow(cells: [
                DataCell(
                    Text(
                      tableData[index]['fecha_entrega'] != null
                          ? tableData[index]['fecha_entrega']
                          : "",
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
                DataCell(
                    Text(
                      '${tableData[index]['name_comercial'].toString()}-${tableData[index]['numero_orden'].toString()}',
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
                DataCell(
                    Text(
                      tableData[index]['precio_total'],
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
                DataCell(
                    Text(
                      tableData[index]['status'].toString(),
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
                DataCell(
                    Text(
                      tableData[index]['comentario'] != null
                          ? tableData[index]['comentario']
                          : "",
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
              ]);
            })),
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

  SizedBox _dates(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            //  height: 50,
            width: 230,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedDateFilter,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDateFilter = newValue ?? "";
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items:
                  listDateFilter.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
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

                    sharedPrefs!.setString("dateDesdeVendedor", nuevaFecha);
                  }
                });
              },
              child: Text(
                "${sharedPrefs!.getString("dateDesdeVendedor")}",
                style: TextStyle(fontWeight: FontWeight.bold),
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

                    sharedPrefs!.setString("dateHastaVendedor", nuevaFecha);
                  }
                });
              },
              child: Text(
                "${sharedPrefs!.getString("dateHastaVendedor")}",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
              onPressed: () async {
                setState(() {
                  _search.clear();
                  tableData = [];
                });
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

  addCounts() {
    for (var filter in filters2) {
      subData = [];
      for (var element in newdata) {
        if (element['status'] == filter.filter) {
          subData.add(element);
        }
      }
      setState(() {
        filter.numOfFiles = subData.length;
      });
      subFilters.add({
        "title": filter.filter,
        "total": subData.length,
        "color": filter.color
      });
    }
  }

  // addTableRows(value) {
  //   tableData = [];
  //   List arrTable = [];
  //   for (var element in data) {
  //     if (element['Status'] == value) {
  //       arrTable.add(element);
  //     }
  //   }

  //   setState(() {
  //     tableData = arrTable;
  //   });
  // }

  addTableRows2(value) {
    tableData = [];
    List arrTable = [];
    for (var element in newdata) {
      if (element['status'] == value) {
        arrTable.add(element);
      }
    }

    setState(() {
      tableData = arrTable;
    });
  }

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
}
