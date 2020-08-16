import 'dart:collection';

import'package:monumental_change/Models/place.dart';
import'package:http/http.dart' as http;
import 'dart:convert' as convert;
class PlacesService {
  final key = 'AIzaSyATI5JvYvomCjqC9BURRu8Ly-9w6yILXBs';

  Future<List<Place>> getPlaces(double lat, double lng) async {
    var response = await http.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&keyword=statue&radius=5000&key=$key');
    var response2 = await http.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&keyword=historical&radius=5000&key=$key');
    var response3 = await http.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&keyword=memorial&radius=5000&key=$key');
    var response4 = await http.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&keyword=sculpture&radius=5000&key=$key');


    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    jsonResults = jsonResults.map((place) => Place.fromJson(place)).toList();
    var json2 = convert.jsonDecode(response2.body);
    var jsonResults2 = json2['results'] as List;
    jsonResults2 = jsonResults2.map((place) => Place.fromJson(place)).toList();
    var json3 = convert.jsonDecode(response3.body);
    var jsonResults3 = json3['results'] as List;
    jsonResults3 = jsonResults3.map((place) => Place.fromJson(place)).toList();
    var json4 = convert.jsonDecode(response4.body);
    var jsonResults4 = json4['results'] as List;
    jsonResults4 = jsonResults4.map((place) => Place.fromJson(place)).toList();
    jsonResults = jsonResults + jsonResults2 + jsonResults3 + jsonResults4;
    Map<double, Place> order = SplayTreeMap<double, Place>();
    List<Place> list = List<Place>();
    for (Place place in jsonResults) {
        if (place.name.toLowerCase().contains("statue") ||
            place.name.toLowerCase().contains("memorial")
            || place.name.toLowerCase().contains("historic") ||
            place.name.toLowerCase().contains("house")
            || place.name.toLowerCase().contains("manor") || place.name.toLowerCase().contains("sculpture") ||
            place.name.toLowerCase().contains("display")) {
          var num = place.geometry.location.lat;
          var numtwo = place.geometry.location.lng;
          var closestNumber = (num + numtwo) - lat - lng;
          if (closestNumber < 0) {
            closestNumber = closestNumber * -1;
          }
          order[closestNumber] = place;
        }
      }
    int i = 0;
    for (double num in order.keys) {
      list.add(order[num]);
      if (list[i].name.toLowerCase().contains('stevens') || list[i].name.toLowerCase().contains('park') || list[i].name.toLowerCase().contains('funeral')) {
        list.removeAt(i);
        i--;
      }
      i++;
    }

    return list;
  }
}



