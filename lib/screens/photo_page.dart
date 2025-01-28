import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageDisplayPage extends StatefulWidget {
  final String imagePath;
  final VoidCallback onRetake;

  const ImageDisplayPage(
      {super.key, required this.imagePath, required this.onRetake});

  @override
  State<ImageDisplayPage> createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  bool _isUploading = false;

  Future<void> downloadImage() async {
    final response = await ImageGallerySaver.saveFile(widget.imagePath!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(response['isSuccess'] ? 'Image saved' : 'Image not saved'),
      ),
    );
  }

  Future<void> uploadImageAndshowQr() async {
    String? imageUrl = await _uploadImageToSupabase();
    if (imageUrl != null) {
      showQrCode(imageUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  void showQrCode(String url) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Download Image Url'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: QrImageView(
              data: url,
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

  Future<String?> _uploadImageToSupabase() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final response = await Supabase.instance.client.storage
          .from('photo-bucket')
          .upload(fileName, File(widget.imagePath));

      setState(() {
        _isUploading = false;
      });

      if (response != null || response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image Uploaded Successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed'),
          ),
        );
      }
      final imageUrl = Supabase.instance.client.storage
          .from('photo-bucket')
          .getPublicUrl(fileName);

      return imageUrl;
    } on Exception catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed!'),
        ),
      );
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: const Text('Image Preview',
              style: TextStyle(color: Colors.white70)),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          )),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: Image.file(File(widget.imagePath)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 90),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.white70)),
                  onPressed: () {
                    downloadImage();
                  },
                  child: Text(
                    'Download',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.white70)),
                  onPressed: () {
                    widget.onRetake();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Retake',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
                      backgroundColor: WidgetStateProperty.all(Colors.white70)),
                  onPressed: () {
                    uploadImageAndshowQr();
                  },
                  child: Text(
                    'Upload',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
