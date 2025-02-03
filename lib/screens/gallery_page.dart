import 'dart:io';

import 'package:camera_app/screens/photo_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoGalleryScreen extends StatefulWidget {
  final List<File> imagesList;

  const PhotoGalleryScreen({Key? key, required this.imagesList})
      : super(key: key);

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Gallery', style: TextStyle(color: Colors.white70)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns in the grid
          childAspectRatio: 1, // Aspect ratio of each grid item
        ),
        itemCount: widget.imagesList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageDisplayPage(
                    imagePath: widget.imagesList[index].path,
                    onRetake: () {
                      Navigator.pop(context); // Go back to the gallery
                    },
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Hero(
                tag: widget.imagesList[index].path,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.imagesList[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
