import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/add_provider/layout_approve.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/product/product_info.dart';
import 'package:google_fonts/google_fonts.dart';

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
  int pageSize = 500;
  int pageCount = 100;
  bool isLoading = false;
  bool isFirst = false;
  List populate = ["warehouse.provider"];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = ["product_id", "product_name"];
  var sortFieldDefaultValue = "product_id:DESC";
  TextEditingController _search = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _warehouseController = WrehouseController();
    getWarehouses();
    _productController = ProductController();
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

  Future<List<ProductModel>> _getProductModelData() async {
    await _productController.loadProductsByProvider(
        widget.provider.id,
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        _search.text,
        "approve");
    // List<ProductModel> filteredProducts = _productController.products
    //     .where((product) => product.approved == 2)
    //     .toList();
    // return filteredProducts;
    return _productController.products;
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

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.provider.name.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bodega:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
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
                              "warehouse.warehouse_id": selectedWarehouse
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
                Expanded(child: Container()),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                    child:
                        _modelTextField(text: "Busqueda", controller: _search),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                          fontSize: 12,
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
                          size: ColumnSize.S,
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
                              Text(products[index]
                                  .warehouse!
                                  .branchName
                                  .toString()),
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
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            contentPadding: EdgeInsets.all(10),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.90,
              child: ProductInfo(
                product: product,
              ),
            ),
          );
        }).then((value) {});
  }
}
