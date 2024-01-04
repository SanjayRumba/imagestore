import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_gallery/image_model.dart';

class ImageViewModel with ChangeNotifier {
  List<ImageModel> _imageList = [];

  List<ImageModel> get imageList => _imageList;

Future<void> fetchImages() async {
  try {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('images').get();

    print('Fetched ${snapshot.docs.length} documents');

    _imageList = snapshot.docs
        .map((doc) => ImageModel(
              name: doc['name'],
              imagePath: doc['imagePath'],
            ))
        .toList();

    print('Parsed ${_imageList.length} images');

    notifyListeners();
  } catch (e) {
    print('Error fetching images: $e');
  }
}



  void addImage(ImageModel image) {
    _imageList.add(image);
    notifyListeners();
  }
}
