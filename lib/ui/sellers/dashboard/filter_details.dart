import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/sellers/dashboard/MyFiles.dart';
import 'package:frontend/ui/sellers/dashboard/file_info_card.dart';
import 'package:frontend/ui/sellers/dashboard/storage_info_card.dart';

import 'chart.dart';

class FilterDetails extends StatefulWidget {
  final double total;
  final double costoEntregas;
  final double costoDevoluciones;
  final double utilidades;
  const FilterDetails(
      {Key? key,
      required this.total,
      required this.costoEntregas,
      required this.costoDevoluciones,
      required this.utilidades})
      : super(key: key);

  @override
  State<FilterDetails> createState() => _FilterDetailsState();
}

class _FilterDetailsState extends State<FilterDetails> {
  @override
  Widget build(BuildContext context) {
    List demoMyFiles = [
      CloudStorageInfo(
        title: "Total valores recibidos",
        numOfFiles: widget.total,
        svgSrc: "assets/icons/Documents.svg",
        // totalStorage: "\$ 923,23",
        color: Colors.amber,
        percentage: 35,
      ),
      CloudStorageInfo(
        title: "Costo entregas",
        numOfFiles: widget.costoEntregas,
        svgSrc: "assets/icons/google_drive.svg",
        // totalStorage: "\$200,23",
        color: Color(0xFFFFA113),
        percentage: 35,
      ),
      CloudStorageInfo(
        title: "Devoluciones",
        numOfFiles: widget.costoDevoluciones,
        svgSrc: "assets/icons/one_drive.svg",
        // totalStorage: "\$20,23",
        color: Color(0xFFA4CDFF),
        percentage: 10,
      ),
      CloudStorageInfo(
        title: "Utilidades",
        numOfFiles: widget.utilidades,
        svgSrc: "assets/icons/drop_box.svg",
        // totalStorage: "\$320,16",
        color: Color(0xFF007EE5),
        percentage: 78,
      ),
    ];

    final Size _size = MediaQuery.of(context).size;

    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Calculo de valores',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Column(
                  children: [
                    // FileInfoCardGridView(
                    //   childAspectRatio: _size.width < 1400 ? 1.0 : 1.3,
                    // ),
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: demoMyFiles.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 7.0,
                        mainAxisSpacing: 7.0,
                        childAspectRatio: _size.width < 1400 ? 1.0 : 1.3,
                      ),
                      itemBuilder: (context, index) =>
                          FileInfoCard(info: demoMyFiles[index]),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterCheckModel {
  final String? svgSrc, title, filter;
  int? numOfFiles;
  final double? percentage;
  final Color? color;
  late bool? check;

  FilterCheckModel(
      {this.svgSrc,
      this.title,
      this.filter,
      this.numOfFiles,
      this.percentage,
      this.color,
      this.check});
}
