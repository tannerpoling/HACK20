import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;
//import 'package:path_provider/path_provider.dart';
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

  _onArCoreViewCreated(ArCoreController _arcoreController) {
//    arCoreController = _arcoreController;
    _addSphere(arcoreController);
    _addCube(arcoreController);
    _addCyclinder(arcoreController);
    _addText(arcoreController);
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

    this.arcoreController.addArCoreNode(node);
  }

  _addCyclinder(ArCoreController _arcoreController) {
    final material = ArCoreMaterial(color: Colors.green, reflectance: 1);
    final cylinder =
        ArCoreCylinder(materials: [material], radius: 0.4, height: 0.3);
    final node = ArCoreNode(
      shape: cylinder,
      position: vector.Vector3(
        0,
        -2.5,
        -3.0,
      ),
    );

    this.arcoreController.addArCoreNode(node);
  }

  _addCube(ArCoreController _arcoreController) {
    final material = ArCoreMaterial(color: Colors.pink, metallic: 1);
    final cube =
        ArCoreCube(materials: [material], size: vector.Vector3(1, 1, 1));
    final node = ArCoreNode(
      shape: cube,
      position: vector.Vector3(
        -0.5,
        -0.5,
        -3,
      ),
    );

    this.arcoreController.addArCoreNode(node);
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
}
