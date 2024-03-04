import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';

class InfoCarrierExternal extends StatefulWidget {
  const InfoCarrierExternal({super.key});

  @override
  State<InfoCarrierExternal> createState() => _InfoCarrierExternalState();
}

class _InfoCarrierExternalState extends State<InfoCarrierExternal> {
  bool isLoading = false;
  List<String> provinciasToSelect = [];
  String? selectedProvincia;
  List<String> parroquiasToSelect = [];
  String? selectedParroquia;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
        provinciasToSelect = [];
        parroquiasToSelect = [];
      });
      //
      var provinciasList = [];

      provinciasList = await Connections().getProvincias();
      for (var i = 0; i < provinciasList.length; i++) {
        setState(() {
          provinciasToSelect.add('${provinciasList[i]}');
        });
      }

      //
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
          context, "Ha ocurrido un error al cargar las Subrutas");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWith > 600 ? screenWith * 0.95 : screenWith,
      height: screenHeight * 0.9,
      color: Colors.white,
      child: CustomProgressModal(
        isLoading: isLoading,
        content: ListView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          children: [],
        ),
      ),
    );
  }
}
