import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:monumental_change/screens/search.dart';
import 'package:monumental_change/services/geolocator_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:monumental_change/services/places_service.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:expand_widget/expand_widget.dart';
import 'Models/place.dart';

Future<void> main() async {
  runApp(
    MyApp()
  );
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Monumental Change';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return SignInPage();
          }
          return HomeWidget();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class SignInPage extends StatelessWidget {

  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loginbackground.png'),
            fit: BoxFit.cover,
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 30),
                    decoration: BoxDecoration(
                      color: Color(0xff315cf4),
                      border: Border.all(
                        color: Colors.white,
                        width: 5
                      ),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Text(
                                  'Welcome to Monumental Change',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                color: Color(0xff315CF4),
                                child: RaisedButton(
                                  child: Text('Sign In Anonymously'),
                                  onPressed: _signInAnonymously,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          )
                        ]
                    ),
                )
              ]
            ),
          ]
        )
      )
    );
  }
}


class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    MapsWidget(),
    MonumentVisionWidget(),
    SavedWidget()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
//        body: GoogleMap(
//          onMapCreated: _onMapCreated,
//          initialCameraPosition: CameraPosition(
//            target: _center,
//            zoom: 11.0,
//          ),
//        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              backgroundColor: Colors.white,
              title: Text('Explore'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.change_history),
              backgroundColor: Colors.white,
              title: Text('Monument'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              backgroundColor: Colors.white,
              title: Text('Saved'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xff315CF4),
          elevation: 0,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class MapsWidget extends StatefulWidget {
  MapsWidget({Key key}) : super(key: key);

  @override
  _MapsWidgetState createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {

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

class MonumentVisionWidget extends StatefulWidget {
  MonumentVisionWidget({Key key}) : super(key: key);

  @override
  _MonumentVisionWidgetState createState() => _MonumentVisionWidgetState();
}

class _MonumentVisionWidgetState extends State<MonumentVisionWidget> {
  var title = '';
  var desc = '';
  Color infoIconColor = Colors.white;
  Color discIconColor = Colors.white;
  Color artIconColor = Colors.white;
  ArCoreController arCoreController;
  List<ArCoreNode> arNodes = new List<ArCoreNode>();
  var textBoxWidth = 1.2;
  var textBoxHeight = 0.8;
  var startView = true;
  var infoView = false;
  var discView = false;
  var artView = false;

  getInfo() {
    setState(() {
      arCoreController.addArCoreNode(arNodes.elementAt(0));
      arCoreController.removeNode(nodeName: 'disc');
      arCoreController.removeNode(nodeName: 'art');
    });
  }

  getDiscussion() {
    setState(() {
      arCoreController.addArCoreNode(arNodes.elementAt(1));
      arCoreController.removeNode(nodeName: 'info');
      arCoreController.removeNode(nodeName: 'art');
    });
  }

  getArtwork() {
    setState(() {
      arCoreController.addArCoreNode(arNodes.elementAt(2));
      arCoreController.removeNode(nodeName: 'info');
      arCoreController.removeNode(nodeName: 'disc');
    });
  }

  _arCoreStartView(ArCoreController _arCoreController) async {
    arCoreController = _arCoreController;
    String infoPath = "assets/images/info.png";
    vector.Vector3 position = vector.Vector3(-1.0, -1.0, -3);
    vector.Vector3 size = vector.Vector3(textBoxWidth, textBoxHeight, 0.1);
    _addTextBox(_arCoreController, infoPath, position, size, 'info');

    String discussionPath = "assets/images/discussion.png";
    position = vector.Vector3(0.0, -2.0, -3);
    size = vector.Vector3(textBoxWidth, textBoxHeight, 0.1);
    _addTextBox(_arCoreController, discussionPath, position, size, 'disc');

    String artPath = "assets/images/art.png";
    position = vector.Vector3(1.0, -1.0, -3);
    size = vector.Vector3(textBoxWidth, textBoxHeight, 0.1);
    _addTextBox(_arCoreController, artPath, position, size, 'art');
  }

  _arCoreInfoView(ArCoreController _arCoreController) async {

  }
  _arCoreDiscView(ArCoreController _arCoreController) async {

  }
  _arCoreArtView(ArCoreController _arCoreController) async {

  }

  _addTextBox(ArCoreController _arcoreController, String filepath, vector.Vector3 position, vector.Vector3 size, String name) async {
    final Uint8List intList = await getTexture(filepath);
    ArCoreMaterial material = ArCoreMaterial(color: Colors.white, metallic: 1.0, reflectance: 0, roughness: 2.8, textureBytes: intList);
    ArCoreCube cube = ArCoreCube(materials: [material], size: size);
    ArCoreNode node = ArCoreNode(
      shape: cube,
      position: position, // z axis (close / far away)
      name: name,
    );
    arNodes.add(node);
    //_arcoreController.addArCoreNode(node);
  }

  Future<Uint8List> getTexture(String filepath) async {
    ByteData textureBytes = await rootBundle.load(filepath);
    Uint8List resultList = textureBytes.buffer.asUint8List();
    return resultList;
  }

  @override
  void dispose() {
    this.arCoreController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Widget titleSection = Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'George\nWashington\nStatue',
                    style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(0.0, 4.0),
                          blurRadius: 8.0,
                          color: Color.fromARGB(110, 0, 0, 0),
                        ),
                      ],
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget textSection = Container(
      padding: const EdgeInsets.all(32),
      color: Color.fromRGBO(255, 255, 255, 0),
      height: 200,
      width: 1000,
    );

    Widget buttonSection = Container(
        padding: const EdgeInsets.only(left: 32.0),
        child: Row(
          children: [
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Color.fromRGBO(255, 255, 255, 160),
                      child: IconButton(
                        tooltip: 'Information on this monument',
                        color: infoIconColor,
                        padding: EdgeInsets.all(8.0),
                        icon: Icon(Icons.info_outline),
                        iconSize: 40,
                        onPressed: () {
                          getInfo();
                          infoIconColor = Color(0xff315CF4);
                          discIconColor = Colors.white;
                          artIconColor = Colors.white;
                        },
                      ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Color.fromRGBO(255, 255, 255, 160),
                      child: IconButton(
                        tooltip: 'Follow the discussion',
                        color: discIconColor,
                        padding: EdgeInsets.all(8.0),
                        icon: Icon(Icons.forum),
                        iconSize: 40,
                        onPressed: () {
                          getDiscussion();
                          infoIconColor = Colors.white;
                          discIconColor = Color(0xff315CF4);
                          artIconColor = Colors.white;
                        },
                      ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Color.fromRGBO(255, 255, 255, 160),
                      child: IconButton(
                        tooltip: 'Discover artwork',
                        color: artIconColor,
                        padding: EdgeInsets.all(8.0),
                        icon: Icon(Icons.photo_library),
                        iconSize: 40,
                        onPressed: () {
                          getArtwork();
                          infoIconColor = Colors.white;
                          discIconColor = Colors.white;
                          artIconColor = Color(0xff315CF4);
                        },
                      ),
                    )
                ),
              ],
            ),
          ],
        )
    );

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Stack(
                children: [
                  Visibility(
                    child: ArCoreView(
                      onArCoreViewCreated: _arCoreStartView,
                    ),
                    visible: startView,
                  ),
                  Visibility(
                    child: ArCoreView(
                      onArCoreViewCreated: _arCoreInfoView,
                    ),
                    visible: infoView,
                  ),
                  Visibility(
                    child: ArCoreView(
                      onArCoreViewCreated: _arCoreDiscView,
                    ),
                    visible: discView,
                  ),
                  Visibility(
                    child: ArCoreView(
                      onArCoreViewCreated: _arCoreArtView,
                    ),
                    visible: artView,
                  ),
                ]
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleSection,
                  buttonSection,
                  textSection,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedWidget extends StatefulWidget {
  SavedWidget({Key key}) : super(key: key);

  @override
  _SavedWidgetState createState() => _SavedWidgetState();
}

class _SavedWidgetState extends State<SavedWidget> {
  var fini = false;
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  List<Widget> savedPosts = new List<Widget>();

  Future<void> getData() async {
    Firestore.instance.collection('saved').snapshots().listen((data) =>
        data.documents.forEach((saved) =>
            Firestore.instance.collection('monuments').snapshots().listen((data) =>
                data.documents.forEach((monument) => (monument)['id'] == (saved)['mid'] ? storeData((monument)['title'], (monument)['description']) : null))));
    fini = true;
  }

  storeData(String title, String description) {
    Widget post = Container(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Icon(Icons.location_on, size: 60, color: Colors.white),
          ),
          Container(
            width: 290,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 20, top: 20),
                  child: Text(
                    title,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                ),
                Container(
                  child: Text(
                    description,
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white,
                    )
                  ),
                )
              ],
            )
          )
        ]
      )
    );
    setState(() {
      savedPosts.add(post);
    });
  }

  Widget build(BuildContext context) {
    if(!fini) getData();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Saved Monuments'),
          backgroundColor: const Color(0xff315CF4),
          elevation: 0,
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                )
              ),
              onPressed: () {
                _signOut();
              },
            )
          ]
        ),
        body: Column(
          children: savedPosts,
        ),
        backgroundColor: const Color(0xff315CF4),
      ),
    );
  }
}