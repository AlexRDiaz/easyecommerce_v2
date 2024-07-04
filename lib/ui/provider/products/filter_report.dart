import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/report_product.dart';
import 'package:frontend/ui/widgets/loading.dart';

class FilterReport extends StatefulWidget {
  const FilterReport({super.key});

  @override
  State<FilterReport> createState() => _FilterReportState();
}

class _FilterReportState extends State<FilterReport> {
  String idProv = sharedPrefs!.getString("idProvider").toString();
  String idProvUser = sharedPrefs!.getString("idProviderUserMaster").toString();
  String idUser = sharedPrefs!.getString("id").toString();
  int provType = 0;
  String specialProv = sharedPrefs!.getString("special").toString() == "null"
      ? "0"
      : sharedPrefs!.getString("special").toString();

  bool warehouseFilter = false;
  bool ownerFilter = false;

  var getReport = ReportProductos();
  List<String> ownersToSelect = [];
  String? selectedOwner;
  List<dynamic> andReport = [];
  List<dynamic> arrayFiltersNot = [];

  List<String> warehousesToSelect = [];
  String? selectedWarehouseReport;
  List<dynamic> ownersSelectedRep = [];
  List<dynamic> warehousesSelectedRep = [];

  List populate = ["warehouses", "reserve.seller", "owner"];
  int currentPage = 1;
  int pageSize = 1;
  int pageCount = 100;
  List<dynamic> warehousesSubProv = [];

  @override
  void initState() {
    // print("idProv-prin: $idProv-$idProvUser");
    // print("idProv: $idUser");
    if (idProvUser == idUser) {
      provType = 1; //prov principal
    } else if (idProvUser != idUser) {
      provType = 2; //sub principal
    }
    // print("tipo prov: $provType");
    // print("special prov?: $specialProv");

    super.initState();
    loadData();
    // getOwners();getWarehouses();
  }

  Future loadData() async {
    try {
      var responseSubWare = await Connections().getWarehousesSubProv(idUser);
      // print(responseSubWare);
      if (responseSubWare != []) {
        warehousesSubProv = responseSubWare;
      }
    } catch (e) {
      print(e);
    }
  }

  getOwners() async {
    try {
      getLoadingModal(context, false);

      var responseOwners = await Connections().getOwnersByProv(idProv);
      // print(responseOwners);
      for (var element in responseOwners) {
        ownersToSelect.add(
            "${element['warehouse_id']}|${element['owner']['id']}|${element['owner']['vendedores'][0]['nombre_comercial']}");
      }
      // print(ownersToSelect);
      if (provType == 2) {
        // print("Quitar seller según bodega de sub");
        List<String> filteredOwners = [];

        for (var element in ownersToSelect) {
          int idWareToSele = int.parse(element.split('|')[0]);

          bool keepElement = true;

          for (var warehouse in warehousesSubProv) {
            int warehouseId = warehouse["warehouse_id"];
            if (idWareToSele != warehouseId) {
              keepElement = false;
              break;
            }
          }

          if (keepElement) {
            filteredOwners.add(element);
          }
        }

        ownersToSelect = filteredOwners;
      }

      setState(() {});
      Navigator.pop(context);
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  getWarehouses() async {
    try {
      getLoadingModal(context, false);

      var responseWarehouses = await Connections().getWarehousesByProv(idProv);
      // print(responseWarehouses);

      for (var element in responseWarehouses) {
        warehousesToSelect
            .add("${element['warehouse_id']}|${element['branch_name']}");
      }

      if (provType == 2) {
        // print("quitar seller segun bodega de sub");
      }
      Navigator.pop(context);

      setState(() {});
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    return Container(
      padding: const EdgeInsets.all(20),
      width: 500,
      height: 500,
      child: Column(
        children: [
          const Text(
            "Seleccione filtros",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Bodega',
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          warehouseFilter = !warehouseFilter;
                          if (warehouseFilter = true) {
                            ownerFilter = false;
                            ownersSelectedRep = [];
                            getWarehouses();
                          } else {
                            ownerFilter = true;
                          }
                        });
                      },
                      backgroundColor:
                          warehouseFilter ? Colors.blue : Colors.white,
                      child: Icon(
                        Icons.warehouse,
                        color: warehouseFilter ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Productos Propios',
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          ownerFilter = !ownerFilter;
                          if (ownerFilter = true) {
                            warehouseFilter = false;
                            warehousesSelectedRep = [];
                            getOwners();
                          } else {
                            warehouseFilter = true;
                          }
                        });
                      },
                      backgroundColor:
                          ownerFilter ? Colors.green : Colors.white,
                      child: Icon(
                        Icons.person,
                        color: ownerFilter ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          Visibility(
            visible: warehouseFilter,
            child: SizedBox(
              width: 350,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                hint: Text(
                  'Bodega',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                items: warehousesToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split("|")[1].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
                value: selectedWarehouseReport,
                onChanged: (value) {
                  setState(() {
                    selectedWarehouseReport = value as String;
                    if (!warehousesSelectedRep
                        .contains(selectedWarehouseReport)) {
                      warehousesSelectedRep.add(selectedWarehouseReport);
                    }
                  });
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
          const SizedBox(height: 5),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(warehousesSelectedRep.length, (index) {
              String warehouse = warehousesSelectedRep[index];
              String name = warehouse.split("|")[1];

              return Chip(
                label: Text(name),
                onDeleted: () {
                  setState(() {
                    warehousesSelectedRep.removeAt(index);
                  });
                },
              );
            }),
          ),
          Visibility(
            visible: ownerFilter,
            child: SizedBox(
              width: 350,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                hint: Text(
                  'Propietario',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                items: ownersToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split("|")[2].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
                value: selectedOwner,
                onChanged: (value) {
                  setState(() {
                    selectedOwner = value as String;
                    if (!ownersSelectedRep.contains(selectedOwner)) {
                      ownersSelectedRep.add(selectedOwner);
                    }
                  });
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
          const SizedBox(height: 5),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(ownersSelectedRep.length, (index) {
              String owner = ownersSelectedRep[index];
              String ownerName = owner.split("|")[2];

              return Chip(
                label: Text(ownerName),
                onDeleted: () {
                  setState(() {
                    ownersSelectedRep.removeAt(index);
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {
                  //
                  getLoadingModal(context, false);
                  Stopwatch stopwatch = Stopwatch();
                  stopwatch.start();

                  andReport = [];
                  if (provType == 1) {
                    andReport.add({"equals/warehouses.provider_id": idProv});
                  } else if (provType == 2) {
                    andReport
                        .add({"equals/warehouses.up_users.id_user": idUser});
                  }

                  List<dynamic> multifilter = [];
                  // print(ownersSelectedRep);
                  // print(warehousesSelectedRep);

                  if (warehouseFilter) {
                    for (var warehouse in warehousesSelectedRep) {
                      multifilter.add(
                          {"warehouse_id": warehouse.toString().split('-')[0]});
                    }
                    andReport.add({"/seller_owned": null});
                  }

                  if (ownerFilter) {
                    for (var owner in ownersSelectedRep) {
                      multifilter.add(
                          {"seller_owned": owner.toString().split('|')[1]});
                    }
                    arrayFiltersNot.add({"seller_owned": null});
                  }

                  var dataProducts = await Connections()
                      .getProductsBySubProvider(
                          populate,
                          null,
                          currentPage,
                          [],
                          andReport,
                          "product_id:DESC",
                          "",
                          arrayFiltersNot,
                          multifilter);
                  // print(dataProducts['data']);
                  //  print(dataProducts['total']);

                  // getReport.generateExcelReport(dataProducts['data']);
                  // print(dataProducts['data']);

                  // getReport.generateProductDetails(dataProducts['data']);
                  if (ownerFilter) {
                    getReport.generateProductDetails(dataProducts, "owner");
                  } else {
                    //
                    getReport.generateProductDetails(dataProducts, "");
                  }

                  stopwatch.stop();
                  Duration duration = stopwatch.elapsed;
                  print(
                      'La función tardó ${duration.inMilliseconds} milisegundos en ejecutarse.');
                  Navigator.pop(context);
                  // Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    Text(
                      "Descargar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
