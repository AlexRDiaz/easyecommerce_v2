import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/add_provider.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/warehouses/addwarehouse.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
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
                      fontFamily: 'TuFuentePersonalizada',
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
                          color: ColorsSystem()
                              .colorBlack, // Usa un color claro como en la imagen
                          child: InkWell(
                            onTap: () => _showEditModal(warehouses[index]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceAround, // Distribuye el espacio de manera uniforme
                              children: <Widget>[
                                Expanded(
                                  child: Center(
                                    child: Icon(Icons.store,
                                        size: iconSize,
                                        color: Colors
                                            .white), // Icono de bodega centrado
                                  ),
                                ), // Esto empujará todo lo demás hacia abajo
                                Align(
                                  alignment: Alignment
                                      .bottomCenter, // Alinea el contenedor al final de la columna
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
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

  void _showEditModal(WarehouseModel warehouse) {
    TextEditingController _nameSucursalController =
        TextEditingController(text: warehouse.branchName);
    TextEditingController _addressController =
        TextEditingController(text: warehouse.address);
    TextEditingController _referenceController =
        TextEditingController(text: warehouse.reference);
    TextEditingController _descriptionController =
        TextEditingController(text: warehouse.description);
    // ... Agrega más controladores si tienes más campos

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double dialogWidth = MediaQuery.of(context).size.width * 0.3;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
              width: dialogWidth,
              padding: EdgeInsets.all(
                  20.0), // Ancho del 80% del ancho de la pantalla
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      const Text(
                        'Editar Bodega',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _controller.deleteWarehouse(warehouse.id!).then((_) {
                            Navigator.of(context).pop();
                            setState(() {
                              _futureWarehouseData = _loadWarehouses();
                              SnackBarHelper.showOkSnackBar(
                                  context, "BODEGA ELIMINADA.");
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // content:
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        TextFieldWithIcon(
                          controller: _nameSucursalController,
                          labelText: 'Nombre de bodega',
                          icon: Icons.store_mall_directory,
                        ),
                        SizedBox(height: 10),
                        TextFieldWithIcon(
                          controller: _addressController,
                          labelText: 'Dirección',
                          icon: Icons.place,
                        ),
                        SizedBox(height: 10),
                        TextFieldWithIcon(
                          controller: _referenceController,
                          labelText: 'Referencia',
                          icon: Icons.bookmark_border,
                        ),
                        SizedBox(height: 10),
                        TextFieldWithIcon(
                          controller: _descriptionController,
                          labelText: 'Descripción',
                          icon: Icons.description,
                        ),
                        SizedBox(height: 30),

                        // ... Agrega más TextFields para cada campo editable
                      ],
                    ),
                  ),
                  // actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Implementa la lógica de actualización aquí
                              _controller
                                  .updateWarehouse(
                                      warehouse.id!,
                                      _nameSucursalController.text,
                                      _addressController.text,
                                      _referenceController.text,
                                      _descriptionController.text)
                                  .then((_) {
                                Navigator.of(context).pop();
                                setState(() {
                                  // Esto forzará la reconstrucción de la vista con los datos actualizados
                                  _futureWarehouseData = _loadWarehouses();
                                  SnackBarHelper.showOkSnackBar(
                                      context, "DATOS ACTUALIZADOS.");
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsSystem()
                                  .colorSelectMenu, // Color del botón 'Aceptar'
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Aceptar'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Cierra el diálogo
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsSystem()
                                  .colorBlack, // Color del botón 'Cancelar'
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        );
      },
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
