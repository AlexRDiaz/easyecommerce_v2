import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';

class AddCarrierLaravelModal extends StatefulWidget {
  const AddCarrierLaravelModal({super.key});

  @override
  State<AddCarrierLaravelModal> createState() => _AddCarrierModalLaravelState();
}

class _AddCarrierModalLaravelState extends State<AddCarrierLaravelModal> {
  TextEditingController _usuario = TextEditingController();
  TextEditingController _correo = TextEditingController();
  TextEditingController _costo = TextEditingController();
  TextEditingController _telefono = TextEditingController();
  TextEditingController _telefono2 = TextEditingController();
  List<String> routes = [];
  List<String> selectedItems = [];
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getLoadingModal(context, false);
    // });
    isLoading = true;
    var routesList = [];
    setState(() {
      routes.clear();
    });

    routesList = await Connections().getActiveRoutes();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        routes.add('${routesList[i]}');
      });
    }

    isLoading = false;
    // Future.delayed(Duration(milliseconds: 500), () {
    //   Navigator.pop(context);
    // });
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
        isLoading: isLoading,
        content: AlertDialog(
          content: SizedBox(
            width: 500,
            height: 550,
            child: ListView(
              children: [
                responsive(webContainer(context), webContainer(context), context),
              ],
            ),
          ),
        ));
  }

  Column webContainer(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Asegura que los hijos de la Row se distribuyan al inicio y al final
          children: [
            Text(
              "Registro de Transportista",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(), // Inserta un Spacer aquí
            Align(
              alignment: Alignment
                  .centerRight, // Corrige el alineamiento aquí si es necesario, aunque puede no ser necesario con el uso de Spacer
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        TextField(
          controller: _usuario,
          decoration: InputDecoration(
            hintText: "Usuario",
            prefixIcon: Icon(Icons.person_outline, color: Colors.deepPurple),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _correo,
          decoration: InputDecoration(
            hintText: "Correo",
            prefixIcon: Icon(Icons.email_outlined, color: Colors.orange),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _costo,
          decoration: InputDecoration(
            hintText: "Costo",
            prefixIcon: Icon(Icons.attach_money, color: Colors.green),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextButton(
            onPressed: () async {
              // Navigator.pop(context);
              await showDialog(
                  context: context,
                  builder: (context) {
                    return AddRoute();
                  });
              // await loadData();
            },
            child: Text(
              "AGREGAR",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            )),
        SizedBox(
          height: 10,
        ),
        customDropdown(context),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _telefono,
          decoration: InputDecoration(
            hintText: "Teléfono",
            prefixIcon: Icon(Icons.phone_android, color: Colors.blueAccent),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: _telefono2,
          decoration: InputDecoration(
            hintText: "Teléfono 2",
            prefixIcon: Icon(Icons.phone_in_talk, color: Colors.teal),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        // !! aqui hace todo el proceso de creacion
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 450,
            child: ElevatedButton(
                onPressed: () async {
                  // getLoadingModal(context, false);
                  List listaFinal = selectedItems
                      .map((elemento) => elemento.split("-").last)
                      .toList();

                  if (listaFinal.isEmpty ||
                      _usuario.text == "" ||
                      _correo.text == "" ||
                      _costo.text == "" ||
                      _telefono.text == "" ||
                      _telefono2.text == "") {
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Faltan datos del Registro',
                      desc: '',
                      btnCancelText: "Cancelar",
                      btnOkText: "Aceptar",
                      btnOkColor: Colors.green,
                      btnOkOnPress: () async {},
                      btnCancelOnPress: () async {},
                    ).show();
                  } else {
                    //  ************** YA ESTA CON LARAVEL ↓ *******************

                    var accesofRol = await Connections()
                        .getAccessofSpecificRol("TRANSPORTADOR");

                    // ! ************** REESTRUCTURACION LARAVEL ↓ *******************
                    Map<String, dynamic> roleParameters = {
                      "nombre_transportadora": _usuario.text,
                      "telefono1": _telefono2.text,
                      "telefono2": _telefono.text,
                      "costo_transportadora": _costo.text,
                      "rutas": listaFinal
                    };

                    await Connections().createUser(3, _usuario.text,
                        _correo.text, accesofRol, 3, roleParameters);
                    Navigator.pop(context);
                  }
                  //  ************** UNO *******************
                  // var responseCode =
                  //     await Connections().generateCodeAccount(
                  //   _correo.text,
                  // );

                  //  ************** TRES *******************

                  // var responseCreateGeneral = await Connections()
                  //     .createTransporterGeneral(_usuario.text, listaFinal,
                  //         _costo.text, _telefono.text, _telefono2.text);

                  //     //  ************** CUATRO *******************

                  // var response = await Connections().createTransporter(
                  //     _usuario.text,
                  //     _correo.text,
                  //     responseCreateGeneral[1],
                  //     responseCode.toString(),
                  //     accesofRol);

                  // Navigator.pop(context);
                },
                child: const Text(
                  "GUARDAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          ),
        )
      ],
    );
  }

  DropdownButtonHideUnderline customDropdown(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        hint: Row(
          children: [
            Icon(Icons.map_outlined, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Seleccione Rutas',
                style: TextStyle(color: Colors.deepPurple)),
          ],
        ),
        items: routes.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            //disable default onTap to avoid closing menu when selecting an item
            enabled: false,
            child: StatefulBuilder(
              builder: (context, menuSetState) {
                final _isSelected = selectedItems.contains(item);
                return InkWell(
                  onTap: () {
                    _isSelected
                        ? selectedItems.remove(item)
                        : selectedItems.add(item);
                    //This rebuilds the StatefulWidget to update the button's text
                    setState(() {});
                    //This rebuilds the dropdownMenu Widget to update the check mark
                    menuSetState(() {});
                  },
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _isSelected
                            ? const Icon(Icons.check_box_outlined)
                            : const Icon(Icons.check_box_outline_blank),
                        const SizedBox(width: 16),
                        Text(
                          item.toString().split('-')[0].toString(),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
        //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
        value: selectedItems.isEmpty ? null : selectedItems.last,
        onChanged: (value) {},
        selectedItemBuilder: (context) {
          return routes.map(
            (item) {
              return Container(
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  selectedItems.join(', '),
                  style: const TextStyle(
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
              );
            },
          ).toList();
        },
      ),
    );
  }
}

class AddRoute extends StatefulWidget {
  const AddRoute({super.key});

  @override
  State<AddRoute> createState() => _AddRouteState();
}

class _AddRouteState extends State<AddRoute> {
  bool isLoading = false;
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
        isLoading: isLoading,
        content: AlertDialog(
          content: SizedBox(
            width: 300,
            height: MediaQuery.of(context).size.height * 0.20,
            child: webContainer(context),
          ),
        ));
  }

  ListView webContainer(BuildContext context) {
    return ListView(
      children: [
        Align(
          // alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close)),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: Text(
            "Agregar Ruta",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        // Text(
        //   "Titulo",
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        SizedBox(
          height: 10,
        ),
        _modelTextField(
            text: "Título",
            controller: _controller,
            icon: Icons.text_fields_outlined),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () async {
                  Navigator.pop(context);
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AddCarrierLaravelModal();
                      });
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  var response =
                      await Connections().createRuta(_controller.text);
                  Navigator.pop(context);
                  // await showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return AddCarrierLaravelModal();
                  //     });
                },
                child: Text(
                  "Guardar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          ],
        )
      ],
    );
  }

  _modelTextField({text, controller, icon}) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width * 0.5,
      // padding: EdgeInsets.only(top: 15.0),
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // paginateData();
          // loadData();
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(icon),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    // getLoadingModal(context, false);
                    setState(() {
                      _controller.clear();
                    });

                    setState(() {
                      // paginateData();
                      // loadData();
                    });
                    // Navigator.pop(context);
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
}
