import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/image_input.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/forms/row_options.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import '../../widgets/forms/modal_row.dart';
import 'controllers/controllers.dart';

class AddStockVendorDetail extends StatefulWidget {
  final bool isNew;
  const AddStockVendorDetail({
    super.key,
    required this.isNew,
  });

  @override
  State<AddStockVendorDetail> createState() =>
      _AddStockVendorDetailState();
}

class _AddStockVendorDetailState extends State<AddStockVendorDetail> {
  late AddStockToVendorController _controllers;
  initControllers() {
    if (widget.isNew) {
      _controllers = AddStockToVendorController(
          fecha: '',
          id: '',
          idProducto: '',
          cantidad: '');
    } else {
      _controllers = AddStockToVendorController(
          fecha: '',
          id: '',
          idProducto: '',
          cantidad: '');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  getLoadingModal(context, false);
    });
  }

  var data = {};
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    /*var response = await Connections().getLogisticGeneralByID();
    // data = response;
    data = response;
    _controllers.updateControllersEdit(response);
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });

    setState(() {});*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context, "/layout/logistic");
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black)),
        centerTitle: true,
        title: const Text(
          "Añadir Stock Productos Logistica Vendedores",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  DateInput(
                    isEdit: true,
                    title: "Fecha",
                    dateTime: DateTime.now(),
                    controller: _controllers.fechaController,
                  ),
                  ModalRow(
                    controller: _controllers.idController,
                    title: 'Id Vendedor',
                    options: [
                      'IMNOVO',
                      'MANDE STORE',
                      'EL RINCONCITO ECUATORIANO'
                    ],
                  ),
                  ModalRow(
                    controller: _controllers.idProductoController,
                    title: 'Id Producto',
                    options: [
                      'Producto 1',
                      'Producto 2',
                      'Producto 3'
                    ],
                  ),
                  InputRow(
                      controller: _controllers.cantidadController,
                      title: 'Cantidad'),
                  ElevatedButton(
                      onPressed: () async {
                        /*getLoadingModal(context, false);
                        await _controllers.updateUser(success: () {
                          Navigator.pop(context);
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.rightSlide,
                            title: 'Completado',
                            desc: 'Actualización Completada',
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                        }, error: () {
                          Navigator.pop(context);
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: 'Error',
                            desc: 'Revisa los Campos',
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                        });*/
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.colorGreen),
                      child: Text(
                        "Actualizar Datos",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
