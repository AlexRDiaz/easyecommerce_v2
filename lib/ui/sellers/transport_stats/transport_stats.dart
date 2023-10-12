import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/sellers/transport_stats/chart_dynamic.dart';
// import 'package:frontend/ui/widgets/loading.dart';

class tansportStats extends StatefulWidget {
  const tansportStats({Key? key}) : super(key: key);

  @override
  State<tansportStats> createState() => _tansportStatsState();
}

class _tansportStatsState extends State<tansportStats> {
  List<Map<String, dynamic>> entries = [];
  Map<String, dynamic> listarutas_transportadoras = {};

  // List<dynamic> listarutas_transportadoras = [];

  // late Chart chart;
  String idTrans = "";
  String idRuta = "";

  List<dynamic> sections = [];
  List<dynamic> sections2 = [];
  List<dynamic> sections3 = [];
  List<dynamic> sectionsgeneralTrans = [];
  List<dynamic> sectionsgeneralRoutes = [];

  var entregadosGeneralTrans = 0.0;
  var totalGeneralTrans = 0.0;

  var entregadosGeneralRoutes = 0.0;
  var totalGeneralRoutes = 0.0;

  var entregados = 0.0;
  var noEntregados = 0.0;
  var total = 0.0;
  var entregados2 = 0.0;
  var noEntregados2 = 0.0;
  var total2 = 0.0;
  var entregados3 = 0.0;
  var noEntregados3 = 0.0;
  var total3 = 0.0;

  var responsetransportadoras;
  var responseroutes;
  var responseroutesofTransport;
  var responsGeneralDataofTransport;
  var responsGeneralDataofRoutes;

  List<String> transp = [];
  List<String> rutasEncontradas = [];
  List<String> transportadorasEncontradas = [];
  List<Map<String, dynamic>> routes = [];

  List<String> pedidosEncontrados = [];

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
            bottom: TabBar(
              tabs: [
                Tab(text: 'Transportadora->Ciudades'),
                Tab(text: 'Ciudades->Transportadora'),
                Tab(text: 'Mis Transportes'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Contenido de la pestaña 1

              principal(),
              // Contenido de la pestaña 2
              // Puedes agregar tu contenido aquí según sea necesario
              principal2(),
              // Contenido de la pestaña 3
              // Puedes agregar tu contenido aquí según sea necesario
              principal3()
            ],
          ),
        ));

    // principal();
  }

  // Future<void> _loadPedidos(String rutaId) async {
  //   try {
  //     var peds = await Connections().getPedidosOfRuta(rutaId);
  //     setState(() {
  //       pedidosEncontrados = List<String>.from(peds);
  //     });
  //   } catch (error) {
  //     print("Error al obtener los pedidos: $error");
  //   }
  // }
  void updateChart(double entregados, double total, sections) {
    Color base;

    if (((entregados / total) * 100) >= 75.00) {
      base = Color.fromARGB(225, 116, 204, 39).withOpacity(0.7);
    } else if (((entregados / total) * 100) >= 50 &&
        ((entregados / total) * 100) < 75) {
      base = Color.fromARGB(224, 204, 190, 39).withOpacity(0.7);
    } else if (((entregados / total) * 100) >= 25 &&
        ((entregados / total) * 100) < 50) {
      base = Color.fromARGB(223, 204, 119, 39).withOpacity(0.7);
    } else {
      base = Color.fromARGB(223, 218, 54, 22).withOpacity(0.7);
    }

    setState(() {
      sections.clear();
      // double porcentaje = total > 0 ? (entregados) / total : 0.0;
      // porcentaje = porcentaje.clamp(0.0, 100.0); // Asegura que esté en el rango [0, 100]
      sections.add({
        'color': base,
        'value': entregados,
        'showTitle': true,
        'tistle': "Entregados",
        'radius': 20,
      });
      

      print(entregados);
    });
  }

  Future<void> loadData() async {
    try {
      responsetransportadoras = await Connections().getTransportadoras();
      responseroutes = await Connections().getRoutesLaravel();

      transp = List<String>.from(responsetransportadoras['transportadoras']);
      routes = List<Map<String, dynamic>>.from(responseroutes);

      updateChart(entregados, total, sections);
      // updateChart(entregados2, total2, sections2);
      updateChart(
          entregadosGeneralTrans, totalGeneralTrans, sectionsgeneralTrans);
      updateChart(
          entregadosGeneralRoutes, totalGeneralRoutes, sectionsgeneralRoutes);
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
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[350],
                          ),
                          margin: EdgeInsets.all(5),
                          width: 380,
                          height: 550,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: const Text(
                                  "Transportadoras",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(), // Opcional: Divider para separar el texto de la lista
                              Expanded(
                                child: _buildListView(transp),
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
                          margin: EdgeInsets.all(5),
                          width: 380,
                          height: 550,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: const Text(
                                  "Ciudades",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(), // Opcional: Divider para separar el texto de la lista
                              Expanded(
                                child: _buildListViewRutas(rutasEncontradas),
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
                              Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  "Nivel de Efectividad General",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(),
                              ChartDynamic(
                                  sections: sectionsgeneralTrans,
                                  total: totalGeneralTrans),
                              Divider(),
                              Padding(
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
                              ChartDynamic(sections: sections, total: total),
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
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: EdgeInsets.all(20),
                        width: 360,
                        height: 280,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: const Text(
                                "Transportadoras",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(), // Opcional: Divider para separar el texto de la lista
                            Expanded(
                              child: _buildListView(transp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[350],
                      ),
                      margin: EdgeInsets.all(20),
                      width: 360,
                      height: 280,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: const Text(
                              "Ciudades",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(), // Opcional: Divider para separar el texto de la lista
                          Expanded(
                            child: _buildListViewRutas(rutasEncontradas),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[350],
                      ),
                      margin: const EdgeInsets.all(20),
                      width: 360,
                      height: 500,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              "Nivel de Efectividad General",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(),
                          ChartDynamic(
                              sections: sectionsgeneralTrans,
                              total: totalGeneralTrans),
                          Divider(),
                          Padding(
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
                          ChartDynamic(sections: sections, total: total),
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
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: const Text(
                                "Ciudades",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(), // Opcional: Divider para separar el texto de la lista
                            Expanded(
                              child: _buildListViewCiudades(
                                  routes.cast<Map<String, dynamic>>()),
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
                        margin: EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: const Text(
                                "Transportadoras",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(), // Opcional: Divider para separar el texto de la lista
                            Expanded(
                              child: _buildListViewTransportadoras(
                                  transportadorasEncontradas),
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
                            Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                "Nivel de Efectividad General",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            ChartDynamic(
                                sections: sectionsgeneralRoutes,
                                total: totalGeneralRoutes),
                            Divider(),
                            Padding(
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
                            ChartDynamic(sections: sections2, total: total2),
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[350],
                    ),
                    margin: EdgeInsets.all(20),
                    width: 360,
                    height: 280,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: const Text(
                            "Ciudades",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(), // Opcional: Divider para separar el texto de la lista
                        Expanded(
                          child: _buildListViewCiudades(
                              routes.cast<Map<String, dynamic>>()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[350],
                  ),
                  margin: EdgeInsets.all(20),
                  width: 360,
                  height: 280,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: const Text(
                          "Transportadoras",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(), // Opcional: Divider para separar el texto de la lista
                      Expanded(
                        child: _buildListViewTransportadoras(
                            transportadorasEncontradas),
                      ),
                    ],
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[350],
                  ),
                  margin: const EdgeInsets.all(20),
                  width: 360,
                  height: 500,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          "Nivel de Efectividad General",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(),
                      ChartDynamic(
                          sections: sectionsgeneralRoutes,
                          total: totalGeneralRoutes),
                      Divider(),
                      Padding(
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
                      ChartDynamic(sections: sections2, total: total2),
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
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: EdgeInsets.all(5),
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
                              child: Text("Mis Transportes"),
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
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[350],
                        ),
                        margin: EdgeInsets.all(5),
                        width: 380,
                        height: 550,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: const Text(
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
                            Padding(
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[350],
                    ),
                    margin: EdgeInsets.all(20),
                    width: 360,
                    height: 280,
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
                          child: Text("Mis Transportes"),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
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
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[350],
                  ),
                  margin: EdgeInsets.all(20),
                  width: 360,
                  height: 280,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: const Text(
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
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[350],
                  ),
                  margin: const EdgeInsets.all(20),
                  width: 360,
                  height: 280,
                  child: Column(
                    children: [
                      Padding(
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

  Widget _buildListView(List<String> transportadoras) {
    return ListView.builder(
      itemCount: transportadoras.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            print("Hola: ${transportadoras[index]}");
            try {
              idTrans = transportadoras[index].split('-')[1];

              var rutas = await Connections()
                  .getRutasOfTransport(transportadoras[index].split('-')[1]);
              setState(() {
                rutasEncontradas = List<String>.from(rutas['rutas']);
                print(rutasEncontradas);
              });

              responsGeneralDataofTransport = await Connections()
                  .getGeneralDataOrdersofTransport(
                      transportadoras[index].split('-')[1]);
              // print(responsGeneralDataofTransport);
              setState(() {
                entregadosGeneralTrans =
                    responsGeneralDataofTransport['entregados_count'];
                totalGeneralTrans =
                    responsGeneralDataofTransport['total_pedidos'];
              });

              updateChart(entregadosGeneralTrans, totalGeneralTrans,
                  sectionsgeneralTrans);
            } catch (error) {
              print("Error al obtener las transportadoras: $error");
            }
          },
          child: Container(
            margin: EdgeInsets.all(2.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.blueGrey[800],
            ),
            child: ListTile(
              title: Row(
                children: [
                  Icon(Icons.local_shipping,
                      color: Colors.white), // Icono de camión
                  SizedBox(width: 8.0), // Espacio entre el icono y el texto
                  Text(
                    transportadoras[index].split('-')[0],
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListViewRutas(List<String> nruta) {
    return ListView.builder(
      itemCount: nruta.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            try {
              print("${nruta[index].split('-')[1]} || $idTrans");
              var nrutaResponse = await Connections()
                  .getPedidosOfRuta(nruta[index].split('-')[1], idTrans);

              // idTrans="0";

              if (nrutaResponse != null) {
                setState(() {
                  var newpds = nrutaResponse
                      .map((key, value) => MapEntry(key, value.toString()));
                  entregados = double.parse(newpds['entregados'].toString());
                  noEntregados =
                      double.parse(newpds['no_entregados'].toString());
                  total = double.parse(newpds['suma_total'].toString());

                  print("$entregados | $noEntregados | $total");
                  updateChart(entregados, total, sections);
                });
              } else {
                print("La respuesta de getPedidosOfRuta es nula.");
              }
            } catch (error) {
              print("Error al obtener los pedidos de la ruta: $error");
            }
          },
          child: Container(
            margin: EdgeInsets.all(2.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.blueGrey[800],
            ),
            child: ListTile(
              title: Row(
                children: [
                  Icon(Icons.location_on,
                      color: Colors.white), // Icono de camino
                  SizedBox(width: 8.0), // Espacio entre el icono y el texto
                  Text(
                    nruta[index].split('-')[0],
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListViewTransportadoras(List<String> nruta) {
    return ListView.builder(
      itemCount: nruta.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            // print("pedidos");
            try {
              print("$idRuta-${nruta[index].split('-')[1]}");

              var nrutaResponse = await Connections()
                  .getPedidosOfRuta(idRuta, nruta[index].split('-')[1]);

              if (nrutaResponse != null) {
                setState(() {
                  var newpds = nrutaResponse
                      .map((key, value) => MapEntry(key, value.toString()));
                  // print(newpds);
                  entregados2 = double.parse(newpds['entregados'].toString());
                  noEntregados2 =
                      double.parse(newpds['no_entregados'].toString());
                  total2 = double.parse(newpds['suma_total'].toString());

                  print("$entregados2 | $noEntregados2 | $total2");

                  updateChart(entregados2, total2, sections2);
                });
              } else {
                print("La respuesta de getPedidosOfRuta es nula.");
                // Puedes tomar medidas adicionales, como mostrar un mensaje al usuario.
              }
            } catch (error) {
              print("Error al obtener los pedidos de la ruta: $error");
            }
          },
          child: Container(
            margin: EdgeInsets.all(2.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.blueGrey[800],
            ),
            child: ListTile(
                title: Row(children: [
              Icon(Icons.local_shipping,
                  color: Colors.white), // Icono de camión
              SizedBox(width: 8.0),
              Text(
                nruta[index].split('-')[0],
                style: TextStyle(color: Colors.white),
              ),
            ])),
          ),
        );
      },
    );
  }

  Widget _buildListViewCiudades(List<Map<String, dynamic>> ciudades) {
    return ListView.builder(
      itemCount: ciudades.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> ciudad = ciudades[index];

        return GestureDetector(
          onTap: () async {
            // Manejar el clic aquí
            print("Hola: ${ciudad['titulo']}");
            idRuta = ciudad['id'].toString();
            try {
              var transprtdrs =
                  await Connections().getTransportadorasOfRuta(ciudad['id']);
              setState(() {
                transportadorasEncontradas =
                    List<String>.from(transprtdrs['transportadoras']);
                print(transportadorasEncontradas);
                // Aquí puedes agregar lógica adicional si es necesario
              });
              responsGeneralDataofRoutes = await Connections()
                  .getGeneralDataOrdersofRoutes(ciudad['id']);
              // print(responsGeneralDataofTransport);
              setState(() {
                entregadosGeneralRoutes =
                    responsGeneralDataofRoutes['entregados_count'];
                totalGeneralRoutes =
                    responsGeneralDataofRoutes['total_pedidos'];
              });

              updateChart(entregadosGeneralRoutes, totalGeneralRoutes,
                  sectionsgeneralRoutes);
            } catch (error) {
              print("Error al obtener las transportadoras: $error");
            }
          },
          child: Container(
            margin: EdgeInsets.all(2.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.blueGrey[800],
            ),
            child: ListTile(
              title: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text("${ciudad['titulo']}",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ! ************************************************************
  Widget _buildListViewFromData(Map<String, dynamic> data) {
    // Obtén todas las claves (nombres de propiedades) del mapa
    List<String> keys = data.keys.toList();

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        String key = keys[index];

        // Puedes personalizar este ListTile según tus necesidades
        return Container(
          margin: EdgeInsets.all(2.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Color.fromARGB(255, 15, 119, 222),
          ),
          child: ListTile(
            title: Row(children: [
              Icon(Icons.my_location_outlined,
                  color: Colors.white), // Icono de camión
              SizedBox(width: 8.0),
              Text(key.split('-')[0], style: TextStyle(color: Colors.white)),
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

  Widget _buildListViewFromEntries(entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> entry = entries[index];

        return Container(
          margin: EdgeInsets.all(2.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Color.fromARGB(255, 15, 119, 222),
          ),
          child: ListTile(
            title: Row(
              children: [
                Icon(Icons.my_location_outlined, color: Colors.white),
                SizedBox(width: 8.0),
                Text(entry['transportadoras'].split('-')[0],
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            // subtitle: Text(
            //     'Entregados: ${entry['entregados_count']}, No entregados: ${entry['no_entregados_count']}, Total Pedidos: ${entry['total_pedidos']}'),
            onTap: () {
              // Puedes realizar acciones adicionales al hacer clic en una entrada

              entregados3 = double.parse(entry['entregados_count'].toString());
              noEntregados3 =
                  double.parse(entry['no_entregados_count'].toString());
              total3 = double.parse(entry['total_pedidos'].toString());

              print("$entregados3 | $noEntregados3 | $total3");
              updateChart(entregados3, total3, sections3);
              // print('Clic en ${entry['transportadoras']}');
              // print('Detalles: $entry');
            },
          ),
        );
      },
    );
  }
}
