import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_watermark/image_watermark.dart'; // Import the image_watermark package

class ImageDisplayPage extends StatefulWidget {
  final String imagePath;
  final VoidCallback onRetake;

  const ImageDisplayPage({
    super.key,
    required this.imagePath,
    required this.onRetake,
  });

  @override
  State<ImageDisplayPage> createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  bool _isUploading = false;
  String? _imageUrl;

  Future<void> uploadImage() async {
    File imageFile = File(widget.imagePath);

    // Upload the image to Supabase
    String? imageUrl = await _uploadImageToSupabase(imageFile);
    if (imageUrl != null) {
      setState(() {
        _imageUrl = imageUrl;
      }); // Show the QR code with the image URL
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  Future<String?> _uploadImageToSupabase(File image) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final response = await Supabase.instance.client.storage
          .from('photo-bucket')
          .upload(fileName, image);

      if (response != null || response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image Uploaded Successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed')),
        );
      }

      // Get the public URL of the uploaded image
      final imageUrl = Supabase.instance.client.storage
          .from('photo-bucket')
          .getPublicUrl(fileName);

      return imageUrl; // Return the public URL
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    uploadImage(); // Automatically upload and show QR code
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
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: Hero(
                tag: widget.imagePath,
                child: Image.file(File(widget.imagePath))),
          ),
          Dialog(
            backgroundColor: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(),
            ),
          ),
          _imageUrl != null
              ? QrWidget(
                  url: _imageUrl!,
                  imagePath: widget.imagePath,
                )
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class QrWidget extends StatefulWidget {
  const QrWidget({
    super.key,
    required this.url,
    required this.imagePath,
  });
  final String url;
  final String imagePath;

  @override
  State<QrWidget> createState() => _QrWidgetState();
}

class _QrWidgetState extends State<QrWidget> {
  Future<void> downloadImage() async {
    final response = await ImageGallerySaver.saveFile(widget.imagePath);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(response['isSuccess'] ? 'Image saved' : 'Image not saved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        textAlign: TextAlign.center,
        'Download Image URL',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        height: 300,
        width: 300,
        child: QrImageView(
          data: widget.url,
          version: QrVersions.auto,
          size: 200,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              onPressed: () {
                downloadImage();
              },
            ),
            TextButton(
              child: const Text('Close',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }
}









          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 90),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       ElevatedButton(
          //         style: ButtonStyle(
          //           padding: MaterialStateProperty.all(
          //               EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
          //           backgroundColor: MaterialStateProperty.all(Colors.white70),
          //         ),
          //         onPressed: () {
          //           downloadImage();
          //         },
          //         child: Text(
          //           'Download',
          //           style: TextStyle(color: Colors.black),
          //         ),
          //       ),
          //       ElevatedButton(
          //         style: ButtonStyle(
          //           padding: MaterialStateProperty.all(
          //               EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
          //           backgroundColor: MaterialStateProperty.all(Colors.white70),
          //         ),
          //         onPressed: () {
          //           widget.onRetake();
          //           Navigator.pop(context);
          //         },
          //         child: Text(
          //           'Retake',
          //           style: TextStyle(color: Colors.black),
          //         ),
          //       ),
          //       ElevatedButton(
          //         style: ButtonStyle(
          //           padding: MaterialStateProperty.all(
          //               EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
          //           backgroundColor: MaterialStateProperty.all(Colors.white70),
          //         ),
          //         onPressed: () {
          //           uploadImage();
          //         },
          //         child: Text(
          //           'Upload',
          //           style: TextStyle(color: Colors.black),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),







 // Future<void> downloadImage() async {
  //   final response = await ImageGallerySaver.saveFile(widget.imagePath);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content:
  //           Text(response['isSuccess'] ? 'Image saved' : 'Image not saved'),
  //     ),
  //   );
  // }

  // Future<void> uploadImage() async {
  //   File imageFile = File(widget.imagePath);

  //   // Add watermark to the image
  //   File watermarkedImage = await addWatermark(imageFile, "My Watermark");

  //   // Upload the watermarked image
  //   String? imageUrl = await _uploadImageToSupabase(watermarkedImage);
  //   if (imageUrl != null) {
  //     showQrCode(imageUrl);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to upload image')),
  //     );
  //   }
  // }

 

  // Future<String?> _uploadImageToSupabase(File image) async {
  //   setState(() {
  //     _isUploading = true;
  //   });

  //   try {
  //     final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
  //     final response = await Supabase.instance.client.storage
  //         .from('photo-bucket')
  //         .upload(fileName, image);

  //     setState(() {
  //       _isUploading = false;
  //     });

  //     if (response != null || response.isNotEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Image Uploaded Successfully!')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Upload failed')),
  //       );
  //     }
  //     final imageUrl = Supabase.instance.client.storage
  //         .from('photo-bucket')
  //         .getPublicUrl(fileName);

  //     return imageUrl;
  //   } on Exception catch (e) {
  //     setState(() {
  //       _isUploading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Upload failed!')),
  //     );
  //     print('Error uploading image: $e');
  //   }
  // }

  // Future<File> addWatermark(File imageFile, String watermarkText) async {
  //   // Read the original image as bytes
  //   final imageBytes = await imageFile.readAsBytes();

  //   // Create a watermark
  //   final watermarkedImage = await ImageWatermark.addTextWatermark(
  //     imgBytes: imageBytes,
  //     watermarkText: watermarkText,
  //     color: Colors.white70,
  //     dstX: 500,
  //     dstY: 500,
  //     rightJustify: true,
  //   );

  //   // Save the watermarked image
  //   final watermarkedImageFile =
  //       File(imageFile.path.replaceFirst('.png', '_watermarked.png'));
  //   await watermarkedImageFile.writeAsBytes(watermarkedImage);

  //   return watermarkedImageFile;
  // }
