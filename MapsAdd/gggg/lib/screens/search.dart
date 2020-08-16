import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:monumental_change/Models/place.dart';
import 'package:monumental_change/services/geolocator_service.dart';
import 'package:monumental_change/services/marker_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
class Search extends State<AnimatedContainerApp> {
  double _width = 0;
  double _height = 0;
  var hideListView = 0;
  double sizeBoxHeight = 0;
  @override
  Widget build(BuildContext context) {
    final currentPosition = Provider.of<Position>(context);
    final placesProvider = Provider.of<Future<List<Place>>>(context);
    final geoService = GeoLocatorService();
    final markerService = MarkerService();
    bool _isVisible = false;
    return FutureProvider(
      create: (context) => placesProvider,
      child: Scaffold(
        body: (currentPosition != null)
          ? Consumer<List<Place>>(
              builder: (_, places, __) {
                var markers = (places != null) ? markerService.getMarkers(places) : List<Marker>();
              return (places != null) ?
              Column(
                children: <Widget>[
                  AnimatedContainer(
                    height: _height = MediaQuery
                        .of(context)
                        .size
                        .height * 3/5,
                    width: _height = MediaQuery
                        .of(context)
                        .size
                        .height,
                    duration: Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn,
                    child: GoogleMap(
                      initialCameraPosition:
                      CameraPosition(target: LatLng(
                          currentPosition.latitude, currentPosition.longitude),
                          zoom: 9.0),
                      zoomGesturesEnabled: true,
                      markers: Set<Marker>.of(markers),
                    ),

                  ),
                  SizedBox(height: sizeBoxHeight,),
                  Expanded(
                    //child:Visibility(
                      //visible: _isVisible,
                    child: ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        return FutureProvider(
                          create: (context) => geoService.getDistance(currentPosition.latitude,
                              currentPosition.longitude,
                              places[index].geometry.location.lat,
                              places[index].geometry.location.lng),
                            //child: Visibility(
                              //  visible: _isVisible,
                          child: Card(
                            child: ListTile(
                              title: Text(places[index].name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 3.0,),
                              Row(),
                                  SizedBox(height: 5.0,),
                                  Consumer<double>(
                                    builder: (context, meters, widget) {
                                      return (meters != null)
                                          ?Text('${places[index].vicinity} \u00b7 ${(meters / 1609).toString().substring(0,3)}mi')
                                          :Container();
                                    },
                                  )
                                  ] ,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.directions),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  launchMapsURL(places[index].geometry.location.lat, places[index].geometry.location.lng);
                                },
                              )
                                  )
                              ),
                            );
                          }),

                    //),
                  ),
//                  FloatingActionButton(
//                    child: Icon(Icons.play_arrow),
//                    // When the user taps the button
//                    onPressed: () {
//                    // Use setState to rebuild the widget with new values.
//                    setState(() {
//                // Generate a random width and height.
////                _width = random.nextInt(300).toDouble();
////                _height = random.nextInt(300).toDouble();
//                });
//                        }
                ]
              ) : Center(child: CircularProgressIndicator());
            },
        )
            : Center(
                child: CircularProgressIndicator(),
            ),
      ),
    );
  }

  void launchMapsURL(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch specified URL';
    }
  }
}

class AnimatedContainerApp extends StatefulWidget {
  @override
  Search createState() => Search();
}
