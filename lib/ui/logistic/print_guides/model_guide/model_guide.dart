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
double heigthColumns = 36.2;
const double point = 1.0;
const double inch = 72.0;
const double cm = inch / 2.54;
const double mm = inch / 25.4;

class _ModelGuideState extends State<ModelGuide> {
  @override
  Widget build(BuildContext context) {
    var Params = [
      {'param': 'Fecha', 'value': widget.date},
      {'param': 'Código', 'value': widget.numPedido},
      {'param': 'Nombre', 'value': widget.name},
      {'param': 'Teléfono', 'value': widget.phone},
      {'param': 'Cantidad', 'value': widget.quantity},
      {'param': 'Producto', 'value': widget.product},
      {'param': 'Producto extra', 'value': widget.extraProduct},
      {'param': 'Precio total', 'value': '\$${widget.price}'},
    ];

    var paramsDatosEnvio = [
      {'param': 'Transportadora', 'value': widget.transport},
      {'param': 'Dirección', 'value': widget.address},
      {'param': 'Observación', 'value': widget.observation},
    ];

    Expanded addParams() {
      List<Widget> colParams = [];
      List<Widget> colValues = [];
      for (var element in Params) {
        colParams.add(
          Flexible(
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
          Flexible(
            child: Text(
              element['value'].toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: size * 1.3, fontFamily: 'RobotoMono'),
            ),
          ),
        );
      }

      return Expanded(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 40, right: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: Params.map((text) => Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '${text['param']}: ',
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size * 1.3,
                                fontFamily: 'RobotoMono'),
                          ),
                        ),
                      )).toList(),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 40, right: 10, bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: Params.map((text) => Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '${text['value']}',
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: size * 1.3, fontFamily: 'RobotoMono'),
                          ),
                        ),
                      )).toList(),
                ),
              ),
            ]),
      );
    }

    Expanded addDataPackage() {
      List<Widget> colDataPackege = [];

      for (var element in Params) {
        colDataPackege.add(
          Flexible(
            child: Row(
              children: [
                Container(
                  width: 6.2 * cm,
                  child: Text(
                    '${element['param'].toString()}: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size * 1.3,
                        fontFamily: 'RobotoMono'),
                  ),
                ),
                Expanded(
                  child: Text(
                    element['value'].toString(),
                    style: TextStyle(
                        fontSize: size * 1.3, fontFamily: 'RobotoMono'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 40, right: 10, top: 20),
          child: Column(
            children: colDataPackege,
          ),
        ),
      );
    }

    Expanded addDataDelivery() {
      List<Widget> colDataDelivery = [];

      for (var element in paramsDatosEnvio) {
        colDataDelivery.add(
          Row(
            children: [
              Container(
                width: 6.2 * cm,
                child: Text(
                  '${element['param'].toString()}: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size * 1.3,
                      fontFamily: 'RobotoMono'),
                ),
              ),
              Expanded(
                child: Text(
                  element['value'].toString(),
                  style:
                      TextStyle(fontSize: size * 1.3, fontFamily: 'RobotoMono'),
                ),
              ),
            ],
          ),
        );
      }
      return Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 40, right: 10, top: 20),
          child: Column(
            children: colDataDelivery,
          ),
        ),
      );
    }

    return Transform.scale(
      scale: 1,
      child: Container(
        width: 26.2 * cm,
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _Header(),
            ),
            addDataPackage(),
            Divider(
              height: 10,
              color: Colors.black,
            ),
            addDataDelivery(),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 40, bottom: 20),

              // padding: EdgeInsets.only(left: 40),
              child: Text(
                "Ciudad: ${widget.city}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size * 2.2,
                    fontStyle: FontStyle.italic),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          right: BorderSide(color: Colors.black, width: 0.5),
                          top: BorderSide(color: Colors.black, width: 0.5)),
                    ),
                    height: 49 * multi,
                    width: 500,
                    child: Column(
                      children: [
                        Expanded(
                          child: BarcodeWidget(
                            margin: EdgeInsets.all(12),
                            barcode: Barcode.code128(),
                            data: '${widget.idForBarcode.toString()}',
                            drawText: true,
                            style: TextStyle(fontSize: 10),
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
    );
  }

  Row _4Column() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Container(
          height: 49 * multi,
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black, width: 0.5))),
          child: Center(
            child: PrettyQr(
              size: 120,
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
          ],
        ),
      ),
    );
  }
}
