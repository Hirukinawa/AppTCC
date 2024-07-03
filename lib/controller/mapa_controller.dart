import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

class MapaController extends ChangeNotifier {
  double lat = 0.0;
  double long = 0.0;
  String erro = "";
  late GoogleMapController _mapsController;
  List<Polyline> polylines = []; // Lista de polylines

  get mapsController => _mapsController;

  onMapCreated(GoogleMapController gmc) async {
    _mapsController = gmc;
    getPosicao();
  }

  // Método para adicionar as polylines
  void addPolylines(List<Polyline> polylines) {
    // Adicione as polylines à lista de polylines existente
    this.polylines.addAll(polylines);
    notifyListeners();
  }

  getPosicao() async {
    try {
      Position posicao = await _posicaoAtual();
      lat = posicao.latitude;
      long = posicao.longitude;
      _mapsController.animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
    } catch (e) {
      erro = e.toString();
    }
  }

  getNewPosicao(LatLng newLocation) async {
    try {
      _mapsController.animateCamera(CameraUpdate.newLatLng(newLocation));
    } catch (e) {
      erro = e.toString();
    }
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;

    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      return Future.error('Por favor habilite a localização');
    }

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();

      if (permissao == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }
}
