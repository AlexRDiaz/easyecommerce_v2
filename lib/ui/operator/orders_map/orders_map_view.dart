// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/text_field_icon.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class OrdersMapView extends StatefulWidget {
  const OrdersMapView({super.key});

  @override
  State<OrdersMapView> createState() => _OrdersMapViewState();
}

class _OrdersMapViewState extends State<OrdersMapView> {
  final TextEditingController _idOrder = TextEditingController();
  final TextEditingController _code = TextEditingController();

  final TextEditingController _latitude = TextEditingController();
  final TextEditingController _longitude = TextEditingController();

  static const LatLng _start = LatLng(-0.155118, -78.494425);
  static const LatLng _order1 = LatLng(-0.1973628, -78.4935989);
  static const LatLng _order2 = LatLng(-0.1973628, -78.4935989);
  static const LatLng _order3 = LatLng(-0.2079762, -78.496783);
  static const LatLng _order4 = LatLng(-0.1320988, -78.48232);
  static const LatLng _order5 = LatLng(-0.1084936, -78.4697426);
  List<Marker> _markers = [];

  LatLng? _customLocation;
  LatLng? _currentLocation;

  final MapController _leftMapController = MapController();
  final MapController _rightMapController = MapController();

  List<Map<String, dynamic>> ordersData = [
    {
      "id": 281967,
      "numero_orden": "ECUtienda-6336",
      "latitude": -0.2079762,
      "longitude": -78.496783
    },
    {
      "id": 281968,
      "numero_orden": "Bacantiendaec-10238",
      "latitude": -0.1973628,
      "longitude": -78.4935989
    },
    {
      "id": 281968,
      "numero_orden": "DETODITOEC-37417",
      "latitude": -0.1320988,
      "longitude": -78.48232
    },
    {
      "id": 281968,
      "numero_orden": "TienditaEcu-23040",
      "latitude": -0.1084936,
      "longitude": -78.4697426
    },
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    for (var order in ordersData) {
      if (order["latitude"] != null && order["longitude"] != null) {
        _markers.add(
          Marker(
            point: LatLng(order["latitude"], order["longitude"]),
            width: 80,
            height: 80,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: Text(
                    order["numero_orden"],
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 12),
                  ),
                ),
                Icon(
                  Icons.location_pin,
                  size: 30,
                  color: ColorsSystem().textoAzulElectrico,
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Position position = await Geolocator.getCurrentPosition();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.lowest);
    // desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    // List<LatLng> points = [
    //   _start,
    //   _order1,
    //   _order2,
    //   _order3,
    //   _order4,
    //   _order5,
    // ];

    // List<Marker> markers = points.map((point) {
    //   return Marker(
    //     point: point,
    //     width: 60,
    //     height: 60,
    //     child: Icon(
    //       Icons.location_pin,
    //       size: 40,
    //       color: ColorsSystem().mainBlue,
    //     ),
    //   );
    // }).toList();

    // Añade el marcador para la ubicación actual si está disponible.
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          point: _currentLocation!,
          width: 60,
          height: 60,
          child: const Icon(
            Icons.location_pin,
            size: 40,
            color: Colors.redAccent,
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Container(
            //   padding: const EdgeInsets.only(
            //       left: 20, right: 15, top: 20, bottom: 20),
            //   color: Colors.green[100],
            //   child: InputDecorator(
            //     decoration: InputDecoration(
            //       labelText: 'Configuraciones',
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10.0),
            //       ),
            //     ),
            //     child: const Column(children: []),
            //   ),
            // ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      padding: const EdgeInsets.all(10),
                      color: Colors.blue[100],
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ingreso de Localizacion de entrega',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: TextFieldIcon(
                                    controller: _idOrder,
                                    labelText: 'ID Pedido',
                                    icon: Icons.numbers,
                                    inputType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}$')),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () async {
                                    //
                                    var response = await Connections()
                                        .getOrderById(
                                            _idOrder.text, ["vendor"]);
                                    print(response);
                                    if (response != 1 && response != 2) {
                                      _code.text =
                                          "${response['numero_orden']}-${response['vendor']['nombre_comercial']}";
                                      setState(() {});
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                  child: const Text(
                                    "Buscar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Código: ${_code.text}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFieldIcon(
                              controller: _latitude,
                              labelText: 'Latitud',
                              icon: Icons.location_pin,
                              inputType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d+\.?\d*$'),
                                ),
                              ],
                            ),
                            TextFieldIcon(
                              controller: _longitude,
                              labelText: 'Longitud',
                              icon: Icons.location_pin,
                              inputType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d+\.?\d*$'),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  double latitude =
                                      double.parse(_latitude.text);
                                  double longitude =
                                      double.parse(_longitude.text);
                                  _customLocation = LatLng(latitude, longitude);
                                  _leftMapController.move(_customLocation!, 15);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                "Localizar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              padding: const EdgeInsets.all(10),
                              color: Colors.deepPurple[100],
                              child: FlutterMap(
                                mapController: _leftMapController,
                                options: MapOptions(
                                  center: _currentLocation ?? _start,
                                  zoom: 17,
                                  interactiveFlags: InteractiveFlag.all,
                                ),
                                children: [
                                  openStreetMapTileLayer,
                                  if (_customLocation != null)
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _customLocation!,
                                          width: 60,
                                          height: 60,
                                          child: const Icon(
                                            Icons.location_pin,
                                            size: 40,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                var response = await Connections()
                                    .updatenueva(_idOrder.text, {
                                  "latitude": double.parse(_latitude.text),
                                  "longitude": double.parse(_longitude.text)
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                "Guardar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      padding: const EdgeInsets.all(10),
                      color: Colors.deepPurple[100],
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Mapa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: FlutterMap(
                          options: MapOptions(
                            center: _currentLocation ?? _start,
                            zoom: 13,
                            interactiveFlags: InteractiveFlag.all,
                          ),
                          children: [
                            openStreetMapTileLayer,
                            MarkerLayer(
                              markers: _markers,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      );
}
