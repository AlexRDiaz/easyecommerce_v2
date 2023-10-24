import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'dart:math';
import 'package:frontend/connections/connections.dart';

class AccountStatus2 extends StatefulWidget {
  const AccountStatus2({Key? key}) : super(key: key);

  @override
  State<AccountStatus2> createState() => _AccountStatus2State();
}

class _AccountStatus2State extends State<AccountStatus2> {
  bool isMenuOpen = false;
  bool isSearchOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FullHeightContainer(),
      ),
    );
  }
}

class FullHeightContainer extends StatefulWidget {
  @override
  _FullHeightContainerState createState() => _FullHeightContainerState();
}

class _FullHeightContainerState extends State<FullHeightContainer> {
  String? selectedVendedor;

  Map valuesTransporter = {};
  bool showSearchSpace = false; // Por defecto, el TextField está oculto
  bool isMenuExpanded = false; // Para controlar la expansión de la lista

  double totalValoresRecibidos = 0;
  double costoDeEntregas = 0;
  double devoluciones = 0;
  double utilidad = 0;

  List<String> listvendedores = ['TODO'];
  TextEditingController searchController = TextEditingController();

  // var arrayfiltersDefaultAnd = [
  //   {"id_comercial": "74"}
  // ];
  var arrayfiltersDefaultAnd = [];
  // {"id_comercial": "74"}

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(
          () {}); // Refresca el widget cuando cambia el valor del TextEditingController
    });
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future loadData() async {
    try {
      // var responseValues =
      //     await Connections().getValuesSellerLaravelc2(arrayfiltersDefaultAnd);
      // valuesTransporter = responseValues['data'];
      // print(responseValues);
      // print(valuesTransporter);
      // calculateValues();

      if (listvendedores.length == 1) {
        var responsevendedores = await Connections().getVendedores();
        List<dynamic> vendedoresList = responsevendedores['vendedores'];
        for (var vendedor in vendedoresList) {
          listvendedores.add(vendedor);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  calculateValues() {
    totalValoresRecibidos = 0;
    costoDeEntregas = 0;
    devoluciones = 0;

    setState(() {
      totalValoresRecibidos =
          double.parse(valuesTransporter['totalValoresRecibidos'].toString());
      costoDeEntregas =
          double.parse(valuesTransporter['totalShippingCost'].toString());
      devoluciones =
          double.parse(valuesTransporter['totalCostoDevolucion'].toString());
      utilidad = (valuesTransporter['totalValoresRecibidos']) -
          (valuesTransporter['totalShippingCost'] +
              valuesTransporter['totalCostoDevolucion']);
      utilidad = double.parse(utilidad.toString());
      print(utilidad.toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double menuHeight = isMenuExpanded ? menuItems.length * 50.0 : 0.0;

    return Container(
      width: screenWidth,
      height: double.infinity,
      margin: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.0), // Margen superior de 10.0
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0)),
                    width: screenWidth * 0.2,
                    height: 50.0,
                    child: DropdownButton<String>(
                      value: selectedVendedor,
                      items: listvendedores
                          .where((vendedor) => vendedor
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase()))
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.split('-')[0]),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedVendedor = newValue;
                          var idComercial = newValue?.split('-').last;
                          arrayfiltersDefaultAnd = [{"id_comercial": idComercial}];
                          print(arrayfiltersDefaultAnd);
                          
                          _updateValuesBasedOnVendedor();
                        });
                      },
                      hint: Text('Selecciona un vendedor'),
                    )),
                SizedBox(width: 30),
                Container(
                  width: screenWidth * 0.10,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showSearchSpace =
                            !showSearchSpace; // Cambia el estado para mostrar u ocultar el TextField
                      });
                    },
                    child: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedOpacity(
                  opacity: showSearchSpace ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    width: screenWidth * 0.20,
                    height: 50.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                      child: Container(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width *
                0.6, // Hacer el ancho del contenedor dependiente del ancho de la pantalla
            margin: const EdgeInsets.only(top: 50.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedVendedor?.split('-').first ?? '',
                  style: TextStyle(
                    fontSize: max(
                        35,
                        MediaQuery.of(context).size.width *
                            0.03), // Hacer el tamaño de fuente dependiente del ancho de la pantalla
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                Icon(
                  Icons.store,
                  size: max(160, MediaQuery.of(context).size.width * 0.1),
                  color: Colors.blue,
                ),
                // SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                Text(
                  '\$100',
                  style: TextStyle(
                    fontSize: max(40, MediaQuery.of(context).size.width * 0.03),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '\$Utilidad: ${utilidad.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: max(40, MediaQuery.of(context).size.width * 0.03),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _updateValuesBasedOnVendedor() async {
  try {
    var responseValues = await Connections().getValuesSellerLaravelc2(arrayfiltersDefaultAnd);
    setState(() { // Ahora, actualiza el estado después de que hayas terminado la operación asíncrona
      valuesTransporter = responseValues['data'];
      print(valuesTransporter);
      calculateValues();
    });
  } catch (e) {
    print(e);
  }
}


}

final List<String> menuItems = [
  'Item 1',
  'Item 2',
  'Item 3',
  'Item 4', // Puedes añadir más elementos a la lista de ejemplo
];

@override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  return Container(
    width: screenWidth,
    height: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      border: Border.all(color: Colors.red, width: 2.0),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.5,
              height: 50.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2.0),
              ),
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(menuItems[index]));
                },
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: screenWidth * 0.15,
              height: 50.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2.0),
              ),
              child: ElevatedButton(
                onPressed: () {},
                child: Icon(Icons.arrow_downward),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: screenWidth * 0.15,
              height: 50.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2.0),
              ),
              child: ElevatedButton(
                onPressed: () {},
                child: Icon(Icons.search),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: screenWidth * 0.15,
              height: 50.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2.0),
              ),
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
