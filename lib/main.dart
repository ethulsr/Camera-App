import 'dart:typed_data';

import 'package:camera_app/functions.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Gallery'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HiveService adapter = HiveService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Uint8List>?>(
        future: _readImagesFromDatabase(),
        builder: (context, AsyncSnapshot<List<Uint8List>?> snapshot) {
          if (snapshot.hasError) {
            return Text("Error appeared ${snapshot.error}");
          }

          if (snapshot.hasData) {
            if (snapshot.data == null) return const Text("Nothing to show");

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 5,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => Image.memory(
                snapshot.data![index],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Increment',
        child: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }

  Future<void> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    Uint8List imageBytes = await image.readAsBytes();
    setState(() {
      adapter.storeImage(imageBytes);
    });
  }

  Future<List<Uint8List>?> _readImagesFromDatabase() async {
    return adapter.showImages();
  }
}
