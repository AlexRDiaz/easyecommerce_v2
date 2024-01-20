// import 'package:flutter/material.dart';

// class WalletMobile extends StatefulWidget {
//   const WalletMobile({super.key});

//   @override
//   State<WalletMobile> createState() => _WalletMobileState();
// }

// class _WalletMobileState extends State<WalletMobile> {
  
//   @override
//   Widget build(BuildContext context) {
//        double heigth = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           _leftWidgetMobile(width, heigth, context),
//           Container(
//             height: heigth * 0.6,
//             child: Expanded(
//               child: Column(
//                 children: [
//                   _searchBar(width, heigth, context),
//                   _dataTableTransactions(heigth),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  _searchBar(double width, double heigth, BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white,
//       ),
//       child: responsive(
//           Row(
//             children: [
//               Container(
//                 decoration:
//                     BoxDecoration(borderRadius: BorderRadius.circular(15)),
//                 width: MediaQuery.of(context).size.width * 0.2,
//                 child: _modelTextField(
//                     text: "Buscar", controller: searchController),
//               ),

//               Container(
//                 padding: const EdgeInsets.only(left: 15, right: 5),
//                 child: Text(
//                   "Registros: ${data.length}",
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.black),
//                 ),
//               ),
//               TextButton(
//                   onPressed: () => loadData(), child: Text("Actualizar")),
//               Spacer(),
//               Expanded(child: numberPaginator()),

//               //   Expanded(child: numberPaginator()),
//             ],
//           ),
//           Row(
//             children: [
//               Container(
//                 decoration:
//                     BoxDecoration(borderRadius: BorderRadius.circular(15)),
//                 width: MediaQuery.of(context).size.width * 0.2,
//                 child: _modelTextField(
//                     text: "Buscar", controller: searchController),
//               ),

//               Container(
//                 padding: const EdgeInsets.only(left: 15, right: 5),
//                 child: Text(
//                   "Registros: ${data.length}",
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.black),
//                 ),
//               ),
//               TextButton(
//                   onPressed: () => loadData(), child: Text("Actualizar")),

//               Expanded(child: numberPaginator()),

//               //   Expanded(child: numberPaginator()),
//             ],
//           ),
//           context),
//     );
//   }

//   Container _dataTableTransactions(height) {
//     return Container(
//       height: height * 0.4,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: Colors.white,
//       ),
//       child: data.length > 0
//           ? Expanded(
//               child: DataTableModelPrincipal(
//                   columnWidth: 400,
//                   columns: getColumns(),
//                   rows: buildDataRows(data)),
//             )
//           : Center(
//               child: Text("Sin datos"),
//             ),
//     );
//   }


//   Container _saldoDeCuentaMobile(double width) {
//     return Container(
//       decoration: BoxDecoration(boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.5), // Color de la sombra
//           spreadRadius: 5, // Radio de dispersión de la sombra
//           blurRadius: 7, // Radio de desenfoque de la sombra
//           offset: Offset(
//               0, 3), // Desplazamiento de la sombra (horizontal, vertical)
//         ),
//       ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
//       width: width * 0.3,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             '\$${formatNumber(double.parse(saldo))}',
//             style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueAccent),
//           ),
//           Text(
//             'Saldo de Cuenta',
//             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }




//   Container _leftWidgetWeb(double width, double heigth, BuildContext context) {
//     return Container(
//       width: width * 0.15,
//       padding: EdgeInsets.only(left: 10, right: 20),
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
//       child:
//           Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//         Container(
//           decoration: BoxDecoration(boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5), // Color de la sombra
//               spreadRadius: 5, // Radio de dispersión de la sombra
//               blurRadius: 7, // Radio de desenfoque de la sombra
//               offset: Offset(
//                   0, 3), // Desplazamiento de la sombra (horizontal, vertical)
//             ),
//           ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
//           width: width * 0.2,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 '\$${formatNumber(double.parse(saldo))}',
//                 style: TextStyle(
//                     fontSize: 34,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueAccent),
//               ),
//               Text(
//                 'Saldo de Cuenta',
//                 style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 20,
//         ),
//         _dateButtons(width, context),
//         SizedBox(
//           height: 20,
//         ),
//         _optionButtons(width, heigth),
//       ]),
//     );
//   }

//   Container _leftWidgetMobile(
//       double width, double heigth, BuildContext context) {
//     return Container(
//       height: heigth * 0.15,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15), color: Colors.white),
//       child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//         _saldoDeCuenta(width),
//         _dateButtonsMobile(width, context),
//         _optionButtons(width, heigth),
//       ]),
//     );
//   }

//   Container _dateButtonsMobile(double width, BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.5), // Color de la sombra
//           spreadRadius: 5, // Radio de dispersión de la sombra
//           blurRadius: 7, // Radio de desenfoque de la sombra
//           offset: Offset(
//               0, 3), // Desplazamiento de la sombra (horizontal, vertical)
//         ),
//       ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
//       width: width * 0.34,
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.only(bottom: 10),
//                 child: FilledButton.tonal(
//                   onPressed: () {
//                     _showDatePickerModal(context);
//                   },
//                   style: ButtonStyle(
//                     shape: MaterialStateProperty.all<OutlinedBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             5), // Ajusta el valor según sea necesario
//                       ),
//                     ),
//                   ),
//                   child: Icon(Icons.calendar_month_outlined),
//                 ),
//               ),
//               SizedBox(width: 5),
//               Container(
//                 padding: EdgeInsets.only(bottom: 10),
//                 child: FilledButton.tonal(
//                   style: ButtonStyle(
//                     shape: MaterialStateProperty.all<OutlinedBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             5), // Ajusta el valor según sea necesario
//                       ),
//                     ),
//                   ),
//                   onPressed: () {
//                     loadData();
//                   },
//                   child: Icon(Icons.search),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 5),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildDateFieldMobile("Desde", _startDateController),
//               SizedBox(width: 5),
//               _buildDateFieldMobile("Hasta", _endDateController),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

// }