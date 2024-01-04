import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final TextEditingController _imageNameController = TextEditingController();
  html.File? _selectedFile;
  ui.Image? _selectedImage;

  Future<Uint8List> _readFileAsBytes(html.File file) async {
    final html.FileReader reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return Uint8List.fromList(List<int>.from(reader.result as List<int>));
  }

  Future<ui.Image?> _loadImage() async {
    if (_selectedFile != null) {
      final Uint8List data = await _readFileAsBytes(_selectedFile!);
      final Completer<ui.Image> completer = Completer();

      ui.decodeImageFromList(data, (result) {
        completer.complete(result);
      });

      return completer.future;
    }
    return null;
  }

  Future<void> _uploadImage(BuildContext context) async {
     print('Entering _uploadImage');
    if (_imageNameController.text.trim().isEmpty) {
      print('Image name cannot be empty');
      return;
    }

    await _performUpload(context);
  }

Future<void> _performUpload(BuildContext context) async {
  final String imageName = _imageNameController.text.trim();
  final Uint8List data = await _readFileAsBytes(_selectedFile!);

  final String imagePath = 'images/$imageName.png'; // Change the path as needed

  try {
    final UploadTask task = FirebaseStorage.instance.ref(imagePath).putData(data);
    await task.whenComplete(() {
      print('Image uploaded');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image uploaded successfully!'),
        ),
      );
    });


    Navigator.pop(context);
  } catch (e) {
    print('Error uploading image: $e');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error uploading image: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  Future<void> _pickImage(BuildContext context) async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.click();

    await input.onChange.first;

    final html.File file = input.files!.first;
    setState(() {
      _selectedFile = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(context),
                  child: Text("Select & Upload Image"),
                ),
                SizedBox(height: 20),
                _buildImageWidget(), // Extracted widget for displaying the image
                SizedBox(height: 20),
                TextField(
                  controller: _imageNameController,
                  decoration: InputDecoration(labelText: "Enter Image Name"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _uploadImage(context);
                  },
                  child: Text("Upload"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return FutureBuilder<ui.Image?>(
      future: _loadImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _selectedImage = snapshot.data;
          if (_selectedImage != null) {
            return FutureBuilder<Uint8List?>(
              future: _imageToByteList(_selectedImage!),
              builder: (context, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.done && dataSnapshot.data != null) {
                  return Image.memory(dataSnapshot.data!);
                } else {
                  return Container();
                }
              },
            );
          } else {
            return Container();
          }
        } else if (snapshot.hasError) {
          return Text("Error loading image");
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<Uint8List?> _imageToByteList(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
