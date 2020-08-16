import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:monumental_change/screens/search.dart';
import 'package:monumental_change/services/geolocator_service.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:monumental_change/services/places_service.dart';

import 'Models/place.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final locatorService = GeoLocatorService();
  final placesService = PlacesService();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(create: (context) => locatorService.getLocation()),
        ProxyProvider<Position,Future<List<Place>>>(
          update: (context, position, places){
            return (position != null) ? placesService.getPlaces(position.latitude, position.longitude) :null;
          },
        )
      ],
      child: MaterialApp(
      title: 'Monumental Change',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:AnimatedContainerApp(),
    ),
    );

  }


}

