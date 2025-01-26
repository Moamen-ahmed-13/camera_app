import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ImageDisplayPage extends StatefulWidget {
  final String imagePath;
  final VoidCallback onRetake;

  const ImageDisplayPage(
      {super.key, required this.imagePath, required this.onRetake});

  @override
  State<ImageDisplayPage> createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  Future<void> downloadImage() async {
    final response = await ImageGallerySaver.saveFile(widget.imagePath!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(response['isSuccess'] ? 'Image saved' : 'Image not saved'),
      ),
    );
  }

  void showQrCode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Download Image'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: QrImageView(
              data: widget.imagePath,
              version: QrVersions.auto,
              size: 200,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: Image.file(File(widget.imagePath)),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    downloadImage();
                    showQrCode();
                  },
                  child: Text('Download'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onRetake();
                    Navigator.pop(context);
                  },
                  child: Text('Retake'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

                             


// Column(
//                 children: [
//                   if (imagePath != null)
//                     Column(
//                       children: [
//                         Container(
//                             height: 200,
//                             width: 200,
//                             child:
//                                 Image.file(File(imagePath!), fit: BoxFit.cover)),
//                         QrImageView(
//                           data: imagePath!,
//                           version: QrVersions.auto,
//                           size: 200.0,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             ElevatedButton(
//                               onPressed: downloadImage,
//                               child: Text('Download'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () {
//                                 setState(() {
//                                   imagePath = null;
//                                 });
//                                 captureImage();
//                               },
//                               child: Text('Retake'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                       ],
//                     );