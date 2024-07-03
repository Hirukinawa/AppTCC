import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uniride/controller/mapa_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class RotaPage extends StatefulWidget {
  final Set<Polyline> rota;
  final List<LatLng> paradas;
  final LatLng origem;
  final LatLng destino;
  final List<Marker> markers;
  const RotaPage(
      {Key? key,
      required this.rota,
      required this.paradas,
      required this.origem,
      required this.destino,
      required this.markers})
      : super(key: key);

  @override
  _RotaPageState createState() => _RotaPageState();
}

class _RotaPageState extends State<RotaPage> {
  GoogleMapPolyline googleMapPolyline =
      GoogleMapPolyline(apiKey: "APIKEY");
  String link = "";
  List<LatLng> rotaFinal = [];

  @override
  void initState() {
    super.initState();
    loadLink();
  }

  Future<void> loadLink() async {
    String waypoints = "";

    rotaFinal.add(widget.origem);
    if (widget.paradas.isNotEmpty) {
      for (var parada in widget.paradas) {
        rotaFinal.add(parada);
      }
    }
    rotaFinal.add(widget.destino);

    if (widget.paradas.isNotEmpty) {
      for (int i = 1; i < rotaFinal.length - 1; i++) {
        waypoints += "${rotaFinal[i].latitude},${rotaFinal[i].longitude}";
        if (i < (rotaFinal.length - 2)) {
          waypoints += "|";
        }
      }
    }
    String origem = "${rotaFinal[0].latitude},${rotaFinal[0].longitude}";
    String destino =
        "${rotaFinal[rotaFinal.length - 1].latitude},${rotaFinal[rotaFinal.length - 1].longitude}";
    link =
        "https://www.google.com/maps/dir/?api=1&origin=$origem&destination=$destino&waypoints=$waypoints";
  }

  @override
  Widget build(BuildContext context) {
    final MapaController mapaController = Provider.of<MapaController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota'),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: ChangeNotifierProvider<MapaController>(
        create: (context) => MapaController(),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(mapaController.lat, mapaController.long),
            zoom: 13,
          ),
          zoomControlsEnabled: true,
          mapType: MapType.normal,
          myLocationEnabled: true,
          onMapCreated: mapaController.onMapCreated,
          polylines: widget.rota,
          markers: Set<Marker>.from(widget.markers),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: () async {
            var rotasLink = Uri.parse(link);

            try {
              await launchUrl(rotasLink);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Não foi possível abrir o mapa")));
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: (link == "")
              ? const CircularProgressIndicator()
              : const Text(
                  "Abrir no Google Maps",
                  style: TextStyle(
                    fontFamily: "InterLight",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
