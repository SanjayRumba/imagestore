import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/imageListPage.dart';
import 'package:photo_gallery/imageUplodaPage.dart';
import 'package:photo_gallery/image_viewmodel.dart';
import 'package:photo_gallery/splasscreen.dart';
import 'package:provider/provider.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:const FirebaseOptions(
    apiKey: "AIzaSyDayhHKhuNAturje4euckbM0MBwy11yXzk", 
    appId: "1:958541243459:web:b965ae01e9fc058f2660f6", 
    messagingSenderId: "958541243459", 
    projectId: "image-storage-a2874",
    storageBucket: "image-storage-a2874.appspot.com",
    )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ImageViewModel(),
      child: MaterialApp(
        title: 'Image Storage Web App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
        routes: {
          '/imageList': (context) => ImageListPage(),
          '/imageUpload': (context) => ImageUploadPage(),
        },
      ),
    );
  }
}
