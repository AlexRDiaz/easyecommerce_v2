import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/add_provider.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/warehouses/addwarehouse.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/provider/warehouses/editwarehouse.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class WarehousesView extends StatefulWidget {
  const WarehousesView({super.key});
  @override
  _WarehousesViewState createState() => _WarehousesViewState();
}

class _WarehousesViewState extends StateMVC<WarehousesView> {
  late WrehouseController _controller;
  late TextEditingController _searchController;
  late Future<List<WarehouseModel>> _futureWarehouseData;

  List<dynamic> activeRoutes = [];
  List<dynamic> secondDropdownOptions = [];
  List<String> formattedList = [];
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _trnasportController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller = WrehouseController();
    _searchController = TextEditingController();
    _futureWarehouseData = _loadWarehouses();

    _searchController.addListener(() {
      setState(() {
        _futureWarehouseData = _loadWarehouses(_searchController.text);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData().then((_) {
      setState(() {});
    });
  }

  Future loadData() async {
    if (activeRoutes.isEmpty) {
      activeRoutes = await Connections().getActiveRoutes();
    }
  }

  Future<List<WarehouseModel>> _loadWarehouses([String query = '']) async {
    await _controller.loadWarehouses();
    if (query.isEmpty) {
      return _controller.warehouses;
    } else {
      return _controller.warehouses.where((warehouse) {
        // Puedes ajustar los criterios de búsqueda según tus necesidades
        return warehouse.branchName!
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<dynamic> openDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: const AddWarehouse(),
            ),
          );
        }).then((value) => setState(() {
          _futureWarehouseData = _loadWarehouses(); // Actualiza el Future
        }));
  }

  Future<dynamic> openDialogE(BuildContext context, WarehouseModel warehousen) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: EditWarehouse(
                warehouse: warehousen,
              ),
            ),
          );
        }).then((value) => setState(() {
          _futureWarehouseData = _loadWarehouses(); // Actualiza el Future
        }));
  }

  String mapNumbersToDays(List<dynamic> numbers) {
    Map<int, String> daysMap = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
    };

    List<String?> days = numbers.map((number) {
      return (number >= 1 && number <= 5) ? daysMap[number] : null;
    }).toList();

    // Filtra los días válidos y los une con '-'
    return days.where((day) => day != null).join('-');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSize =
        screenWidth > 600 ? 22 : 12; // Ejemplo de ajuste basado en el ancho
    double iconSize =
        screenWidth > 600 ? 70 : 25; // Ejemplo de ajuste basado en el ancho

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar bodega',
                      prefixIcon: Icon(Icons.search,
                          color: ColorsSystem().colorSelectMenu),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    height:
                        50, // Altura del botón (ajusta según la altura de tu TextField)
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => openDialog(context),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      "Agregar Bodega",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsSystem().colorSelectMenu,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _futureWarehouseData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar bodegas'));
                } else {
                  List<WarehouseModel> warehouses = snapshot.data ?? [];
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.builder(
                      itemCount: warehouses.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.8,
                      ),
                      itemBuilder: (context, index) {
                        WarehouseModel warehouse = warehouses[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 10,
                          color: ColorsSystem().colorBlack,
                          child: InkWell(
                            onTap: () => openDialogE(context, warehouse),
                            child: Stack(
                              children: [
                                // Imagen o icono principal
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: warehouses[index].url_image != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: Image.network(
                                            "$generalServer${warehouses[index].url_image}",
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            (loadingProgress
                                                                    .expectedTotalBytes ??
                                                                1)
                                                        : null,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        )
                                      : Icon(Icons.store,
                                          size: iconSize, color: Colors.white),
                                ),
                                // Icono de check verde en la esquina superior izquierda
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: warehouses[index].active == 1
                                      ? Icon(
                                          Icons.check,
                                          color: const Color.fromARGB(
                                              255, 45, 228, 51),
                                          size: 20,
                                        )
                                      : Icon(
                                          Icons.lock,
                                          color: Colors
                                              .red,
                                          size: 20,
                                        ),
                                ),

                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: warehouses[index].active == 1
                                          ? ColorsSystem().colorSelectMenu
                                          : Colors.grey,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    width: double.infinity,
                                    child: Text(
                                      warehouse.branchName ?? 'Sin nombre',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize: textSize,
                                        fontFamily: 'Arial',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TextFieldWithIcon extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;

  const TextFieldWithIcon({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: ColorsSystem().colorSelectMenu),
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        style: const TextStyle(fontFamily: 'Arial', color: Colors.black),
      ),
    );
  }
}
