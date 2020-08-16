import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/rendering.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter AR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ArCoreController arcoreController;
  ArCoreFaceController arCoreFaceController;

  Uint8List textureList;
  File imageFile;

  _onArCoreViewCreated(ArCoreController arcoreController) async {
//    arCoreController = _arcoreController;

    arcoreController.init();
    _addCube(arcoreController);
//    _addSphere(arcoreController);

//    _addCyclinder(arcoreController);
//    _addText(arcoreController);
  }

  _addText(ArCoreController _arcoreController) {

//    final node = ArCoreNode(
//      shape: ArCorePlane(extendX: 0.3, extendZ: 0.3, type: ArCorePlaneType.VERTICAL);
//    )
  }

//  void _onArCoreViewCreated(ArCoreFaceController controller) {
//    arCoreFaceController = controller;
//    loadMesh();
//  }
//
//  loadMesh() async {
//    final ByteData textureBytes =
//    await rootBundle.load('resources/images/black.png');
//
//    arCoreFaceController.loadMesh(
//      textureBytes: textureBytes.buffer.asUint8List(),
//      skin3DModelFilename: "tt.sfb",
//    );
//  }



  _addSphere(ArCoreController _arcoreController) {

    final material = ArCoreMaterial(color: Colors.deepPurple);
    final sphere = ArCoreSphere(materials: [material], radius: 0.2);
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(
        0,
        0,
        -1,
      ),
    );

    _arcoreController.addArCoreNode(node);
  }


  _addCube(ArCoreController _arcoreController) async {
    final Uint8List intList = await getTexture();
    final material = ArCoreMaterial(color: Colors.amber, metallic: 0, reflectance: 0, roughness: 0, textureBytes: intList);
//    final material = ArCoreMaterial(color: Colors.pink, metallic: 1);
    final cube =
        ArCoreCube(materials: [material], size: vector.Vector3(0.8, 0.8, 0.1));
    final node = ArCoreNode(
      shape: cube,
      position: vector.Vector3(
        -0.5,
        -1.0,
        -2.0, // z axis (close / far away)
      ),
    );

    _arcoreController.addArCoreNode(node);
  }

  Future<Uint8List> getTexture() async {
    ByteData textureBytes = await rootBundle.load('assets/images/text.png');
    Uint8List resultList = textureBytes.buffer.asUint8List();
    return resultList;
  }

  @override
  void dispose() {
    this.arcoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
    );
  }

//  Future _loadEverything() async {
//    await _requestAppDocumentsDirectory();   // TODO: 2 - GET APP DOCUMENTS DIRECTORY
//    _dekontExist = await makeReceiptImage(); // TODO: 3 - MAKE A RECEIPT
//
//    // Show the writen image
//    if (_dekontExist == true) {
//      setState(() {
//        newDekontImage = _appDocumentsDirectory + "/" + widget._currentUserReceiptNo + ".jpg";
//        imageOkay = true; // FOR - 4 - MAIN WIDGET BUILD
//      });
//    }
//  }


}
