import 'package:flutter/material.dart';
import 'package:photo_gallery/imageUplodaPage.dart';
import 'package:provider/provider.dart';
import 'image_viewmodel.dart';

class ImageListPage extends StatefulWidget {
  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  late Future<void> _fetchImagesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch images when the widget is initialized
    _fetchImagesFuture = Provider.of<ImageViewModel>(context, listen: false).fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image List"),
      ),
      body: FutureBuilder(
        future: _fetchImagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading images: ${snapshot.error}"));
          } else {
            var imageViewModel = Provider.of<ImageViewModel>(context);
            return ListView.builder(
              itemCount: imageViewModel.imageList.length,
              itemBuilder: (context, index) {
                var image = imageViewModel.imageList[index];
                return ListTile(
                  title: Text(image.name),
                  leading: Image.network(image.imagePath),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageUploadPage(),
            ),
          ).then((value) {

            if (value != null && value is bool && value) {

              setState(() {
                _fetchImagesFuture = Provider.of<ImageViewModel>(context, listen: false).fetchImages();
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
