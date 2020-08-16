import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;


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

  _onArCoreViewCreated(ArCoreController arcoreController) async {

      String infoPath = "assets/images/info.png";
      vector.Vector3 position = vector.Vector3(-0.5, -1.0, -1.8);
      vector.Vector3 size = vector.Vector3(1.2, 0.8, 0.1);
      _addTextBox(arcoreController, infoPath, position, size);

      String artPath = "assets/images/art.png";
      position = vector.Vector3(1.0, -1.0, -1.8);
      size = vector.Vector3(1.2, 0.8, 0.1);
      _addTextBox(arcoreController, artPath, position, size);
  }

  _addTextBox(ArCoreController _arcoreController, String filepath, vector.Vector3 position, vector.Vector3 size) async {
    final Uint8List intList = await getTexture(filepath);
    final material = ArCoreMaterial(color: Colors.white, metallic: 1.0, reflectance: 0, roughness: 2.8, textureBytes: intList);
    final cube =
        ArCoreCube(materials: [material], size: size);
    final node = ArCoreNode(
      shape: cube,
      position: position, // z axis (close / far away)
    );

    _arcoreController.addArCoreNode(node);
  }

  Future<Uint8List> getTexture(String filepath) async {
    ByteData textureBytes = await rootBundle.load(filepath);
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



}
