import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/image_input.dart';
import 'package:frontend/ui/widgets/forms/image_row.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import '../../widgets/options_modal.dart';
import 'controllers/controllers.dart';

class WithdrawalDetailsLaravel extends StatefulWidget {
  final dataT;

  const WithdrawalDetailsLaravel({super.key, required this.dataT});

  @override
  State<WithdrawalDetailsLaravel> createState() =>
      _WithDrawalDetailsLaravelState();
}

class _WithDrawalDetailsLaravelState extends State<WithdrawalDetailsLaravel> {
  TextEditingController _modalController = TextEditingController();
  List data = [];
  bool loading = true;
  XFile? imageSelect = null;
  TextEditingController _fecha = TextEditingController();
  TextEditingController _monto = TextEditingController();
  TextEditingController _codigoDeValidacion = TextEditingController();
  TextEditingController _codigoDeRetiro = TextEditingController();
  TextEditingController _fechaT = TextEditingController();

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    data = [widget.dataT];

    _fecha.text = data[0]['fecha'].toString();
    _monto.text = data[0]['monto'].toString();
    _fechaT.text = data[0]['fecha_transferencia'].toString();

    // Navigator.pop(context);
    // setState(() {
    //   loading = false;
    // });
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.6,
        child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  RowLabel(
                    title: 'Fecha Ingreso Solicitud',
                    value: data[0]['fecha'].toString(),
                    color: Colors.black,
                  ),
                  RowLabel(
                    title: 'Id Vendedor',
                    value:
                        data[0]['users_permissions_user'][0]['id'].toString(),
                    color: Colors.black,
                  ),
                  RowLabel(
                    title: 'Vendedor',
                    value: data[0]['users_permissions_user'][0]['username']
                        .toString(),
                    color: Colors.black,
                  ),
                  RowLabel(
                    title: 'Email',
                    value:
                        data[0]['users_permissions_user'][0]['email'].toString(),
                    color: Colors.black,
                  ),
                  RowLabel(
                    title: 'Monto a retirar',
                    value: data[0]['monto'].toString(),
                    color: Colors.black,
                  ),
                  RowLabel(
                    title: 'Estado del pago',
                    value: data[0]['estado'].toString(),
                    color: Colors.black,
                  ),
                  RowLabel(
                    title: 'Fecha y Hora Transferencia',
                    value: data[0]['fecha_transferencia'].toString(),
                    color: Colors.black,
                  ),
                  RowLabel(
                    title: 'Comentario',
                    value: data[0]['comentario'].toString(),
                    color: Colors.black,
                  ),
                  RowImage(
                    title: "Comprobante",
                    value: data[0]['comprobante'].toString(),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
