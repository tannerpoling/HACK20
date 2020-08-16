import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:monumental_change/Models/place.dart';

class MarkerService {
  List<Marker> getMarkers(List<Place> places) {
    var markers = List<Marker>();

    places.forEach((element) {
      Marker marker = Marker(
          markerId: MarkerId(element.name),
          draggable: false,
        infoWindow:  InfoWindow(
            title: element.name,
            snippet: element.vicinity),
        position: LatLng(element.geometry.location.lat, element.geometry.location.lng)
        );

      markers.add(marker);
    });
  return markers;
  }
}