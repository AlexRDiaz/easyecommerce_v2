import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/carriers_external/add_carrier_external.dart';
import 'package:frontend/ui/logistic/carriers_external/carriers_external_general.dart';
import 'package:frontend/ui/logistic/carriers_external/info_carrier_external.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';

class CarriersExternalView extends StatefulWidget {
  const CarriersExternalView({super.key});

  @override
  State<CarriersExternalView> createState() => _CarriersExternalViewState();
}

class _CarriersExternalViewState extends State<CarriersExternalView> {
  bool isLoading = false;
  var data = [];

  List populate = [];
  List arrayFiltersOr = ["name", "phone", "email", "address"];
  TextEditingController searchController = TextEditingController(text: "");

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

      //

      data = await Connections()
          .getCarriersExternal(arrayFiltersOr, searchController.text);

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

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            //
            showCreateOperator(context);
          },
          backgroundColor: Colors.green,
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: _modelTextField(
                            text: "Buscar", controller: searchController),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          //
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarriersExternalGeneral(),
                            ),
                          );
                        },
                        child: const Text(
                          "Coberturas Generales",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              /*
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                color: Colors.amber,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Número de tarjetas por fila
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        color: Colors.blue.shade100,
                        child: InkWell(
                          onTap: () {
                            showInfo(context, data[index]);
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                // SizedBox(
                                //   height: screenHeight * 0.1,
                                //   width: screenWith * 0.1,
                                //   child: Container(
                                //     color: Colors.deepPurple.shade100,
                                //   ),
                                // ),
                                Text(data[index]['name']),
                                Text(data[index]['phone']),
                                Text(data[index]['email']),
                                Text(data[index]['address']),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
*/
              // Container(
              //   height: MediaQuery.of(context).size.height * 0.50,
              //   child: Container(
              //     padding: EdgeInsets.all(5),
              //     child: ListView.builder(
              //       itemCount: data.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         return Card(
              //           color: Colors.blue.shade100,
              //           child: InkWell(
              //             onTap: () {
              //               showInfo(context);
              //             },
              //             child: Container(
              //               padding: EdgeInsets.all(10),
              //               child: Column(
              //                 children: [
              //                   SizedBox(
              //                     height: screenHeight * 0.1,
              //                     width: screenWith * 0.1,
              //                     child: Container(
              //                       color: Colors.deepPurple.shade100,
              //                     ),
              //                   ),
              //                   Text(data[index]['name']),
              //                   Text(data[index]['phone']),
              //                   Text(data[index]['email']),
              //                   Text(data[index]['address']),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ),

              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                // color: Colors.cyan,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      data.length,
                      (index) => Card(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            //
                            showInfo(context, data[index]);
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: screenWith * 0.22,
                            child: Column(
                              children: [
                                // SizedBox(
                                //   height: screenHeight * 0.1,
                                //   width: screenWith * 0.1,
                                //   child: Container(
                                //     color: Colors.deepPurple.shade100,
                                //   ),
                                // ),
                                Text(data[index]['name']),
                                Text(data[index]['phone']),
                                Text(data[index]['email']),
                                Text(data[index]['address']),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: searchController,
        onSubmitted: (value) {
          loadData();
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    searchController.clear();
                    loadData();
                  },
                  child: Icon(Icons.close))
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

  Future<dynamic> showCreateOperator(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return const AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: AddCarrierExternal(),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }

  Future<dynamic> showInfo(BuildContext context, data) {
    // print(data);
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
              content: InfoCarrierExternal(data: data),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }
}
