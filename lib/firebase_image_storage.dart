import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImgStorage extends StatefulWidget {
  const ImgStorage({super.key});

  @override
  State<ImgStorage> createState() => _ImgStorageState();
}

class _ImgStorageState extends State<ImgStorage> {
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    //var status = Permission.camera.status;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Center(
          child: Text(
            "Store and retrieve images",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                fontSize: 24),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton.icon(
                onPressed: () async {
                  if (await Permission.camera.request().isGranted) {
                    open("camera");
                  } else {
                    print("Camera access denied");
                  }
                },
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  "Camera",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withOpacity(.3)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (await Permission.storage.request().isGranted) {
                    open("gallery");
                  } else {
                    print("Gallery access denied");
                  }
                },
                icon: const Icon(
                  Icons.photo_camera_back_outlined,
                  color: Colors.white,
                ),
                label: const Text("Gallery",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withOpacity(.3)),
              ),
            ]),
            const Divider(
              thickness: 4,
              color: Colors.purple,
            ),
            Expanded(
                child: FutureBuilder(
                    future: fetchImages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return GridView.builder(
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final image = snapshot.data![index];
                            return Card(
                              child: Column(
                                children: [
                                  Expanded(
                                      child: Image.network(image['imageUrl'])),
                                  Text(image['uploaded_by']),
                                  Text(image["time"]),
                                  MaterialButton(
                                    onPressed: () => deleteImage(image['path']),
                                    minWidth: 150,
                                    color: Colors.redAccent,
                                    shape: const StadiumBorder(),
                                    child: const Text('Delete'),
                                  )
                                ],
                              ),
                            );
                          },
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }))
          ],
        ),
      ),
    );
  }

  Future<void> open(String imgSource) async {
    final imgPicker = ImagePicker();
    XFile? pickedImage;

    try {
      pickedImage = await imgPicker.pickImage(
          source:
              imgSource == "camera" ? ImageSource.camera : ImageSource.gallery);
      final String imgFileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        await storage.ref(imgFileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              "uploaded_by": "xxxxxxxx",
              "time": "${DateTime.now().isUtc}"
            }));
      } on FirebaseException catch (error) {
        print("Exception occurred while uploading picture $error");
      }
    } catch (error) {
      print("Exception during File fetching $error");
    }
  }

  Future<List<Map<String, dynamic>>> fetchImages() async {
    List<Map<String, dynamic>> images = [];
    //ListResult class holds the list od values and it's metadatas as a result of list listAll
    final ListResult result = await storage.ref().list();
    //Reference of each items stored in firebase storage
    final List<Reference> allFiles = result.items;
    await Future.forEach(allFiles, (singleFile) async {
      final String fileUrl = await singleFile.getDownloadURL();
      final FullMetadata metadata = await singleFile.getMetadata();

      images.add({
        "imageUrl": fileUrl,
        "path": singleFile.fullPath,
        "uploaded_by": metadata.customMetadata?["uploaded_by"] ?? "NoData",
        "time": metadata.customMetadata?["time"] ?? "NoData",
      });
    });
    return images;
  }

  Future<void> deleteImage(String imagepath) async {
    await storage.ref(imagepath).delete();
    setState(() {});
  }
}
