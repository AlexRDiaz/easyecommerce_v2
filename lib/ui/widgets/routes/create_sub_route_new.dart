import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';

class CreateSubRouteNew extends StatefulWidget {
  final String idCarrier;
  const CreateSubRouteNew({super.key, required this.idCarrier});

  @override
  State<CreateSubRouteNew> createState() => _CreateSubRouteNewState();
}

class _CreateSubRouteNewState extends State<CreateSubRouteNew> {
  bool isLoading = false;
  List<String> routesToSelect = [];
  String? selectedValueRoute;
  TextEditingController _nameSubRoute = TextEditingController();

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      var routesList = [];
      setState(() {
        routesToSelect = [];
      });
      var response = await Connections().getRoutesByCarrier(widget.idCarrier);
      // print(response);
      routesList = response['rutas'];
      for (var i = 0; i < routesList.length; i++) {
        setState(() {
          routesToSelect.add('${routesList[i]}');
        });
      }

      // print(data);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print("error!!!:  $e");

      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWith > 600 ? screenWith * 0.3 : screenWith,
      height: screenHeight * 0.5,
      color: Colors.white,
      child: CustomProgressModal(
        isLoading: isLoading,
        content: ListView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Ruta',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold),
                    ),
                    items: routesToSelect
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item.split('-')[0],
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                    value: selectedValueRoute,
                    onChanged: (value) async {
                      setState(() {
                        selectedValueRoute = value as String;
                        // print(selectedValueRoute);
                      });
                    },

                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        _nameSubRoute.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameSubRoute,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                      hintText: "Titulo",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: selectedValueRoute == null
                      ? null
                      : () async {
                          //
                          var response = await Connections().createRouteLaravel(
                              widget.idCarrier,
                              selectedValueRoute.toString().split("-")[1],
                              _nameSubRoute.text);

                          if (response != 0) {
                            // ignore: use_build_context_synchronously
                            showSuccessModal(
                                context,
                                "Error, no se ha podido crear la ruta.",
                                Icons8.warning_1);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      ColorsSystem().mainBlue,
                    ),
                  ),
                  child: const Text(
                    "ACEPTAR",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
