import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/sellers/transport_stats/chart_dynamic.dart';
import 'package:frontend/ui/sellers/transport_stats/chart_dynamic_cron.dart';
// import 'package:frontend/ui/widgets/loading.dart';

class tansportStats extends StatefulWidget {
  const tansportStats({Key? key}) : super(key: key);

  @override
  State<tansportStats> createState() => _tansportStatsState();
}

class _tansportStatsState extends State<tansportStats> {
  bool isdataLoaded = false;
  List<Map<String, dynamic>> entries = [];
  Map<String, dynamic> listarutas_transportadoras = {};

  List<dynamic> sections = [];
  List<dynamic> sections3 = [];
  List<dynamic> sectionsCron = [];
  List<dynamic> sectionsCronMonth = [];
  List<dynamic> sectionsCronrt = [];
  List<dynamic> sectionsCronMonthrt = [];

  var entregadosGeneralTrans = 0.0;
  var totalGeneralTrans = 0.0;

  var entregados = 0.0;
  var noEntregados = 0.0;
  var total = 0.0;

  var entregados3 = 0.0;
  var noEntregados3 = 0.0;
  var total3 = 0.0;

  var entregadosCron = 0.0;
  var entregadosCronCounter = 0;
  var entregadosCronMonth = 0.0;
  var entregadosCronMonthCounter = 0;
  String monthDate = "";
  String dayDate = "";

  var responsGeneralDataofTransport;

  List<String> transp = [];
  List<String> rutasEncontradas = [];

  var responsebdddatacron;
  var responsebdddatacronrt;

  Map<String, dynamic> transpdatacron = {};
  Map<String, dynamic> transpdatacronrt = {};

  List<Map<String, dynamic>> entriescron = [];
  List<Map<String, dynamic>> entriescronrt = [];

  int? selectedIndex;
  int? selectedIndex2;
  int? selectedIndex2_2;
  int? selectedIndex1_2;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            // title: Text('Transport Stats'),
            // automaticallyImplyLeading: false,
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Transportadora -> Ciudades'),
                Tab(text: 'Ciudades -> Transportadora'),
                Tab(text: 'Mis Transportes'),
              ],
            ),
          ),
          body: TabBarView(
            children: [principal(), principal2(), principal3()],
          ),
        ));
  }

  void updateChartCron(double entregados, int counter, sections,
      String monthDate, String dayDate) {
    Color base;

    if (((entregados / counter) * 100) >= 75.00) {
      base = Color.fromARGB(225, 116, 204, 39).withOpacity(0.7);
    } else if (((entregados / counter) * 100) >= 50 &&
        ((entregados / counter) * 100) < 75) {
      base = Color.fromARGB(224, 204, 190, 39).withOpacity(0.7);
    } else if (((entregados / counter) * 100) >= 25 &&
        ((entregados / counter) * 100) < 50) {
      base = Color.fromARGB(223, 204, 119, 39).withOpacity(0.7);
    } else {
      base = Color.fromARGB(223, 218, 54, 22).withOpacity(0.7);
    }

    setState(() {
      sections.clear();
      sections.add({
        'color': base,
        'value': entregados,
        'counter': counter,
        'month_date': monthDate,
        'day_date': dayDate,
        'showTitle': true,
        'tistle': "Entregados",
        'radius': 20,
      });
    });
  }

  void updateChart(double entregados, double total, sections) {
    Color base;

    if (((entregados / total) * 100) >= 75.00) {
      base = const Color.fromARGB(225, 116, 204, 39).withOpacity(0.7);
    } else if (((entregados / total) * 100) >= 50 &&
        ((entregados / total) * 100) < 75) {
      base = const Color.fromARGB(224, 204, 190, 39).withOpacity(0.7);
    } else if (((entregados / total) * 100) >= 25 &&
        ((entregados / total) * 100) < 50) {
      base = const Color.fromARGB(223, 204, 119, 39).withOpacity(0.7);
    } else {
      base = const Color.fromARGB(223, 218, 54, 22).withOpacity(0.7);
    }

    setState(() {
      sections.clear();
      sections.add({
        'color': base,
        'value': entregados,
        'showTitle': true,
        'tistle': "Entregados",
        'radius': 20,
      });

      // print(entregados);
    });
  }

  Future<void> loadData() async {
    try {
      isdataLoaded = true;
      // !ultimo agregado
      responsebdddatacron = await Connections().getGeneralDataCron();
      responsebdddatacronrt = await Connections().getGeneralDataCronrt();

      // print(responsebdddatacronrt);
      // ! ********
      transpdatacron = responsebdddatacron;
      transpdatacronrt = responsebdddatacronrt;

      updateChart(entregados, total, sections);
    } catch (e) {
      print("Error al cargar datos: $e");
    }
  }

  Widget principal() {
    return responsive(
        Container(
          alignment: Alignment.center,
          child: Wrap(
            children: [
              Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[350],
                          ),
                          margin: const EdgeInsets.all(5),
                          width: 380,
                          height: 550,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  "Transportadoras",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(), // Opcional: Divider para separar el texto de la lista
                              Expanded(
                                // child: _buildListView(transp),
                                child:
                                    _buildListViewFromDataCron(transpdatacron),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[350],
                          ),
                          margin: const EdgeInsets.all(5),
                          width: 380,
                          height: 550,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  "Sectores",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(), // Opcional: Divider para separar el texto de la lista
                              Expanded(
                                // child: _buildListViewRutas(rutasEncontradas),
                                child:
                                    _buildListViewFromEntriesCron(entriescron),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[350],
                          ),
                          margin: const EdgeInsets.all(5),
                          width: 380,
                          height: 550,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  // "Nivel de Efectividad Específico",
                                  "Nivel de Efectividad General",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(),
                              ChartDynamicCron(sections: sectionsCronMonth),
                              Divider(),
                              const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  "Nivel de Efectividad Específico",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(),
                              entregadosCron > 0
                                  ? ChartDynamicCron(sections: sectionsCron)
                                  : Expanded(
                                      child: Container(
                                          height: 50,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text('Datos No disponibles',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 26,
                                                    color: const Color.fromARGB(
                                                            223, 204, 119, 39)
                                                        .withOpacity(0.7),
                                                  )),
                                            ],
                                          ))),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          // alignment: Alignment.center,
          child: Wrap(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: const EdgeInsets.all(20),
                        width: 360,
                        height: 280,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                "Transportadoras",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(), // Opcional: Divider para separar el texto de la lista
                            Expanded(
                              child: _buildListViewFromDataCron(transpdatacron),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[350],
                      ),
                      margin: const EdgeInsets.all(20),
                      width: 360,
                      height: 280,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              "Sectores",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(), // Opcional: Divider para separar el texto de la lista
                          Expanded(
                            child: _buildListViewFromEntriesCron(entriescron),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[350],
                      ),
                      margin: const EdgeInsets.all(20),
                      width: 360,
                      height: 500,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              // "Nivel de Efectividad Específico",
                              "Nivel de Efectividad General",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(),
                          ChartDynamicCron(sections: sectionsCronMonth),
                          Divider(),
                          const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              "Nivel de Efectividad Específico",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(),
                          entregadosCron > 0
                              ? ChartDynamicCron(sections: sectionsCron)
                              : Expanded(
                                  child: Container(
                                      height: 50,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('Datos No disponibles',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 26,
                                                color: const Color.fromARGB(
                                                        223, 204, 119, 39)
                                                    .withOpacity(0.7),
                                              )),
                                        ],
                                      ))),
                        ],
                      ),
                    )
                  ])
                ],
              ),
            ],
          ),
        ),
        context);
  }

  Widget principal2() {
    return responsive(
        Container(
            alignment: Alignment.center,
            child: Wrap(children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: const EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                "Sectores",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(), // Opcional: Divider para separar el texto de la lista
                            Expanded(
                              child: _buildListViewFromDataCronrt(
                                  transpdatacronrt),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: const EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                "Transportadoras",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(), // Opcional: Divider para separar el texto de la lista
                            Expanded(
                              child: _buildListViewFromEntriesCronrt(
                                  entriescronrt),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: const EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                // "Nivel de Efectividad Específico",
                                "Nivel de Efectividad General",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            ChartDynamicCron(sections: sectionsCronMonth),
                            Divider(),
                            const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                "Nivel de Efectividad Específico",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            entregadosCron > 0
                                  ? ChartDynamicCron(sections: sectionsCron)
                                  : Expanded(
                                      child: Container(
                                          height: 50,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text('Datos No disponibles',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 26,
                                                    color: const Color.fromARGB(
                                                            223, 204, 119, 39)
                                                        .withOpacity(0.7),
                                                  )),
                                            ],
                                          ))),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ])),
        SingleChildScrollView(
            // alignment: Alignment.center,
            child: Wrap(children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[350],
                    ),
                    margin: const EdgeInsets.all(20),
                    width: 360,
                    height: 280,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            "Sectores",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(), // Opcional: Divider para separar el texto de la lista
                        Expanded(
                          child: _buildListViewFromDataCronrt(transpdatacronrt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[350],
                  ),
                  margin: const EdgeInsets.all(20),
                  width: 360,
                  height: 280,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          "Transportadoras",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(), // Opcional: Divider para separar el texto de la lista
                      Expanded(
                        child: _buildListViewFromEntriesCronrt(entriescronrt),
                      ),
                    ],
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[350],
                  ),
                  margin: const EdgeInsets.all(20),
                  width: 360,
                  height: 500,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          // "Nivel de Efectividad Específico",
                          "Nivel de Efectividad General",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(),
                      ChartDynamicCron(sections: sectionsCronMonth),
                      Divider(),
                      const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          "Nivel de Efectividad Específico",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(),
                      entregadosCron > 0
                                  ? ChartDynamicCron(sections: sectionsCron)
                                  : Expanded(
                                      child: Container(
                                          height: 50,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text('Datos No disponibles',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 26,
                                                    color: const Color.fromARGB(
                                                            223, 204, 119, 39)
                                                        .withOpacity(0.7),
                                                  )),
                                            ],
                                          ))),
                    ],
                  ),
                )
              ])
            ],
          ),
        ])),
        context);
  }

  Widget principal3() {
    return responsive(
        Container(
            alignment: Alignment.center,
            child: Wrap(children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: const EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                // Llamar a la función cuando se hace clic en el botón
                                var dataPersonal = await Connections()
                                    .getUserPedidos(sharedPrefs!
                                        .getString("idComercialMasterSeller")
                                        .toString());
                                listarutas_transportadoras =
                                    dataPersonal['listarutas_transportadoras'];

                                // print(listarutas_transportadoras);

                                await loadData(); // Actualizar el estado llamando a la función que carga los datos
                                setState(
                                    () {}); // Asegurarse de que Flutter vuelva a construir el widget con los nuevos datos
                              },
                              child: const Text("Mis Transportes"),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                            ),
                            Divider(), // Opcional: Divider para separar el botón de la lista
                            // ! AQUIIIIIIIIIIII
                            Expanded(
                              child: _buildListViewFromData(
                                  listarutas_transportadoras),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: const EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                "Transportadoras",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(), // Opcional: Divider para separar el texto de la lista
                            Expanded(
                              child: Visibility(
                                  child: _buildListViewFromEntries(entries)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: const EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                "Nivel de Efectividad",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            ChartDynamic(sections: sections3, total: total3),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              )
            ])),
        SingleChildScrollView(
            // alignment: Alignment.center,
            child: Wrap(children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[350],
                    ),
                    margin: const EdgeInsets.all(20),
                    width: 360,
                    height: 280,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            var dataPersonal = await Connections()
                                .getUserPedidos(sharedPrefs!
                                    .getString("idComercialMasterSeller")
                                    .toString());
                            listarutas_transportadoras =
                                dataPersonal['listarutas_transportadoras'];

                            await loadData(); // Actualizar el estado llamando a la función que carga los datos
                            setState(
                                () {}); // Asegurarse de que Flutter vuelva a construir el widget con los nuevos datos
                          },
                          child: Text("Mis Transportes"),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                        ),
                        Divider(), // Opcional: Divider para separar el botón de la lista
                        Expanded(
                          child: _buildListViewFromData(
                              listarutas_transportadoras),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[350],
                  ),
                  margin: const EdgeInsets.all(20),
                  width: 360,
                  height: 280,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          "Transportadoras",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(), // Opcional: Divider para separar el texto de la lista
                      Expanded(
                        child: Visibility(
                            child: _buildListViewFromEntries(entries)),
                      ),
                    ],
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[350],
                  ),
                  margin: const EdgeInsets.all(20),
                  width: 360,
                  height: 280,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          "Nivel de Efectividad",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(),
                      ChartDynamic(sections: sections3, total: total3),
                    ],
                  ),
                )
              ])
            ],
          )
        ])),
        context);
  }

  Widget _buildListViewFromData(Map<String, dynamic> data) {
    // Obtén todas las claves (nombres de propiedades) del mapa
    List<String> keys = data.keys.toList();

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        String key = keys[index];

        // Puedes personalizar este ListTile según tus necesidades
        return Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: const Color.fromARGB(255, 15, 119, 222),
          ),
          child: ListTile(
            title: Row(children: [
              const Icon(Icons.my_location_outlined,
                  color: Colors.white), // Icono de camión
              const SizedBox(width: 8.0),
              Text(key.split('-')[0],
                  style: const TextStyle(color: Colors.white)),
            ])
            // subtitle: Text('Total Pedidos: ${entries.length}'),
            // onTap: () {
            // Aquí puedes realizar acciones cuando se hace clic en una entrada
            // print('Clic en $key');
            // print('Detalles: $entries');
            // },
            ,
            onTap: () {
              // Aquí puedes realizar acciones cuando se hace clic en una entrada
              setState(() {
                entries = List<Map<String, dynamic>>.from(data[key]);
              });
              // print('Clic en $key');
              // print(entries);
            },
          ),
        );
      },
    );
  }

  Widget _buildListViewFromDataCron(Map<String, dynamic> data) {
    List<String> keys = data.keys.toList();
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        String key = keys[index];
        return Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: (selectedIndex == index)
                ? const Color.fromARGB(255, 23, 99, 134)
                : const Color.fromARGB(255, 91, 95, 99),
          ),
          child: ListTile(
            title: Row(children: [
              const Icon(Icons.my_location_outlined, color: Colors.white),
              const SizedBox(width: 8.0),
              Text(key.split('-')[0],
                  style: const TextStyle(color: Colors.white)),
            ]),
            onTap: () {
              setState(() {
                entriescron = List<Map<String, dynamic>>.from(data[key]);
                selectedIndex = index;
                selectedIndex2 = null;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildListViewFromDataCronrt(Map<String, dynamic> data) {
    // Obtén todas las claves (nombres de propiedades) del mapa
    List<String> keys = data.keys.toList();
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        String key = keys[index];

        // Puedes personalizar este ListTile según tus necesidades
        return Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: (selectedIndex1_2 == index)
                ? const Color.fromARGB(255, 23, 99, 134)
                : const Color.fromARGB(255, 91, 95, 99),
          ),
          child: ListTile(
            title: Row(children: [
              const Icon(Icons.my_location_outlined,
                  color: Colors.white), // Icono de camión
              const SizedBox(width: 8.0),
              Text(key.split('-')[0],
                  style: const TextStyle(color: Colors.white)),
            ]),
            onTap: () {
              // Aquí puedes realizar acciones cuando se hace clic en una entrada
              setState(() {
                entriescronrt = List<Map<String, dynamic>>.from(data[key]);
                // print('Clic en $key');
                // print('Detalles: $entriescron');
                selectedIndex1_2 = index;
                selectedIndex2_2 = null;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildListViewFromEntriesCron(entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> entry = entries[index];

        return Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: (selectedIndex2 == index)
                ? const Color.fromARGB(255, 23, 99, 134)
                : const Color.fromARGB(255, 91, 95, 99),
          ),
          child: ListTile(
            title: Row(
              children: [
                const Icon(Icons.my_location_outlined, color: Colors.white),
                const SizedBox(width: 8.0),
                Text(entry['name'].split('-')[0],
                    // },
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            onTap: () {
              selectedIndex2 = index;
              entregadosCron = double.parse(entry['daily_value'].toString());
              entregadosCronCounter =
                  int.parse(entry['daily_counter'].toString());
              entregadosCronMonth =
                  double.parse(entry['month_value'].toString());
              entregadosCronMonthCounter =
                  int.parse(entry['monthly_counter'].toString());
              monthDate = entry['month_date'].toString();
              dayDate = entry['day_date'].toString();

              updateChartCron(entregadosCron, entregadosCronCounter,
                  sectionsCron, monthDate, dayDate);
              updateChartCron(entregadosCronMonth, entregadosCronMonthCounter,
                  sectionsCronMonth, monthDate, dayDate);
            },
          ),
        );
      },
    );
  }


  
  Widget _buildListViewFromEntriesCronrt(entries) {
    


    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> entry = entries[index];

        return Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: (selectedIndex2_2 == index)
                ? const Color.fromARGB(255, 23, 99, 134)
                : const Color.fromARGB(255, 91, 95, 99),
          ),
          child: ListTile(
            title: Row(
              children: [
                const Icon(Icons.my_location_outlined, color: Colors.white),
                const SizedBox(width: 8.0),
                Text(entry['name'].split('-')[0],
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            // subtitle: Text(
            //     'Entregados: ${entry['entregados_count']}, No entregados: ${entry['no_entregados_count']}, Total Pedidos: ${entry['total_pedidos']}'),
            onTap: () {
              // Puedes realizar acciones adicionales al hacer clic en una entrada
              selectedIndex2_2 = index;
              entregadosCron = double.parse(entry['daily_value'].toString());
              entregadosCronCounter =
                  int.parse(entry['daily_counter'].toString());
              entregadosCronMonth =
                  double.parse(entry['month_value_total'].toString());
              entregadosCronMonthCounter =
                  int.parse(entry['monthly_counter_total'].toString());
              // monthDate = entry['month_date'].toString();
              // dayDate = entry['day_date'].toString();

              updateChartCron(entregadosCron, entregadosCronCounter,
                  sectionsCron, monthDate, dayDate);
              updateChartCron(entregadosCronMonth, entregadosCronMonthCounter,
                  sectionsCronMonth, monthDate, dayDate);


                  // print(entries);
            },
          ),
        );
      },
    );
  }

  Widget _buildListViewFromEntries(entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> entry = entries[index];

        return Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: const Color.fromARGB(255, 15, 119, 222),
          ),
          child: ListTile(
            title: Row(
              children: [
                const Icon(Icons.my_location_outlined, color: Colors.white),
                const SizedBox(width: 8.0),
                Text(entry['transportadoras'].split('-')[0],
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            onTap: () {
              entregados3 = double.parse(entry['entregados_count'].toString());
              noEntregados3 =
                  double.parse(entry['no_entregados_count'].toString());
              total3 = double.parse(entry['total_pedidos'].toString());
              updateChart(entregados3, total3, sections3);
            },
          ),
        );
      },
    );
  }

}
