import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:d_chart/d_chart.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
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
  List<DateTime?> _dates = [];
  String dateDesde = "";
  String dateHasta = "";
  String idTransport = "";
  String? selectValueTransport = null;
  List<String> transports = [];
  String? selectValueOperator = null;
  List<String> operators = [];
  List<Map<String, dynamic>> dataChart = [];
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    var responseOperator = [];
    setState(() {
      transports = [];
      operators = [];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    var responseTransports = await Connections().getAllTransportators();
    if (selectValueTransport != null) {
      responseOperator =
          await Connections().getAllOperatorsAndByTransport(idTransport);
    } else {
      responseOperator = await Connections().getAllOperators();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    "FILTROS",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _desde(context),
                  SizedBox(
                    height: 10,
                  ),
                  _hasta(context),
                  SizedBox(
                    height: 10,
                  ),
                  _sellersTransport(context),
                  SizedBox(
                    height: 10,
                  ),
                  _operators(context),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _checks()
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: dateDesde == "" || dateHasta == ""
                          ? null
                          : () async {
                              getLoadingModal(context, false);
                              var response = await Connections()
                                  .getInfoDashboardSellers(
                                      dateDesde.toString(),
                                      dateHasta.toString(),
                                      selectValueTransport != null
                                          ? selectValueTransport
                                              .toString()
                                              .split("-")[1]
                                              .toString()
                                          : "null",
                                      selectValueOperator != null
                                          ? selectValueOperator
                                              .toString()
                                              .split("-")[1]
                                              .toString()
                                          : "null",
                                      checks);
                              setState(() {
                                dataChart = [...response];
                              });
                              Navigator.pop(context);
                            },
                      child: Text(
                        "Buscar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 600,
                    child: DChartPie(
                      data: dataChart,
                      fillColor: (pieData, index) => Colors.greenAccent,
                      pieLabel: (pieData, index) {
                        return "${pieData['domain'].toString()}:\nC:${pieData['measure'].toString()} \n%:${generatePorcent(pieData['measure'])}%";
                      },
                      labelPosition: PieLabelPosition.inside,
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

  DropdownButtonHideUnderline _sellersTransport(BuildContext context) {
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

  Container _desde(BuildContext context) {
    return Container(
        width: 500,
        child: Wrap(
          children: [
            TextButton(
                onPressed: () async {
                  setState(() {});
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

                      String nuevaFecha = "$dia/$mes/$anio";
                      setState(() {
                        dateDesde = nuevaFecha;
                      });
                    }
                  });
                },
                child: Text(
                  "DESDE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            SizedBox(
              width: 10,
            ),
            Text(
              "Fecha: $dateDesde",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ));
  }

  Container _hasta(BuildContext context) {
    return Container(
        width: 500,
        child: Wrap(
          children: [
            TextButton(
                onPressed: () async {
                  setState(() {});
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

                      String nuevaFecha = "$dia/$mes/$anio";
                      setState(() {
                        dateHasta = nuevaFecha;
                      });
                    }
                  });
                },
                child: Text(
                  "HASTA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            SizedBox(
              width: 10,
            ),
            Text(
              "Fecha: $dateHasta",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ));
  }

  Container _checks() {
    return Container(
      width: 500,
      child: Wrap(
        children: [
          Container(
            width: 300,
            child: Row(
              children: [
                Checkbox(
                    value: entregado,
                    onChanged: (v) {
                      setState(() {
                        if (v!) {
                          entregado = true;
                          checks.add("ENTREGADO");
                        } else {
                          entregado = false;

                          checks.remove("ENTREGADO");
                        }
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                    child: Text(
                  "Entregado",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ))
              ],
            ),
          ),
          Container(
            width: 300,
            child: Row(
              children: [
                Checkbox(
                    value: noEntregado,
                    onChanged: (v) {
                      setState(() {
                        if (v!) {
                          noEntregado = true;
                          checks.add("NO ENTREGADO");
                        } else {
                          noEntregado = false;

                          checks.remove("NO ENTREGADO");
                        }
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                    child: Text(
                  "No Entregado",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ))
              ],
            ),
          ),
          Container(
            width: 300,
            child: Row(
              children: [
                Checkbox(
                    value: novedad,
                    onChanged: (v) {
                      setState(() {
                        if (v!) {
                          novedad = true;
                          checks.add("NOVEDAD");
                        } else {
                          novedad = false;

                          checks.remove("NOVEDAD");
                        }
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                    child: Text(
                  "Novedad",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ))
              ],
            ),
          ),
          Container(
            width: 300,
            child: Row(
              children: [
                Checkbox(
                    value: reagendado,
                    onChanged: (v) {
                      setState(() {
                        if (v!) {
                          reagendado = true;
                          checks.add("REAGENDADO");
                        } else {
                          reagendado = false;

                          checks.remove("REAGENDADO");
                        }
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                    child: Text(
                  "Reagendado",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ))
              ],
            ),
          ),
          Container(
            width: 300,
            child: Row(
              children: [
                Checkbox(
                    value: enRuta,
                    onChanged: (v) {
                      setState(() {
                        if (v!) {
                          enRuta = true;
                          checks.add("EN RUTA");
                        } else {
                          enRuta = false;

                          checks.remove("EN RUTA");
                        }
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                    child: Text(
                  "En Ruta",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ))
              ],
            ),
          ),
          Container(
            width: 300,
            child: Row(
              children: [
                Checkbox(
                    value: enOficina,
                    onChanged: (v) {
                      setState(() {
                        if (v!) {
                          enOficina = true;
                          checks.add("EN OFICINA");
                        } else {
                          enOficina = false;

                          checks.remove("EN OFICINA");
                        }
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                    child: Text(
                  "En Oficina",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ))
              ],
            ),
          ),
          Container(
            width: 300,
            child: Row(
              children: [
                Checkbox(
                    value: programado,
                    onChanged: (v) {
                      setState(() {
                        if (v!) {
                          programado = true;
                          checks.add("PEDIDO PROGRAMADO");
                        } else {
                          programado = false;

                          checks.remove("PEDIDO PROGRAMADO");
                        }
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                    child: Text(
                  "P. Programado",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ))
              ],
            ),
          )
        ],
      ),
    );
  }

  generatePorcent(measure) {
    double suma = 0.0;
    for (var i = 0; i < dataChart.length; i++) {
      suma += dataChart[i]['measure'];
    }

    double temp = ((measure * 100) / suma);
    return temp.toStringAsFixed(2);
  }
}
