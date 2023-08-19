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

class CarrierDetails extends StatefulWidget {
  final bool isNew;
  const CarrierDetails({
    super.key,
    required this.isNew,
  });

  @override
  State<CarrierDetails> createState() => _CarrierDetailsState();
}

class _CarrierDetailsState extends State<CarrierDetails> {
  late AddCarrierController _controllers;
  initControllers() {
    if (widget.isNew) {
      _controllers = AddCarrierController(
        usuario: '',
        tipoUsuario: '',
        correo: '',
        costo: '',
        ruta: '',
        telefono: '',
        telefonoDos: '',
      );
    } else {
      _controllers = AddCarrierController(
        usuario: 'usuario',
        tipoUsuario: '',
        correo: '',
        costo: '',
        ruta: '',
        telefono: '',
        telefonoDos: '',
      );
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
          "Agregar Transportista Form",
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
                  InputRow(
                      controller: _controllers.usuarioController,
                      title: 'Usuario'),
                  ModalRow(
                    controller: _controllers.tipoUsuarioController,
                    title: 'Tipo de Usuario',
                    options: [
                      'ADMINISTRADOR MASTER',
                      'ADMINISTRADOR PRV',
                      'OPERADOR'
                    ],
                  ),
                  InputRow(
                      controller: _controllers.correoController,
                      title: 'Correo'),
                  InputRow(
                      controller: _controllers.costoController, title: 'Costo'),
                  ModalRow(
                    controller: _controllers.rutaController,
                    title: 'Estado',
                    options: [
                      'ADMINISTRADOR MASTER',
                      'ADMINISTRADOR PRV',
                      'OPERADOR',
                      'ADMINISTRADOR MASTER',
                      'ADMINISTRADOR PRV',
                      'OPERADOR',
                      'ADMINISTRADOR MASTER',
                      'ADMINISTRADOR PRV',
                      'OPERADOR',
                      'ADMINISTRADOR MASTER',
                      'ADMINISTRADOR PRV',
                      'OPERADOR',
                    ],
                  ),
                  InputRow(
                      controller: _controllers.telefonoController,
                      title: 'Telefono'),
                  InputRow(
                      controller: _controllers.telefonoDosController,
                      title: 'Telefono dos'),
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
