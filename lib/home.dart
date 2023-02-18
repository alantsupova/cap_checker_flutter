import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _loading = true;
  late File _image;
  final imagepicker = ImagePicker();
  List _prediction = [];

  @override
  void initState()  {
    super.initState();
    loadmodel();
  }

  loadmodel() async {
    return await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  detect_image(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _loading = false;
      _prediction = prediction!;
    });
  }

  @override
  void dispose() async {
    super.dispose();
  }

  _loadingimage_gallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image);
  }

  _loadingimage_camera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    var i = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[200],
        title: Text("Cap checker"),
      ),
      body: Container(
        height: h,
        width: w,
        color: Colors.red[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              color: Colors.pink[50],
              child: Image.asset('assets/cap.png'),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  _loadingimage_camera();
                },
                child: Text('Camera'),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  _loadingimage_gallery();
                },
                child: Text('Gallery'),
              ),
            ),
            _loading == false
                ? Container(
                    padding: EdgeInsets.all(10),
                    height: 200,
                    width: 200,
                    child: Column(children: [
                      Image.file(_image),
                      Padding(
                        padding: EdgeInsets.all(
                            15), //apply padding to all four sides
                        child: Text(
                            _prediction[0]['label'].toString().substring(2)),
                      ),
                    ]))
                : Container()
          ],
        ),
      ),
    );
  }
}
