import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';
import 'package:frontend/config/exports.dart';

class ModelGuide extends StatefulWidget {
  final String numPedido;
  final String date;
  final String city;
  final String product;
  final String extraProduct;
  final String quantity;
  final String phone;
  final String price;
  final String name;
  final String transport;
  final String address;
  final String observation;
  final String qrLink;
  final String idForBarcode;

  const ModelGuide(
      {super.key,
      required this.numPedido,
      required this.date,
      required this.city,
      required this.product,
      required this.extraProduct,
      required this.quantity,
      required this.phone,
      required this.price,
      required this.name,
      required this.transport,
      required this.address,
      required this.observation,
      required this.qrLink,
      required this.idForBarcode});

  @override
  State<ModelGuide> createState() => _ModelGuideState();
}

double size = 14.0;
double multi = 3.0;
double heigthColumns = 37;

class _ModelGuideState extends State<ModelGuide> {
  @override
  Widget build(BuildContext context) {
    var Params = [
      {'param': 'Fecha', 'value': widget.date},
      {'param': 'Código', 'value': widget.numPedido},
      {'param': 'Nombre', 'value': widget.name},
      {'param': 'Dirección', 'value': widget.address},
      {'param': 'Teléfono', 'value': widget.phone},
      {'param': 'Cantidad', 'value': widget.quantity},
      {'param': 'Producto', 'value': widget.product},
      {'param': 'Producto extra', 'value': widget.extraProduct},
      {'param': 'Precio Total', 'value': '\$${widget.price}'},
      {'param': 'Observacion', 'value': widget.observation},
      {'param': 'Transportadora', 'value': widget.transport}
    ];

    Row addParams() {
      List<Widget> colParams = [];
      List<Widget> colValues = [];
      for (var element in Params) {
        colParams.add(
          Container(
            height: heigthColumns,
            child: Text(
              '${element['param'].toString()}: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 1.3,
                  fontFamily: 'RobotoMono'),
            ),
          ),
        );

        colValues.add(
          Container(
            height: heigthColumns,
            child: Text(
              element['value'].toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 1.3,
                  fontFamily: 'RobotoMono'),
            ),
          ),
        );
      }

      return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 30, right: 10),
              width: 70 * multi,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: colParams,
              ),
            ),
            Container(
              width: 120 * multi,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: colValues),
            )
          ]);
    }

    return Transform.scale(
      scale: 1,
      child: Container(
        width: 250 * 3,
        height: 8050 * 3,
        child: Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.5),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _Header(),
                    ),
                    addParams(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 0.5)),
                            height: 50 * multi,
                            width: 700,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    " ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  // padding: EdgeInsets.only(left: 3, right: 3),
                                  height: 120,
                                  width: 400,
                                  child: Expanded(
                                    child: BarcodeWidget(
                                      barcode: Barcode.code128(),
                                      data: '${widget.idForBarcode.toString()}',
                                      drawText: true,
                                      height: 35,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: _4Column()),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row _4Column() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Container(
          height: 50 * multi,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5)),
          child: Center(
            child: PrettyQr(
              size: 100,
              data: '${widget.qrLink.toString()}',
              errorCorrectLevel: QrErrorCorrectLevel.M,
              roundEdges: true,
            ),
          ),
        ))
      ],
    );
  }

  Container _Header() {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Center(
        child: Column(
          children: [
            Center(
              child: Container(
                height: 60,
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      images.logoEasyEcommerceNoText,
                      width: 50,
                    ),
                    Text(
                      "asy Ecommerce",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size * 2.5,
                          fontFamily: 'RobotoMono'),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            Container(
              child: Center(
                child: Text(
                  "Ciudad: ${widget.city}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size * 2,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
