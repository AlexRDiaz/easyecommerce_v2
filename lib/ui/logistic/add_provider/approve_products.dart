import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/add_provider/layout_approve.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/product/product_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ApproveProducts extends StatefulWidget {
  final ProviderModel provider;

  const ApproveProducts({super.key, required this.provider});

  @override
  State<ApproveProducts> createState() => _ApproveProductsState();
}

class _ApproveProductsState extends State<ApproveProducts> {
  late ProductController _productController;
  List<ProductModel> products = [];
  late WrehouseController _warehouseController;
  List<WarehouseModel> warehousesList = [];
  List<String> warehousesToSelect = [];
  String? selectedWarehouse;

  int currentPage = 1;
  int pageSize = 1500;
  int pageCount = 100;
  bool isLoading = false;
  bool isFirst = false;
  // List populate = ["warehouse.provider"];
  List populate = ["warehouses"];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = ["product_id", "product_name"];
  var sortFieldDefaultValue = "product_id:DESC";
  TextEditingController _search = TextEditingController(text: "");

  List<String> specialsToSelect = [];
  String? selectedSpecial;
  int total = 0;

  bool _selectAll = false;
  List<int> selectedProductIds = [];

  @override
  void initState() {
    super.initState();
    _warehouseController = WrehouseController();
    getWarehouses();
    getSpecialsWarehouses();
    _productController = ProductController();
    _getProductModelData();
  }

  Future<List<WarehouseModel>> _getWarehousesData() async {
    await _warehouseController.loadWarehouses(widget.provider.id.toString());
    List<WarehouseModel> filteredWarehouses = _warehouseController.warehouses
        .where((warehouse) => warehouse.active == 1 && warehouse.approved == 1)
        .toList();
    return filteredWarehouses;
  }

  getWarehouses() async {
    var responseBodegas = await _getWarehousesData();
    warehousesList = responseBodegas;
    warehousesToSelect.insert(0, '0-TODO');
    for (var provider in responseBodegas) {
      setState(() {
        warehousesToSelect.add('${provider.id}-${provider.branchName}');
      });
    }
  }

  _getProductModelData() async {
    //prov principal y especial
    // arrayFiltersAnd.add({"/approved": 2});
    arrayFiltersAnd.add({"/warehouses.provider_id": widget.provider.id});

    // await _productController.loadProductsByProvider(
    //     widget.provider.id,
    //     populate,
    //     pageSize,
    //     currentPage,
    //     arrayFiltersOr,
    //     arrayFiltersAnd,
    //     sortFieldDefaultValue.toString(),
    //     _search.text,
    //     "approve");
    // List<ProductModel> filteredProducts = _productController.products
    //     .where((product) => product.approved == 2)
    //     .toList();
    // return filteredProducts;

    //new version
    setState(() {
      isLoading = true;
    });
    await _productController.loadBySubProvider(
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        _search.text, []);
    // return _productController.products;
    setState(() {
      products = _productController.products;
      isLoading = false;
    });
  }

  //SpecialsWarehouses
  getSpecialsWarehouses() async {
    var data = await Connections().getSpecialsWarehouses();
    // print("all specials: $data");
    for (var bodega in data) {
      specialsToSelect.add(
          "${bodega['warehouse_id']}-${bodega['branch_name']}/${bodega['city']}");
    }
    setState(() {
      specialsToSelect = specialsToSelect;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    TextStyle customTextStyleTitle = GoogleFonts.dmSerifDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );

    TextStyle customTextStyleText = GoogleFonts.dmSans(
      fontSize: 17,
      color: Colors.black,
    );

    void approveSelectedProducts() {
      final selectedIds = selectedProductIds;
      print('IDs seleccionados para aprobar: $selectedIds');
      for (var selectId in selectedIds) {
        _productController.upate(selectId, {"approved": 1});
      }
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                child: LayoutApprovePage(
                    provider: widget.provider, currentV: "Productos"),
              ),
            );
          }).then((value) {});

      // _getProductModelData();
    }

    void alert() {
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Debe seleccionar productos previamente',
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnOkOnPress: () {},
      ).show();
    }

    void _selectApprovedProducts() {
      setState(() {
        _selectAll = !_selectAll;
        for (var product in products) {
          if (product.approved == 2) {
            product.isSelected = _selectAll;
          }
        }
      });
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.provider.name.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Bodega:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(5),
                child: Row(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: Text(
                          'TODO',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        items: warehousesToSelect.map((item) {
                          var parts = item.split('-');
                          var branchName = parts[1];
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              '$branchName',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        value: selectedWarehouse,
                        onChanged: (value) {
                          setState(() {
                            selectedWarehouse = value;
                          });

                          if (value != 'TODO') {
                            if (value is String) {
                              arrayFiltersAnd = [];
                              arrayFiltersAnd.add({
                                "/warehouses.warehouse_id": selectedWarehouse
                                    .toString()
                                    .split("-")[0]
                                    .toString()
                              });
                            }
                          } else {
                            arrayFiltersAnd = [];
                          }

                          setState(() {});
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.green)),
                    onPressed: selectedProductIds.isEmpty
                        ? alert
                        : approveSelectedProducts,
                    child: const Text('Actualizar Estados'),
                  ),
                ])),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.6,
                    child:
                        _modelTextField(text: "Busqueda", controller: _search),
                  ),
                  const SizedBox(width: 20),
                  Text("Regitros: ${products.length.toString()}"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: DataTable2(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Colors.blueGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dataRowColor: MaterialStateColor.resolveWith((states) {
                  return Colors.white;
                }),
                headingTextStyle: const TextStyle(
                    // fontWeight: FontWeight.bold,
                    color: Colors.black),
                dataTextStyle: const TextStyle(
                    fontSize: 13,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black),
                columnSpacing: 12,
                columns: [
                  DataColumn2(
                    label: Checkbox(
                      activeColor: Colors.green,
                      value: _selectAll,
                      onChanged: (bool? value) {
                        setState(() {
                          _selectAll = value ?? false;
                          if (_selectAll) {
                            selectedProductIds = products
                                .where((product) => product.approved == 2)
                                .map((product) =>
                                    int.parse(product.productId.toString()))
                                .toList();
                          } else {
                            selectedProductIds.clear();
                          }
                        });
                      },
                    ),
                    size: ColumnSize.S,
                  ),
                  const DataColumn2(
                    label: Text('Creado'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: const Text('ID'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      // Lógica para ordenar
                    },
                  ),
                  DataColumn2(
                    label: const Text('Bodega'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      // Lógica para ordenar
                    },
                  ),
                  DataColumn2(
                    label: const Text('Nombre'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) {
                      // Lógica para ordenar
                    },
                  ),
                  DataColumn2(
                    label: const Text('Aprobado'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      // Lógica para ordenar
                    },
                  ),
                  DataColumn2(
                    label: const Text(''), //btn
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // Lógica para ordenar
                    },
                  ),
                  DataColumn2(
                    label: const Text(''), //btn
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) {
                      // Lógica para ordenar
                    },
                  ),
                ],
                rows: List<DataRow>.generate(
                  products.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(
                        products[index].approved == 2
                            ? Checkbox(
                                value: selectedProductIds
                                    .contains(products[index].productId),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedProductIds.add(int.parse(
                                          products[index]
                                              .productId
                                              .toString()));
                                    } else {
                                      selectedProductIds
                                          .remove(products[index].productId);
                                    }
                                    _selectAll = products
                                        .where(
                                            (product) => product.approved == 2)
                                        .map((product) => product.productId)
                                        .every((id) =>
                                            selectedProductIds.contains(id));
                                  });
                                },
                              )
                            : Container(),
                      ),
                      DataCell(
                        Text(UIUtils.formatDate(
                            products[index].createdAt.toString())),
                      ),
                      DataCell(
                        Text(products[index].productId.toString()),
                        onTap: () {
                          showProductInfoDialog(products[index]);
                        },
                      ),
                      DataCell(
                        Text(getWarehousesNamesModel(products[index].warehouses)
//                                 products[index]
//                                   .warehouse!
//                                   .branchName
//                                   .toString(),
                            ),
                        onTap: () {
                          showProductInfoDialog(products[index]);
                        },
                      ),
                      DataCell(
                        Text(products[index].productName.toString()),
                        onTap: () {
                          showProductInfoDialog(products[index]);
                        },
                      ),
                      DataCell(
                        Text(
                          products[index].approved == 1
                              ? 'Aprobado'
                              : products[index].approved == 2
                                  ? 'Pendiente'
                                  : products[index].approved == 3
                                      ? 'Suspendido'
                                      : 'Rechazado',
                          style: TextStyle(
                            color: products[index].approved == 1
                                ? Colors.green
                                : products[index].approved == 2
                                    ? Colors.indigo.shade600
                                    : products[index].approved == 3
                                        ? Colors.orange
                                        : Colors.red,
                          ),
                        ),
                      ),
                      DataCell(
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          elevation: 10,
                          child: Row(
                            children: [
                              Text(
                                "Cambiar Estado",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue.shade700),
                              ),
                            ],
                          ),
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                child: Text(
                                  "Aprobar",
                                ),
                                value: "approve",
                              ),
                              PopupMenuItem<String>(
                                child: Row(
                                  children: [
                                    Text("Rechazar"),
                                  ],
                                ),
                                value: "reject",
                              ),
                              PopupMenuItem<String>(
                                child: Row(
                                  children: [
                                    Text("Suspender"),
                                  ],
                                ),
                                value: "suspend",
                              ),
                            ];
                          },
                          onSelected: (value) async {
                            //
                            if (value == "approve") {
                              _productController.upate(
                                  int.parse(
                                      products[index].productId.toString()),
                                  {"approved": 1});

                              Navigator.pop(context);
                            } else if (value == "reject") {
                              _productController.upate(
                                  int.parse(
                                      products[index].productId.toString()),
                                  {"approved": 0});

                              Navigator.pop(context);
                            } else if (value == "suspend") {
                              _productController.upate(
                                  int.parse(
                                      products[index].productId.toString()),
                                  {"approved": 3});

                              Navigator.pop(context);
                            }

                            return showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.95,
                                      child: LayoutApprovePage(
                                          provider: widget.provider,
                                          currentV: "Productos"),
                                    ),
                                  );
                                }).then((value) {});

                            //
                          },
                        ),

                        /*
                              ElevatedButton(
                                onPressed: () async {
                                  //
                                  _productController.upate(
                                      int.parse(
                                          products[index].productId.toString()),
                                      {
                                        "approved":
                                            products[index].approved != 1
                                                ? 1
                                                : 0
                                      });
                                  Navigator.pop(context);

                                  return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                0.0), // Establece el radio del borde a 0
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.95,
                                            child: LayoutApprovePage(
                                              provider: widget.provider,
                                              currentV: "Productos",
                                            ),
                                          ),
                                        );
                                      }).then((value) {}); //
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: products[index].approved != 1
                                      ? Colors.green
                                      : Colors.red[400],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      products[index].approved != 1
                                          ? "Aprobar"
                                          : "Rechazar",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            */
                      ),
                      DataCell(
                        Center(
                          child: TextButton(
                            onPressed: () {
                              //
                              showAddToWarehouse(context, products[index]);
                            },
                            child: Text(
                              "Añadir a Bodega",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          // showProductInfoDialog(products[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            /*
            Expanded(
              child: FutureBuilder(
                future: _getProductModelData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar productos'));
                  } else {
                    List<ProductModel> products = snapshot.data ?? [];
                    return DataTable2(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(color: Colors.blueGrey),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      dataRowColor: MaterialStateColor.resolveWith((states) {
                        return Colors.white;
                      }),
                      headingTextStyle: const TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Colors.black),
                      dataTextStyle: const TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black),
                      columnSpacing: 12,
                      columns: [
                        const DataColumn2(
                          label: Text('Creado'),
                          size: ColumnSize.M,
                        ),
                        DataColumn2(
                          label: const Text('ID'),
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Bodega'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Nombre'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Aprobado'),
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text(''), //btn
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text(''), //btn
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        products.length,
                        (index) => DataRow(
                          cells: [
                            DataCell(
                              Text(UIUtils.formatDate(
                                  products[index].createdAt.toString())),
                            ),
                            DataCell(
                              Text(products[index].productId.toString()),
                              onTap: () {
                                showProductInfoDialog(products[index]);
                              },
                            ),
                            DataCell(
                              Text(getWarehousesNamesModel(
                                      products[index].warehouses)
//                                 products[index]
//                                   .warehouse!
//                                   .branchName
//                                   .toString(),
                                  ),
                              onTap: () {
                                showProductInfoDialog(products[index]);
                              },
                            ),
                            DataCell(
                              Text(products[index].productName.toString()),
                              onTap: () {
                                showProductInfoDialog(products[index]);
                              },
                            ),
                            DataCell(
                              Text(
                                products[index].approved == 1
                                    ? 'Aprobado'
                                    : products[index].approved == 2
                                        ? 'Pendiente'
                                        : products[index].approved == 3
                                            ? 'Suspendido'
                                            : 'Rechazado',
                                style: TextStyle(
                                  color: products[index].approved == 1
                                      ? Colors.green
                                      : products[index].approved == 2
                                          ? Colors.indigo.shade600
                                          : products[index].approved == 3
                                              ? Colors.orange
                                              : Colors.red,
                                ),
                              ),
                            ),
                            DataCell(
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                elevation: 10,
                                child: Row(
                                  children: [
                                    Text(
                                      "Cambiar Estado",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue.shade700),
                                    ),
                                  ],
                                ),
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem<String>(
                                      child: Text(
                                        "Aprobar",
                                      ),
                                      value: "approve",
                                    ),
                                    PopupMenuItem<String>(
                                      child: Row(
                                        children: [
                                          Text("Rechazar"),
                                        ],
                                      ),
                                      value: "reject",
                                    ),
                                    PopupMenuItem<String>(
                                      child: Row(
                                        children: [
                                          Text("Suspender"),
                                        ],
                                      ),
                                      value: "suspend",
                                    ),
                                  ];
                                },
                                onSelected: (value) async {
                                  //
                                  if (value == "approve") {
                                    _productController.upate(
                                        int.parse(products[index]
                                            .productId
                                            .toString()),
                                        {"approved": 1});

                                    Navigator.pop(context);
                                  } else if (value == "reject") {
                                    _productController.upate(
                                        int.parse(products[index]
                                            .productId
                                            .toString()),
                                        {"approved": 0});

                                    Navigator.pop(context);
                                  } else if (value == "suspend") {
                                    _productController.upate(
                                        int.parse(products[index]
                                            .productId
                                            .toString()),
                                        {"approved": 3});

                                    Navigator.pop(context);
                                  }

                                  return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.95,
                                            child: LayoutApprovePage(
                                                provider: widget.provider,
                                                currentV: "Productos"),
                                          ),
                                        );
                                      }).then((value) {});
                                  //
                                },
                              ),

                              /*
                              ElevatedButton(
                                onPressed: () async {
                                  //
                                  _productController.upate(
                                      int.parse(
                                          products[index].productId.toString()),
                                      {
                                        "approved":
                                            products[index].approved != 1
                                                ? 1
                                                : 0
                                      });
                                  Navigator.pop(context);

                                  return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                0.0), // Establece el radio del borde a 0
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.95,
                                            child: LayoutApprovePage(
                                              provider: widget.provider,
                                              currentV: "Productos",
                                            ),
                                          ),
                                        );
                                      }).then((value) {}); //
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: products[index].approved != 1
                                      ? Colors.green
                                      : Colors.red[400],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      products[index].approved != 1
                                          ? "Aprobar"
                                          : "Rechazar",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            */
                            ),
                            DataCell(
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    //
                                    showAddToWarehouse(
                                        context, products[index]);
                                  },
                                  child: Text(
                                    "Añadir a Bodega",
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                // showProductInfoDialog(products[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          
          */
          ],
        ),
      ),
    );
  }

  String getWarehousesNamesModel(warehouses) {
    String names = "";
    List<WarehouseModel>? warehousesList = warehouses;

    if (warehousesList != null) {
      for (WarehouseModel warehouse in warehousesList) {
        names += "${warehouse.branchName}/ ";
      }
    }
    if (names.isNotEmpty) {
      names = names.substring(0, names.length - 2);
    }
    return names;
  }

  Future<dynamic> showAddToWarehouse(
      BuildContext context, ProductModel product) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: Container(
                padding: EdgeInsets.all(20),
                width: 500,
                height: 300,
                child: Column(
                  children: [
                    const Text(
                      "Añadir a bodega",
                      style: TextStyle(
                          // fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                            "Producto: ${product.productId.toString()}-${product.productName}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 300,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              hint: Text(
                                'TODO',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              items: specialsToSelect.map((item) {
                                var parts = item.split('-');
                                var branchName = parts[1];
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    branchName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: selectedSpecial,
                              onChanged: (value) {
                                setState(() {
                                  selectedSpecial = value;
                                });

                                setState(() {});
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        //
                        // print(
                        //     "${selectedSpecial.toString().split("-")[0].toString()}");

                        var response = await Connections().newProductWarehouse(
                            product.productId.toString(),
                            selectedSpecial
                                .toString()
                                .split("-")[0]
                                .toString());
                        print(response);
                        if (response != 0) {
                          // ignore: use_build_context_synchronously
                          showSuccessModal(
                              context,
                              "Ocurrió un error durante la solicitud.",
                              Icons8.warning_1);
                        }
                        Navigator.pop(context);
                      },
                      child: Text("Añadir"),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) => setState(() {
          // loadData();
        }));
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // getOldValue(true);
          setState(() {
            _search.text = value;
          });
          getLoadingModal(context, false);

          setState(() {});
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        },
        decoration: InputDecoration(
          labelText: 'Buscar producto',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _search.clear();
                      arrayFiltersAnd = [];
                    });

                    // resetFilters();
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close))
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

  showProductInfoDialog(product) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              //
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                contentPadding: EdgeInsets.all(0),
                content: ProductInfo(
                  product: product,
                ),
              );
            },
          );
        }).then((value) {});
  }
}
