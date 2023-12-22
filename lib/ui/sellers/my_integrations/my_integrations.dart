import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/integrations_model.dart';
import 'package:frontend/ui/sellers/my_integrations/controllers/my_integrations_controller.dart';
import 'package:frontend/ui/sellers/my_integrations/create_integration.dart';

class MyIntegrations extends StatefulWidget {
  const MyIntegrations({super.key});

  @override
  State<MyIntegrations> createState() => _MyIntegrationsState();
}

class _MyIntegrationsState extends State<MyIntegrations> {
  List<IntegrationsModel> integrations = [];
  final MyIntegrationsController _integrationsController =
      MyIntegrationsController();
  bool isLoading = false;
  bool _hasData = false;

  @override
  void initState() {
    _loadDataAsync();

    super.initState();
  }

  _loadDataAsync() async {
    setState(() {
      isLoading = true;
    });
    await _integrationsController
        .loadIntegrations(); // Espera a que loadIntegrations() termine
    loadData();
    setState(() {
      isLoading = false;
    }); // Una vez que loadIntegrations() termina, carga los datos en integrations
  }

  loadData() {
    setState(() {
      integrations = _integrationsController.integrations;
      _hasData = integrations.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: isLoading,
      blurEffectIntensity: 4,
      progressIndicator: SpinKitFadingCircle(
        color: const Color.fromARGB(255, 4, 2, 5),
        size: 90.0,
      ),
      dismissible: false,
      opacity: 0.4,
      color: Colors.black87,
      child: Container(
        padding: EdgeInsets.only(
          left: 100,
          right: 100,
          top: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  openDialog(context);
                },
                child: const Text("Crear"),
              ),
            ),
            integrations.isNotEmpty
                ? Center(child: _buildDataTable())
                : Center(child: Text('Sin datos')),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.black),
      dataTextStyle: TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      columnSpacing: 12,
      horizontalMargin: 12,
      columns: [
        DataColumn(
            label: Text(
          'ID',
          style: TextStyle(color: Colors.black),
        )),
        DataColumn(label: Text('Store URL')),
        DataColumn(label: Text('User ID')),
        DataColumn(label: Text('Token'), numeric: true),
        DataColumn(
            label:
                Text('Copy Token')), // Columna adicional para el botón de copia
      ],
      rows: integrations.map((integration) {
        return DataRow(cells: [
          DataCell(Text(integration.id.toString())),
          DataCell(Text(integration.description.toString())),
          DataCell(Text(integration.userId.toString())),
          DataCell(SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 200,
              child: Text(
                integration.token.toString(),
                maxLines: 1, // Limita el texto a una sola línea
                overflow: TextOverflow
                    .ellipsis, // Muestra puntos suspensivos si el texto es demasiado largo
              ),
            ),
          )),
          DataCell(IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: integration.token.toString()));
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Token copiado')));
            },
          )),
        ]);
      }).toList(),
    );
  }

  Future<dynamic> openDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent, // Hace el fondo transparente
          content: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.white, // Color del contenido del diálogo
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: CreateIntegration(),
          ),
        );
      },
    ).then((value) {
      setState(() {
        //_futureProviderData = _loadProviders(); // Actualiza el Future
      });
    });
  }
}
