import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/operator/state_orders/generate_report_status_orders.dart';
import 'package:frontend/ui/operator/state_orders/info_state_orders.dart';
import 'package:frontend/ui/transport/delivery_status_transport/Opcion.dart';
import 'package:frontend/ui/widgets/OptionsWidget.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/box_values_transport.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:intl/intl.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';

class StateOrdersOperator extends StatefulWidget {
  const StateOrdersOperator({super.key});

  @override
  State<StateOrdersOperator> createState() => _StateOrdersOperatorState();
}

class _StateOrdersOperatorState extends State<StateOrdersOperator> {
  //  * laravel version
  TextEditingController searchController = TextEditingController(text: "");
  TextEditingController startDateController = TextEditingController(text: "");
  TextEditingController endDateController = TextEditingController(text: "");
  NumberPaginatorController paginatorController = NumberPaginatorController();

  final MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();

  List dataL = [];
  int currentPage = 1;
  int pageSize = 75;
  int pageCount = 100;
  bool isFirst = true;
  bool isLoading = false;

  int total = 0;
  int entregados = 0;
  int noEntregados = 0;
  int conNovedad = 0;
  int reagendados = 0;
  int enRuta = 0;
  int programado = 0;
  int novedadResuelta = 0;
  int enDevolucion = 0;

  double totalValoresRecibidos = 0;
  double costoTransportadora = 0;

  String selectedDateFilter = "FECHA ENTREGA";
  List<String> listDateFilter = [
    'FECHA ENVIO',
    'FECHA ENTREGA',
  ];
  List populate = [
    'operadore.up_users',
    'transportadora',
    'users.vendedores',
    'novedades',
    'pedidoFecha',
    'ruta',
    'subRuta'
  ];
  //        $pedidos = PedidosShopify::with(['operadore.up_users', 'transportadora', 'users.vendedores', 'novedades', 'pedidoFecha', 'ruta', 'subRuta'])

  List arrayFiltersAnd = [];
  List arrayFiltersNotEq = [];
  List arrayFiltersDefaultAnd = [
    // {'operadore.up_users': sharedPrefs!.getString("id").toString()},
    {
      'operadore.up_users.operadore_id':
          sharedPrefs!.getString("idOperadore").toString()
    },
    {'estado_logistico': "ENVIADO"},
    {'estado_interno': "CONFIRMADO"}
  ];

  List arrayFiltersDefaultAndOp = [
    // {'operadore.up_users': sharedPrefs!.getString("id").toString()},
    {
      'operadore.operadore_id': sharedPrefs!.getString("idOperadore").toString()
    },
    {'estado_logistico': "ENVIADO"},
    {'estado_interno': "CONFIRMADO"}
  ];

  List arrayFiltersOr = [
    'fecha_entrega',
    'numero_orden',
    'nombre_shipping',
    'ciudad_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    'producto_extra',
    'precio_total',
    'observacion',
    'comentario',
    'status',
    'tipo_Pago',
    'marca_t_d',
    'marca_t_d_l',
    'marca_t_d_t',
    'marca_t_i',
    'estado_pagado',
  ];

  var sortFieldDefaultValue = "marca_tiempo_envio:DESC";

  Color currentColor = const Color.fromARGB(255, 108, 108, 109);
  String currentValue = "";
  Map dataCounters = {};
  Map valuesTransporter = {};
  var getReport = CreateReportStatusOrdersOperator();
  String dateStart = "";
  String dateEnd = "";
  bool changevalue = false;

  @override
  void didChangeDependencies() {
    initializeDates();
    loadData();
    super.didChangeDependencies();
  }

  initializeDates() {
    startDateController.text =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    endDateController.text =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = [];
      var responseL = await Connections()
          .getOrdersForSellerStateSearchForDateTransporterLaravel(
              selectedDateFilter,
              startDateController.text,
              endDateController.text,
              populate,
              arrayFiltersAnd,
              arrayFiltersDefaultAnd,
              arrayFiltersOr,
              arrayFiltersNotEq,
              currentPage,
              pageSize,
              searchController.text,
              sortFieldDefaultValue.toString());

      // var responseValues = await Connections().getValuesTrasporter(
      //     "operator",
      //     selectedDateFilter,
      //     startDateController.text,
      //     endDateController.text,
      //     populate,
      //     arrayFiltersAnd,
      //     arrayFiltersDefaultAndOp,
      //     arrayFiltersOr);

      var responseCounters = await Connections().getOrdersCountersTransport(
        selectedDateFilter,
        startDateController.text,
        endDateController.text,
        populate,
        arrayFiltersAnd,
        arrayFiltersDefaultAnd,
        arrayFiltersOr,
      );

      // valuesTransporter = responseValues;

      setState(() {
        dataL = [];
        dataL = responseL['data'];
        total = responseL['total'];
        pageCount = responseL['last_page'];

        if (sortFieldDefaultValue.toString() == "marca_tiempo_envio:DESC" &&
            arrayFiltersAnd.length <= 1) {
          total = responseL['total'];
          dataCounters = responseCounters;
          // calculateValues();
        }

        // dataCounters = responseCounters;
        paginatorController.navigateToPage(0);

        // _scrollController.jumpTo(0);
      });
      updateCounters();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("error!!!:  $e");
      _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
    }

    // Future.delayed(Duration(milliseconds: 500), () {
    //   Navigator.pop(context);
    // });
    // setState(() {});
  }

  paginateData() async {
    // paginatorController.navigateToPage(0);
    try {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   getLoadingModal(context, false);
      // });

      var responseL = await Connections()
          .getOrdersForSellerStateSearchForDateTransporterLaravel(
              selectedDateFilter,
              startDateController.text,
              endDateController.text,
              populate,
              arrayFiltersAnd,
              arrayFiltersDefaultAnd,
              arrayFiltersOr,
              arrayFiltersNotEq,
              currentPage,
              pageSize,
              searchController.text,
              sortFieldDefaultValue.toString());

      setState(() {
        dataL = [];
        dataL = responseL['data'];

        pageCount = responseL['last_page'];
      });

      // Future.delayed(const Duration(milliseconds: 500), () {
      //   Navigator.pop(context);
      // });
      // setState(() {
      //   isFirst = false;

      //   // isLoading = false;
      // });
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

  calculateValues() {
    setState(() {
      totalValoresRecibidos =
          double.parse(valuesTransporter['totalValoresRecibidos'].toString());
      costoTransportadora =
          double.parse(valuesTransporter['totalShippingCost'].toString());
    });
  }

  String getStateFromJson(String? jsonString, String claveAbuscar) {
    // Verificar si jsonString es null
    if (jsonString == null || jsonString.isEmpty) {
      return ''; // Retorna una cadena vacía si el valor es null o está vacío
    }

    try {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap[claveAbuscar]?.toString() ?? '';
    } catch (e) {
      print('Error al decodificar JSON: $e');
      return ''; // Manejar el error retornando una cadena vacía o un valor predeterminado
    }
  }

  Color? GetColorofStateNovelti(stateNovelti) {
    int color = 0xFF000000;

    switch (stateNovelti) {
      case "ok":
        color = 0xFF66BB6A;
        break;
      case "gestioned":
        color = 0xFFD6DC27;
        break;
      case "resolved":
        color = 0xFFFF5722;
        break;
      default:
        color = 0xFF000000;
    }
    return Color(color);
  }

  updateCounters() {
    entregados = 0;
    noEntregados = 0;
    conNovedad = 0;
    reagendados = 0;
    enRuta = 0;
    programado = 0;
    novedadResuelta = 0;
    enDevolucion = 0;

    setState(() {
      entregados = int.parse(dataCounters['ENTREGADO'].toString()) ?? 0;
      noEntregados = int.parse(dataCounters['NO ENTREGADO'].toString()) ?? 0;
      conNovedad = int.parse(dataCounters['NOVEDAD'].toString()) ?? 0;
      novedadResuelta =
          int.parse(dataCounters['NOVEDAD RESUELTA'].toString()) ?? 0;
      reagendados = int.parse(dataCounters['REAGENDADO'].toString()) ?? 0;
      enRuta = int.parse(dataCounters['EN RUTA'].toString()) ?? 0;
      // programado = int.parse(data['EN OFICINA'].toString()) ?? 0;
      programado = int.parse(dataCounters['PEDIDO PROGRAMADO'].toString()) ?? 0;
      enDevolucion = int.parse(dataCounters['DEVOLUCION'].toString()) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    List<Opcion> options = [
      Opcion(
          icono: const Icon(Icons.all_inbox),
          titulo: 'Total',
          filtro: 'Total',
          valor: total,
          color: const Color.fromARGB(255, 108, 108, 109)),
      Opcion(
          icono: const Icon(Icons.send),
          titulo: 'Entregado',
          filtro: 'Entregado',
          valor: entregados,
          color: const Color.fromARGB(255, 102, 187, 106)),
      Opcion(
          icono: const Icon(Icons.error),
          titulo: 'No Entregado',
          filtro: 'No Entregado',
          valor: noEntregados,
          color: const Color.fromARGB(255, 243, 33, 33)),
      Opcion(
          icono: const Icon(Icons.route),
          titulo: 'En Ruta',
          filtro: 'En Ruta',
          valor: enRuta,
          color: const Color.fromARGB(255, 33, 150, 243)),
      Opcion(
          icono: const Icon(Icons.schedule),
          titulo: 'Reagendado',
          filtro: 'Reagendado',
          valor: reagendados,
          color: const Color.fromARGB(255, 227, 32, 241)),
      Opcion(
          icono: const Icon(Icons.lock_clock),
          titulo: 'Programado',
          filtro: 'Pedido Programado',
          valor: programado,
          color: const Color.fromARGB(255, 239, 127, 14)),
      Opcion(
          icono: const Icon(Icons.campaign),
          titulo: 'Novedad',
          filtro: 'Novedad',
          valor: conNovedad,
          color: const Color.fromARGB(255, 244, 225, 57)),
      Opcion(
          icono: const Icon(Icons.done_all),
          titulo: 'Novedad Resuelta',
          filtro: 'Novedad Resuelta',
          valor: novedadResuelta,
          color: Color.fromARGB(255, 85, 57, 244)),
      Opcion(
          icono: Icon(Icons.assignment_return),
          titulo: 'Devoluciones',
          filtro: 'DEVOLUCION',
          valor: enDevolucion,
          color: const Color.fromARGB(255, 186, 85, 211)),
    ];

    return CustomProgressModal(
        isLoading: isLoading,
        content: Scaffold(
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Column(
              children: [
                /*
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: responsive(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          boxValuesTransport(
                            totalValoresRecibidos: totalValoresRecibidos,
                            costoDeEntregas: costoTransportadora,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          boxValuesTransport(
                            totalValoresRecibidos: totalValoresRecibidos,
                            costoDeEntregas: costoTransportadora,
                          ),
                        ],
                      ),
                      context),
                ),
                */
                const SizedBox(height: 10),
                fechaFinFechaIni(),
                const SizedBox(height: 10),
                responsive(
                    Container(
                        height: MediaQuery.of(context).size.height * 0.10,
                        child: OptionsWidget(
                            function: addFilter,
                            options: options,
                            currentValue: currentValue)),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.12,
                        child: OptionsWidget(
                            function: addFilter,
                            options: options,
                            currentValue: currentValue)),
                    context),
                responsive(
                    webMainContainer(width, heigth, context),
                    mobileMainContainer(width, heigth, context),
                    // const Text("Movil version"),
                    context),
              ],
            ),
          ),
        ));
    /*
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              child: responsive(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      boxValuesTransport(
                        totalValoresRecibidos: totalValoresRecibidos,
                        costoDeEntregas: costoTransportadora,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      boxValuesTransport(
                        totalValoresRecibidos: totalValoresRecibidos,
                        costoDeEntregas: costoTransportadora,
                      ),
                    ],
                  ),
                  context),
            ),
            fechaFinFechaIni(),
            /*
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 15, right: 5),
                        child: responsive(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: fechaFinFechaIni(),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: fechaFinFechaIni(),
                            ),
                            context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            */
            responsive(
                Container(
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: OptionsWidget(
                        function: addFilter,
                        options: options,
                        currentValue: currentValue)),
                Container(
                    height: MediaQuery.of(context).size.height * 0.16,
                    child: OptionsWidget(
                        function: addFilter,
                        options: options,
                        currentValue: currentValue)),
                context),
            responsive(
                webMainContainer(width, heigth, context),
                mobileMainContainer(width, heigth, context),
                // const Text("Movil version"),
                context),
            
          ],
        ),
      ),
    );
  */
  }

  addFilter(value) {
    resetFilters();

    arrayFiltersAnd.removeWhere((element) => element.containsKey("status"));
    if (value["filtro"] != "Total" &&
        value["filtro"] != "Novedad" &&
        value["filtro"] != "DEVOLUCION") {
      arrayFiltersAnd.add({"status": value["filtro"]});
    } else if (value["filtro"] == "Novedad") {
      arrayFiltersAnd.removeWhere((element) => element.containsKey("status"));
      arrayFiltersAnd
          .removeWhere((element) => element.containsKey("estado_devolucion"));
      arrayFiltersNotEq
          .removeWhere((element) => element.containsKey("estado_devolucion"));
      arrayFiltersAnd.add({"status": "NOVEDAD"});
      arrayFiltersAnd.add({"estado_devolucion": "PENDIENTE"});
    } else if (value["filtro"] == "DEVOLUCION") {
      arrayFiltersAnd.removeWhere((element) => element.containsKey("status"));
      arrayFiltersAnd
          .removeWhere((element) => element.containsKey("estado_devolucion"));
      arrayFiltersAnd.add({"status": "NOVEDAD"});
      arrayFiltersNotEq.add({"estado_devolucion": "PENDIENTE"});
    }

    setState(() {
      currentColor = value['color'];
    });

    paginatorController.navigateToPage(0);
  }

  getOldValue(Arrayrestoration) {
    List respaldo = [
      {
        'operadore.up_users.operadore_id':
            sharedPrefs!.getString("idOperadore").toString()
      },
      {'estado_logistico': "ENVIADO"},
      {'estado_interno': "CONFIRMADO"}
    ];
    if (Arrayrestoration) {
      setState(() {
        arrayFiltersAnd.clear();
        arrayFiltersAnd = respaldo;
        sortFieldDefaultValue = "marca_tiempo_envio:DESC";
      });
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

        // sharedPrefs!.setString("dateDesdeTransporte", nuevaFecha);
      }
    });

    return nuevaFecha;
  }

  Row fechaFinFechaIni() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        responsive(
            Row(
              children: [
                Text(startDateController.text),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    startDateController.text = await OpenCalendar();
                    // sharedPrefs!.setString("dateDesdeTransportadora",
                    //     _controllers.startDateController.text);
                  },
                ),
                const Text(' - '),
                Text(endDateController.text),
                IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: () async {
                    endDateController.text = await OpenCalendar();
                    // sharedPrefs!.setString("dateHastaTransportadora",
                    //     _controllers.endDateController.text);
                  },
                ),
                Row(
                  children: [
                    Container(
                      //  height: 50,
                      width: 150,
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
                        items: listDateFilter
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 15)),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color(0xFF031749),
                          ),
                        ),
                        onPressed: () async {
                          // await applyDateFilter();
                          // getOldValue(true);
                          loadData();
                        },
                        child: const Text('Filtrar'),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.red,
                        ),
                      ),
                      onPressed: () async {
                        // await applyDateFilter();
                        setState(() {
                          resetFilters();
                          loadData();
                          currentColor =
                              const Color.fromARGB(255, 108, 108, 109);
                        });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_alt),
                          SizedBox(width: 8),
                          Text('Quitar Filtros'),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.green,
                        ),
                      ),
                      onPressed: () async {
                        if (total > 1999) {
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title:
                                'El Número Total de Registros debe ser menor a 2.000',
                            desc: '',
                            btnOkText: "Aceptar",
                            btnOkColor: Colors.green,
                            btnOkOnPress: () async {},
                          ).show();
                        } else {
                          getLoadingModal(context, true);
                          try {
                            var response = await Connections()
                                .getOrdersForSellerStateSearchForDateTransporterLaravel(
                                    startDateController.text,
                                    endDateController.text,
                                    selectedDateFilter,
                                    populate,
                                    arrayFiltersAnd,
                                    arrayFiltersDefaultAnd,
                                    arrayFiltersOr,
                                    [],
                                    currentPage,
                                    1999,
                                    searchController.text,
                                    // sortField.toString());
                                    sortFieldDefaultValue.toString());

                            await getReport
                                .generateExcelFileWithData(response['data']);

                            Navigator.of(context).pop();
                          } catch (e) {
                            Navigator.of(context).pop();
                            _showErrorSnackBar(context,
                                "Ha ocurrido un error al generar el reporte: $e");

                            // SnackBarHelper.showErrorSnackBar(
                            //     context, "Ha ocurrido un error de conexión");
                          }
                        }
                      },
                      child: const Row(
                        // Usar un Row para combinar el icono y el texto
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons
                              .insert_drive_file), // Agregar el icono de filtro aquí
                          SizedBox(
                              width: 8), // Espacio entre el icono y el texto
                          Text('Reportes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(startDateController.text),
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async {
                        startDateController.text = await OpenCalendar();
                        // sharedPrefs!.setString("dateDesdeTransportadora",
                        //     _controllers.startDateController.text);
                      },
                    ),
                    const Text(' - '),
                    Text(endDateController.text),
                    IconButton(
                      icon: Icon(Icons.calendar_month),
                      onPressed: () async {
                        endDateController.text = await OpenCalendar();
                        // sharedPrefs!.setString("dateHastaTransportadora",
                        //     _controllers.endDateController.text);
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      //  height: 50,
                      width: 150,
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
                        items: listDateFilter
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 15)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color(0xFF031749),
                          ),
                        ),
                        onPressed: () async {
                          // await applyDateFilter();
                          // getOldValue(true);
                          loadData();
                        },
                        child: const Text('Filtrar'),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.red,
                        ),
                      ),
                      onPressed: () async {
                        // await applyDateFilter();
                        setState(() {
                          resetFilters();
                          loadData();
                          // currentColor = const Color.fromARGB(255, 108, 108, 109);
                        });
                      },
                      child: const Row(
                        // Usar un Row para combinar el icono y el texto
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons
                              .filter_alt), // Agregar el icono de filtro aquí
                          SizedBox(
                              width: 8), // Espacio entre el icono y el texto
                          Text('Quitar Filtros'),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.green,
                        ),
                      ),
                      onPressed: () async {
                        if (total > 1999) {
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title:
                                'El Número Total de Registros debe ser menor a 2.000',
                            desc: '',
                            btnOkText: "Aceptar",
                            btnOkColor: Colors.green,
                            btnOkOnPress: () async {},
                          ).show();
                        } else {
                          getLoadingModal(context, true);
                          try {
                            var response = await Connections()
                                .getOrdersForSellerStateSearchForDateTransporterLaravel(
                                    selectedDateFilter,
                                    startDateController.text,
                                    endDateController.text,
                                    populate,
                                    arrayFiltersAnd,
                                    arrayFiltersDefaultAnd,
                                    arrayFiltersOr,
                                    [],
                                    currentPage,
                                    1999,
                                    searchController.text,
                                    // sortField.toString());
                                    sortFieldDefaultValue.toString());

                            await getReport
                                .generateExcelFileWithData(response['data']);

                            Navigator.of(context).pop();
                          } catch (e) {
                            Navigator.of(context).pop();
                            _showErrorSnackBar(context,
                                "Ha ocurrido un error al generar el reporte: $e");

                            // SnackBarHelper.showErrorSnackBar(
                            //     context, "Ha ocurrido un error de conexión");
                          }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_drive_file),
                          SizedBox(width: 8),
                          Text('Reportes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            context),
      ],
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
      color: currentColor.withOpacity(0.3),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   color: Colors.white,
      // ),
      child: responsive(
          Row(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width * 0.4,
                child: _modelTextField(
                    text: "Buscar", controller: searchController),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child:
                      Container(width: width * 0.3, child: numberPaginator()),
                ),
              ),
              // Container(width: width * 0.3, child: numberPaginator()),
            ],
          ),
          Column(
            children: [
              _modelTextField(text: "Buscar", controller: searchController),
              numberPaginator(),
            ],
          ),
          context),
    );
  }

  Row webMainContainer(double width, double heigth, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _searchBar(width, heigth, context),
              const SizedBox(height: 10),
              _dataTableOrders(heigth),
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
          _searchBar(width, heigth, context),
          const SizedBox(height: 10),
          _dataTableOrdersMobile(heigth),
        ],
      ),
    );
  }

  _dataTableOrdersMobile(height) {
    return dataL.length > 0
        ? Container(
            height: height * 0.55,
            child: DataTableModelPrincipal(
                columnWidth: 400,
                columns: getColumns(),
                rows: buildDataRows(dataL)),
          )
        : const Center(
            child: Text("Sin datos"),
          );
  }

  Container _dataTableOrders(height) {
    return Container(
      height: height * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: dataL.length > 0
          ? DataTableModelPrincipal(
              columnWidth: 200,
              columns: getColumns(),
              rows: buildDataRows(dataL))
          : const Center(
              child: Text("Sin datos"),
            ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(
        label: Text("Fecha Envio"),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("marca_tiempo_envio", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Fecha Entrega'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("fecha_entrega", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Código'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text(''),
        size: ColumnSize.S,
      ),
      // DataColumn2(
      //   label: Text('Oper'),
      //   size: ColumnSize.M,
      // ),
      DataColumn2(
        label: Text("Com. Novedades"),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          // sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Nombre Cliente'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("nombre_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Ciudad'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Dirección'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Teléfono Cliente'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Cantidad'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("cantidad_total", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Producto'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          sortFunc3("producto_p", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Producto Extra'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Precio Total'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc3("precio_total", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Observación'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Comentario'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Status'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("marca_tiempo_envio", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Tipo Pago'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Est. Dev.'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc3("marca_tiempo_envio", changevalue);
        },
      ),
      DataColumn2(
        label: Text('MTD. OF.'),
        size: ColumnSize.M,
      ),
      // DataColumn2(
      //   label: Text('MTD. INP'),
      //   size: ColumnSize.M,
      // ),
      // const DataColumn2(
      //   label: Text('Est. Pago'),
      //   size: ColumnSize.S,
      // ),
      const DataColumn2(
        label: Text('N. intentos'),
        size: ColumnSize.S,
      ),
    ];
  }

  List<DataRow> buildDataRows(List dataL) {
    dataL = dataL;

    List<DataRow> rows = [];
    for (int index = 0; index < dataL.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            InkWell(
              child: Text(
                dataL[index]['marca_tiempo_envio'].toString(),
              ),
              onTap: () {
                info(context, index);
              },
            ),
          ),
          DataCell(
            Text(dataL[index]['fecha_entrega'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(
                '${dataL[index]['users'] != null && dataL[index]['users'].isNotEmpty ? dataL[index]['users'][0]['vendedores'][0]['nombre_comercial'] : "NaN"}-${dataL[index]['numero_orden'].toString()}',
                style: TextStyle(
                    color: GetColor(dataL[index]['status'].toString()))),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    // y  ${data[index]['attributes']['ProductoExtra'].toString()}
                    var _url = Uri.parse(
                        """https://api.whatsapp.com/send?phone=${dataL[index]['telefono_shipping'].toString()}&text=Buen Día, servicio de mensajeria le saluda, para informarle que tenemos una entrega para su persona de ${dataL[index]['producto_p'].toString()}${dataL[index]['producto_extra'] != null && dataL[index]['producto_extra'].toString() != 'null' && dataL[index]['producto_extra'].toString() != '' ? ' y ${dataL[index]['producto_extra'].toString()}' : ''}. Por el valor de ${dataL[index]['precio_total'].toString()}...... Realizado en la tienta ${dataL[index]['tienda_temporal'].toString()}. Me confirma su recepción el Día de Hoy.""");
                    if (!await launchUrl(_url)) {
                      throw Exception('Could not launch $_url');
                    }
                  },
                  child: const Icon(
                    Icons.send,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () async {
                      var _url = Uri(
                          scheme: 'tel',
                          path:
                              '${dataL[index]['telefono_shipping'].toString()}');

                      if (!await launchUrl(_url)) {
                        throw Exception('Could not launch $_url');
                      }
                    },
                    child: Icon(Icons.phone))
              ],
            ),
          ),
          // DataCell(
          //   Text(dataL[index]['operadore'].toString() != null &&
          //           dataL[index]['operadore'].toString().isNotEmpty
          //       ? dataL[index]['operadore'] != null &&
          //               dataL[index]['operadore'].isNotEmpty &&
          //               dataL[index]['operadore'][0]['up_users'] != null &&
          //               dataL[index]['operadore'][0]['up_users'].isNotEmpty &&
          //               dataL[index]['operadore'][0]['up_users'][0]
          //                       ['username'] !=
          //                   null
          //           ? dataL[index]['operadore'][0]['up_users'][0]['username']
          //           : ""
          //       : ""),
          // ),
          DataCell(InkWell(
              child: Text(
                getStateFromJson(
                    dataL[index]['gestioned_novelty']?.toString(), 'comment'),
              ),
              onTap: () {
                info(context, index);
              })),
          DataCell(
            Text(dataL[index]['nombre_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['ciudad_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['direccion_shipping'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(
              dataL[index]['telefono_shipping'].toString(),
              style: TextStyle(
                  color: GetColorofStateNovelti(getStateFromJson(
                      dataL[index]['gestioned_novelty']?.toString(), 'state'))),
            ),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['cantidad_total'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['producto_p'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['producto_extra'] == null ||
                    dataL[index]['producto_extra'].toString() == "null"
                ? ""
                : dataL[index]['producto_extra'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text("\$ ${dataL[index]['precio_total'].toString()}"),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['observacion'] == null ||
                    dataL[index]['observacion'].toString() == "null"
                ? ""
                : dataL[index]['observacion'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['comentario'] == null ||
                    dataL[index]['comentario'].toString() == "null"
                ? ""
                : dataL[index]['comentario'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(
                style: TextStyle(color: GetColor(dataL[index]['status'])),
                dataL[index]['status'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['tipo_pago'] == null ||
                    dataL[index]['tipo_pago'].toString() == "null"
                ? ""
                : dataL[index]['tipo_pago'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['estado_devolucion'] == null ||
                    dataL[index]['estado_devolucion'].toString() == "null"
                ? ""
                : dataL[index]['estado_devolucion'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          DataCell(
            Text(dataL[index]['marca_t_d'] == null ||
                    dataL[index]['marca_t_d'].toString() == "null"
                ? ""
                : dataL[index]['marca_t_d'].toString()),
            onTap: () {
              info(context, index);
            },
          ),
          // DataCell(
          //   Text(dataL[index]['marca_t_i'] == null ||
          //           dataL[index]['marca_t_i'].toString() == "null"
          //       ? ""
          //       : dataL[index]['marca_t_i'].toString()),
          // ),
          // DataCell(
          //   Text(dataL[index]['estado_pagado'].toString()),
          // ),
          DataCell(
            getLengthArrayMap(dataL[index]['novedades']),
            onTap: () {
              info(context, index);
            },
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  sortFunc3(filtro, changevalu) {
    setState(() {
      if (changevalu) {
        sortFieldDefaultValue = "$filtro:DESC";
        changevalue = false;
      } else {
        // changevalue = true;
        sortFieldDefaultValue = "$filtro:ASC";
        changevalue = true;
      }
      loadData();
    });
  }

  void resetFilters() {
    searchController.clear();
    _controllers.fechaController.clear();
    _controllers.fechaentregaController.clear();
    _controllers.codigoController.clear();
    _controllers.nombreClienteController.clear();
    _controllers.ciudadClienteController.clear();
    _controllers.direccionClienteController.clear();
    _controllers.telefonoClienteController.clear();
    _controllers.cantidadController.clear();
    _controllers.productoController.clear();
    _controllers.productoextraController.clear();
    _controllers.precioTotalController.clear();
    _controllers.observacionController.clear();
    _controllers.comentarioController.clear();
    _controllers.statusController.clear();
    _controllers.tipoPagoController.clear();
    _controllers.suRutaController.clear();
    _controllers.estDevController.clear();
    _controllers.mdtOfController.clear();
    _controllers.mdtBodController.clear();
    _controllers.mdtRutaController.clear();
    _controllers.mtdInpController.clear();
    _controllers.estadoPagoController.clear();
    arrayFiltersAnd = [];
    _controllers.searchController.clear();
  }

  getLengthArrayMap(List data) {
    var arraylength = data.length;
    return Text(
      arraylength.toString(),
      style: TextStyle(
          color:
              arraylength > 3 ? Color.fromARGB(255, 28, 143, 8) : Colors.black),
    );
  }

  Color? GetColor(state) {
    int color = 0xFF000000;

    switch (state) {
      case "ENTREGADO":
        color = 0xFF33FF6D;
        break;
      case "NOVEDAD":
        color = 0xFFD6DC27;
        break;
      case "NOVEDAD RESUELTA":
        color = 0xFF6A1B9A;
        break;
      case "NO ENTREGADO":
        color = 0xFFFF3333;
        break;
      case "REAGENDADO":
        color = 0xFFFA37BF;
        break;
      case "EN RUTA":
        color = 0xFF3341FF;
        break;
      case "EN OFICINA":
        color = 0xFF4B4C4B;
        break;
      case "PEDIDO PROGRAMADO":
        color = 0xFFEF7F0E;
        break;

      default:
        color = 0xFF000000;
    }

    return Color(color);
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
          paginateData();
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
                    });

                    setState(() {
                      paginateData();
                    });
                    Navigator.pop(context);
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

  Future<dynamic> info(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width > 600
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                  Expanded(
                      child: InfoStateOrdersOperator(
                    id: dataL[index]['id'].toString(),
                    comment: dataL[index]['comentario'].toString(),
                    data: dataL,
                    order: dataL[index],
                  ))
                ],
              ),
            ),
          );
        }).then((value) => loadData());
  }
}
