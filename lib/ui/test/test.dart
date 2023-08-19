import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class TestValues extends StatefulWidget {
  const TestValues({super.key});

  @override
  State<TestValues> createState() => _TestValuesState();
}

class _TestValuesState extends State<TestValues> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {


              double costoEntregaTotal = 0.0;
              var data = await Connections().getOrdersTest1();
              List valuesCostoEntregaVendedorEntregados = [];
              double numberCostoEntregaVendedorEntregados = 0.0;
              for (var i = 0; i < data.length; i++) {
                valuesCostoEntregaVendedorEntregados.add(data[i]['attributes']
                        ['users']['data'][0]['attributes']['vendedores']['data']
                    [0]['attributes']['CostoEnvio']);
                numberCostoEntregaVendedorEntregados += double.parse(data[i]
                            ['attributes']['users']['data'][0]['attributes']
                        ['vendedores']['data'][0]['attributes']['CostoEnvio']
                    .toString()
                    .replaceAll(",", "."));
              }
              // print(numberCostoEntregaVendedorEntregados);

              var data2 = await Connections().getOrdersTest2();
              List valuesCostoEntregaVendedorNoEntregados = [];
              double numberCostoEntregaVendedorNoEntregados = 0.0;
              for (var i = 0; i < data2.length; i++) {
                valuesCostoEntregaVendedorNoEntregados.add(data2[i]
                        ['attributes']['users']['data'][0]['attributes']
                    ['vendedores']['data'][0]['attributes']['CostoEnvio']);
                numberCostoEntregaVendedorNoEntregados += double.parse(data2[i]
                            ['attributes']['users']['data'][0]['attributes']
                        ['vendedores']['data'][0]['attributes']['CostoEnvio']
                    .toString()
                    .replaceAll(",", "."));
              }
              // print(numberCostoEntregaVendedorNoEntregados);
              costoEntregaTotal = numberCostoEntregaVendedorNoEntregados +
                  numberCostoEntregaVendedorEntregados;
                  //NUMERO 1
              print(costoEntregaTotal);

              // COSTO ENTREGA TRANSPORTE
              var dataT = await Connections().getOrdersTest1();
              List valuesCostoEntregaTEntregados = [];
              double numberCostoEntregaTEntregados = 0.0;
              for (var i = 0; i < dataT.length; i++) {
                valuesCostoEntregaTEntregados.add(dataT[i]['attributes']
                        ['transportadora']['data']['attributes']
                    ['Costo_Transportadora']);
                numberCostoEntregaTEntregados += double.parse(dataT[i]
                            ['attributes']['transportadora']['data']
                        ['attributes']['Costo_Transportadora']
                    .toString()
                    .replaceAll(",", "."));
              }
              // print(numberCostoEntregaTEntregados);
              double costoEntregaTTotalN = 0.0;

              var data2T = await Connections().getOrdersTest2();
              List valuesCostoEntregaTNoEntregados = [];
              double numberCostoEntregaTNoEntregados = 0.0;
              for (var i = 0; i < data2T.length; i++) {
                valuesCostoEntregaTNoEntregados.add(data2T[i]['attributes']
                        ['transportadora']['data']['attributes']
                    ['Costo_Transportadora']);
                numberCostoEntregaTNoEntregados += double.parse(data2T[i]
                            ['attributes']['transportadora']['data']
                        ['attributes']['Costo_Transportadora']
                    .toString()
                    .replaceAll(",", "."));
              }
              costoEntregaTTotalN = numberCostoEntregaTEntregados +
                  numberCostoEntregaTNoEntregados;
                  //numero 4
              print(costoEntregaTTotalN);

              //DEVOLUCION
              var data3T = await Connections().getOrdersTest3();
               List valuesDevo = [];
              double valuesDevoF = 0.0;
              for (var i = 0; i < data3T.length; i++) {
                print(data3T[i]['id']);
             valuesDevo.add(data3T[i]['attributes']
                        ['users']['data'][0]['attributes']['vendedores']['data']
                    [0]['id']);
                valuesDevoF += double.parse(data3T[i]
                            ['attributes']['users']['data'][0]['attributes']
                        ['vendedores']['data'][0]['attributes']['CostoDevolucion']
                    .toString()
                    .replaceAll(",", "."));
              }

              
            },
            child: Text("Generar")),
      ),
    );
  }
}
