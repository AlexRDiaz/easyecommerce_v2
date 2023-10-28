import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/sellers/add_seller_user/custom_filter_seller_user.dart';
import 'package:frontend/ui/widgets/loading.dart';

class AddSellerI extends StatefulWidget {
  final List<dynamic> accessTemp;
  // const AddSellerI({super.key});

  const AddSellerI({required this.accessTemp, Key? key}) : super(key: key);

  @override
  State<AddSellerI> createState() => _AddSellerIState();
}

class _AddSellerIState extends State<AddSellerI> {
  TextEditingController _usuario = TextEditingController();
  TextEditingController _correo = TextEditingController();
  bool dashboard = false;
  bool reporteVentas = false;
  bool agregarUsuarios = false;
  bool ingresoPedidos = false;
  bool estadoEntregas = false;
  bool pedidosNoDeseados = false;
  bool billetera = false;
  bool miBilletera = false;
  bool transportStats = false;

  bool devoluciones = false;
  bool retiros = false;
  List vistas = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 500,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "USUARIO",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextField(
                style: TextStyle(fontWeight: FontWeight.bold),
                controller: _usuario,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "CORREO",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextField(
                style: TextStyle(fontWeight: FontWeight.bold),
                controller: _correo,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "ACCESOS ACTUALES",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                margin: EdgeInsets.all(20.0),
                height: 500,
                width: 500,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.0, color: Color.fromARGB(255, 224, 222, 222)),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Builder(
                  builder: (context) {
                    return SimpleFilterChips(
                      chipLabels: widget.accessTemp,
                      onSelectionChanged: (selectedChips) {
                        setState(() {
                          vistas = List.from(
                              selectedChips); 
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_correo.text.isNotEmpty && _usuario.text.isNotEmpty) {
                      getLoadingModal(context, false);
                      var response = await Connections().createInternalSeller(
                          _usuario.text, _correo.text, vistas);
                      Navigator.pop(context);
                      setState(() {
                        _correo.clear();
                        _usuario.clear();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "GUARDAR",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "CANCELAR",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
