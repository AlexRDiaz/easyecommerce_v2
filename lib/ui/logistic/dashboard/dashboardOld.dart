import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/dashboard/filterStatus.dart';
import 'package:frontend/ui/sellers/dashboard/chart.dart';
import 'package:frontend/ui/sellers/dashboard/filter_details.dart';
import 'package:frontend/ui/sellers/dashboard/storage_info_card.dart';
import 'package:frontend/ui/widgets/loading.dart';

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
  List checks = [];
  TextEditingController _search = TextEditingController();
  List sections = [];
  List<String> sellers = [];
  List data = [];
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

  bool sort = false;
  String currentValue = "";
  int total = 0;
  int entregados = 0;
  int noEntregados = 0;
  int conNovedad = 0;
  int reagendados = 0;
  double totalValoresRecibidos = 0;
  double costoTransportadora = 0;
  double costoDevoluciones = 0;
  double utilidades = 0;

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
  void didChangeDependencies() {
    loadConfigs();
    super.didChangeDependencies();
  }

  loadConfigs() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
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

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  loadData() async {
    isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    setState(() {
      data = [];
      subFilters = [];
      sections = [];
      filters = [];
    });
    for (FilterCheckModel filter in filters) {
      setState(() {
        filter.check = false;
      });
    }

    var response =
        await Connections().getOrdersDashboard(populate, arrayFiltersAnd);
    setState(() {
      data = response;

      total = data.length;
    });
    filters = [
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

    updateChartValues();
    calculateValues();
    setState(() {});
  }

  updateChartValues() {
    subData =
        data.where((elemento) => elemento['Status'] == 'ENTREGADO').toList();
    var m = subData;
  }

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
              _sellers(context),
              _sellersTransport(context),
              _operators(context),
            ]),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Expanded(
                child: GridView.count(
                  crossAxisCount:
                      2, // Puedes cambiar a 3 si quieres tres columnas
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  shrinkWrap: true,
                  children: filters
                      .map((elemento) => FilterStatus(
                            svgSrc: elemento.svgSrc!,
                            title: elemento.title!,
                            filter: elemento.filter!,
                            color: elemento.color!,
                            details: addTableRows,
                            percentage: elemento.percentage!,
                            numOfFiles: elemento.numOfFiles!,
                            function: changeValue,
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        )
      ],
    )));
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
        child: DataTable2(
            decoration: BoxDecoration(
              color: Colors.white,
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
                      tableData[index]['Fecha_Entrega'] != null
                          ? tableData[index]['Fecha_Entrega']
                          : "",
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
                DataCell(
                    Text(
                      '${tableData[index]['Name_Comercial'].toString()}-${tableData[index]['NumeroOrden'].toString()}',
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
                DataCell(
                    Text(
                      tableData[index]['PrecioTotal'],
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
                DataCell(
                    Text(
                      tableData[index]['Status'].toString(),
                      style: TextStyle(
                        color: rowColor,
                      ),
                    ),
                    onTap: () {}),
                DataCell(
                    Text(
                      tableData[index]['Comentario'] != null
                          ? tableData[index]['Comentario']
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
    for (var filter in filters) {
      subData = [];
      for (var element in data) {
        if (element['Status'] == filter.filter) {
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

  addTableRows(value) {
    tableData = [];
    List arrTable = [];
    for (var element in data) {
      if (element['Status'] == value) {
        arrTable.add(element);
      }
    }

    setState(() {
      tableData = arrTable;
    });
  }

  calculateValues() {
    totalValoresRecibidos = 0;
    costoTransportadora = 0;
    costoDevoluciones = 0;
    utilidades = 0;
    double total = 0;
    double costoEntregas = 0;
    double devol = 0;

    for (var element in data) {
      if (element['Status'] == 'ENTREGADO') {
        print("precioTotal" + element['PrecioTotal']);
        element['PrecioTotal'] =
            element['PrecioTotal'].toString().replaceAll(',', '.');
        total += double.parse(element['PrecioTotal']);
      }

      if (element['Status'] == 'ENTREGADO' ||
          element['Status'] == 'NO ENTREGADO') {
        element['users'][0]['vendedores'][0]['CostoEnvio'] =
            element['users'][0]['vendedores'][0]['CostoEnvio'] ?? 0;

        element['users'][0]['vendedores'][0]['CostoEnvio'] = element['users'][0]
                ['vendedores'][0]['CostoEnvio']
            .toString()
            .replaceAll(',', '.');
        costoEntregas +=
            double.parse(element['users'][0]['vendedores'][0]['CostoEnvio']);
      }

      if (element['Status'] == 'NOVEDAD' &&
          element['Estado_Devolucion'] != 'PENDIENTE') {
        element['users'][0]['vendedores'][0]['CostoDevolucion'] =
            element['users'][0]['vendedores'][0]['CostoDevolucion'] ?? 0;
        element['users'][0]['vendedores'][0]['CostoDevolucion'] =
            element['users'][0]['vendedores'][0]['CostoDevolucion']
                .toString()
                .replaceAll(',', '.');
        devol += double.parse(
            element['users'][0]['vendedores'][0]['CostoDevolucion']);
      }
    }
    setState(() {
      totalValoresRecibidos = total;
      costoTransportadora = costoEntregas;
      costoDevoluciones = devol;
      utilidades =
          totalValoresRecibidos - costoTransportadora - costoDevoluciones;
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

  _sellersTransport(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        dropdownWidth: 500,
        buttonWidth: 500,
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
                              idTransport = "";
                              selectValueTransport = null;
                              selectValueOperator = null;
                            });
                            await loadData();
                          },
                          child: Icon(Icons.close))
                    ],
                  ),
                ))
            .toList(),
        value: selectValueTransport,
        onChanged: (value) async {
          setState(() {
            selectValueTransport = value as String;
            idTransport = value.split('-')[1];
            selectValueOperator = null;
          });
          await loadData();
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
        dropdownWidth: 500,
        buttonWidth: 500,
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
        dropdownWidth: 500,
        buttonWidth: 500,
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
            selectValueSeller = value as String;
          });
        },

        //This to clear the search value when you close the menu
        onMenuStateChange: (isOpen) {
          if (!isOpen) {}
        },
      ),
    );
  }
}
