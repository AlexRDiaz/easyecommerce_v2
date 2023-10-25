import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'dart:math';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';

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
  double valueTotalReturns = 0.0;

  List<String> listvendedores = ['TODO'];
  TextEditingController searchController = TextEditingController();
  var arrayfiltersDefaultAnd = [];

  @override
  void initState() {
    super.initState();
    loadData();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future loadData() async {
    try {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (selectedVendedor != null &&
        !listvendedores
            .where((vendedor) => vendedor
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .contains(selectedVendedor)) {
      selectedVendedor = null;
    }
    return responsive(
        Container(
          width: screenWidth,
          height: double.infinity,
          margin: const EdgeInsets.all(50.0),
          padding: const EdgeInsets.only(top: 20.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      width: screenWidth * 0.2,
                      height: 50.0,
                      padding: const EdgeInsets.only(top: 15.0, left: 5.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedVendedor,
                          items: listvendedores
                              .where((vendedor) => vendedor
                                  .toLowerCase()
                                  .contains(
                                      searchController.text.toLowerCase()))
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  const Icon(Icons.store, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(
                                    value.split('-')[0],
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 19, 50, 80),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              if (newValue != null &&
                                  listvendedores.contains(newValue)) {
                                selectedVendedor = newValue;
                                var idComercial = newValue.split('-').last;
                                arrayfiltersDefaultAnd = [
                                  {"id_comercial": idComercial}
                                ];
                                if (idComercial != "0") {
                                  _updateValuesBasedOnVendedor(idComercial);
                                }
                              }
                              searchController.clear();
                            });
                          },
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.grey),
                          selectedItemBuilder: (BuildContext context) {
                            return listvendedores.map((String value) {
                              return Text(value.split('-')[0]);
                            }).toList();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Container(
                      width: screenWidth * 0.10,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showSearchSpace = !showSearchSpace;
                          });
                        },
                        child: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(width: 30),
                    AnimatedOpacity(
                      opacity: showSearchSpace ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: screenWidth * 0.20,
                        height: 50.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(left: 2.0),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar...',
                                border: InputBorder.none,
                                suffixIcon: searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => setState(() {
                                          searchController.clear();
                                        }),
                                      )
                                    : null,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(bottom: 10.0, top: 10),
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.5,
                margin: const EdgeInsets.only(top: 50.0),
                alignment: Alignment.center,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        selectedVendedor?.split('-').first ?? '',
                        style: TextStyle(
                          fontSize:
                              max(30, MediaQuery.of(context).size.width * 0.03),
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 19, 50, 80),
                        ),
                      ),
                      Icon(
                        Icons.store,
                        size: max(140, MediaQuery.of(context).size.width * 0.1),
                        color: const Color.fromARGB(255, 52, 52, 53),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0, color: ColorsSystem().colorBlack),
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color.fromARGB(255, 19, 50, 80)),
                        child: Text(
                          '\$ ${(utilidad - valueTotalReturns).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: max(
                                40, MediaQuery.of(context).size.width * 0.03),
                            fontWeight: FontWeight.bold,
                            // color: const Color.fromARGB(255, 87, 87, 87),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          width: screenWidth,
          height: double.infinity,
          margin: const EdgeInsets.all(50.0),
          padding: const EdgeInsets.only(top: 20.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              // Dropdown Row
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      width: screenWidth * 0.6,
                      height: 50.0,
                      padding: const EdgeInsets.only(top: 15.0, left: 5.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedVendedor,
                          items: listvendedores
                              .where((vendedor) => vendedor
                                  .toLowerCase()
                                  .contains(
                                      searchController.text.toLowerCase()))
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  const Icon(Icons.store, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(value.split('-')[0]),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              if (newValue != null &&
                                  listvendedores.contains(newValue)) {
                                selectedVendedor = newValue;
                                var idComercial = newValue.split('-').last;
                                arrayfiltersDefaultAnd = [
                                  {"id_comercial": idComercial}
                                ];
                                if (idComercial != "0") {
                                  _updateValuesBasedOnVendedor(idComercial);
                                }
                              }
                              searchController.clear();
                            });
                          },
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.grey),
                          selectedItemBuilder: (BuildContext context) {
                            return listvendedores.map((String value) {
                              return Container(
                                child: Text(value.split('-')[0]),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: showSearchSpace ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: screenWidth * 0.4,
                        height: 50.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(left: 2.0),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar...',
                                border: InputBorder.none,
                                suffixIcon: searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => setState(() {
                                          searchController.clear();
                                        }),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: screenWidth * 0.19,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showSearchSpace = !showSearchSpace;
                          });
                        },
                        child: const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(bottom: 10.0, top: 10),
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.5,
                margin: const EdgeInsets.only(top: 50.0),
                alignment: Alignment.center,
                child: Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        selectedVendedor?.split('-').first ?? '',
                        style: TextStyle(
                          fontSize: max(
                              30,
                              MediaQuery.of(context).size.width *
                                  0.03), 
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 19, 50, 80),
                        ),
                      ),
                      Icon(
                        Icons.store,
                        size: max(140, MediaQuery.of(context).size.width * 0.1),
                        color: const Color.fromARGB(255, 52, 52, 53),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0, color: ColorsSystem().colorBlack),
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color.fromARGB(255, 19, 50, 80)),
                        child: Text(
                          '\$ ${(utilidad - valueTotalReturns).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: max(
                                40, MediaQuery.of(context).size.width * 0.03),
                            fontWeight: FontWeight.bold,
                            // color: const Color.fromARGB(255, 87, 87, 87),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        context);
  }

  Future<void> _updateValuesBasedOnVendedor(idSeller) async {
    try {
      var retvalTotal;
      var responseValues;

      if (idSeller != 0) {
        responseValues = await Connections()
            .getValuesSellerLaravelc2(arrayfiltersDefaultAnd);
        retvalTotal = await Connections().getOrdenesRetiroCount(idSeller);
      }
      setState(() {
        // Ahora, actualiza el estado después de que hayas terminado la operación asíncrona
        valuesTransporter = responseValues['data'];
        valueTotalReturns =
            double.parse(retvalTotal['total_retiros'].toString());
        calculateValues();
      });
    } catch (e) {
      print(e);
    }
  }
}
