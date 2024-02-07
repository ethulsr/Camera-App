import 'dart:typed_data';
import 'package:camera_app/adapterfunction.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService extends DBAdapter {
  @override
  Future<List<Uint8List>> showImages() async {
    var box = await Hive.openBox('imageBox');

    List<Uint8List> images = box.get('images')?.cast<Uint8List>() ?? [];

    return images;
  }

  @override
  Future<void> storeImage(Uint8List imageBytes) async {
    var box = await Hive.box('imageBox');

    List<Uint8List> images = box.get('images')?.cast<Uint8List>() ?? [];

    images.add(imageBytes);
    await box.put("images", images);
  }
}
