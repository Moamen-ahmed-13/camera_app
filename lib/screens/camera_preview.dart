import 'package:camera/camera.dart';
import 'package:camera_app/screens/gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:image_watermark/image_watermark.dart'; // Import for watermarking
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for Supabase

class MyCameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MyCameraApp({super.key, required this.cameras});

  @override
  _MyCameraAppState createState() => _MyCameraAppState();
}

class _MyCameraAppState extends State<MyCameraApp> {
  late CameraController _controller;
  late Future<void> cameraValue;
  List<File> imagesList = [];
  bool isCapturing = false;
  bool isFlashOn = false;
  bool isRearCamera = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    startCamera(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startCamera(int camera) {
    _controller = CameraController(
      widget.cameras[camera],
      ResolutionPreset.max,
      enableAudio: false,
    );
    cameraValue = _controller.initialize();
  }

  void captureImage() async {
    await cameraValue;
    setState(() {
      isCapturing = true;
    });

    if (isFlashOn) {
      await _controller.setFlashMode(FlashMode.torch);
    } else {
      await _controller.setFlashMode(FlashMode.off);
    }

    final XFile image = await _controller.takePicture();
    final file = await saveImage(image);
    final watermarkedFile = await addWatermark(file, "My Watermark");

    // Upload watermarked image to Supabase
    // await _uploadImageToSupabase(watermarkedFile);

    setState(() {
      imagesList.add(watermarkedFile);
      isCapturing = false;
    });
  }

  Future<File> saveImage(XFile image) async {
    final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOADS,
    );
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$downloadPath/$fileName');

    await file.writeAsBytes(await image.readAsBytes());
    return file;
  }

  Future<File> addWatermark(File imageFile, String watermarkText) async {
    // Read the original image as bytes
    final imageBytes = await imageFile.readAsBytes();

    // Create a watermark
    final watermarkedImage = await ImageWatermark.addTextWatermark(
      imgBytes: imageBytes,
      watermarkText: watermarkText,
      color: Colors.white70,
      dstX: 500,
      dstY: 500,
      rightJustify: true,
    );

    // Save the watermarked image
    final watermarkedImageFile =
        File(imageFile.path.replaceFirst('.png', '_watermarked.png'));
    await watermarkedImageFile.writeAsBytes(watermarkedImage);

    return watermarkedImageFile;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: CircleBorder(),
        onPressed: captureImage,
        child: const Icon(
          Icons.camera_alt,
          size: 40,
          color: Colors.black87,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: size.width,
                  height: size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      child: CameraPreview(_controller),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PhotoGalleryScreen(imagesList: imagesList),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/vector-design-of-gallery-icon-M9KWWD.jpg'),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}











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


// import 'package:camera/camera.dart';
// import 'package:camera_app/screens/photo_page.dart';
// import 'package:flutter/material.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'dart:io';
// import 'package:external_path/external_path.dart';
// import 'package:image_watermark/image_watermark.dart';

// class MyCameraApp extends StatefulWidget {
//   @override
//   _MyCameraAppState createState() => _MyCameraAppState();
//   final List<CameraDescription> cameras;

//   const MyCameraApp({super.key, required this.cameras});
// }

// class _MyCameraAppState extends State<MyCameraApp> {
//   late CameraController _controller;
//   late Future<void> cameraValue;
//   String? imagePath;
//   bool isCapturing = false;
//   List<File> imagesList = [];
//   bool isFlashOn = false;
//   bool isRearCamera = true;

//   @override
//   void initState() {
//     super.initState();
//     startCamera(0);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void startCamera(int camera) {
//     _controller = CameraController(
//       widget.cameras[camera],
//       ResolutionPreset.max,
//       enableAudio: false,
//     );
//     cameraValue = _controller.initialize();
//   }

//   void captureImage() async {
//     await cameraValue;
//     setState(() {
//       isCapturing = true;
//     });
//     for (var i = 0; i < 3; i++) {
//       await Future.delayed(const Duration(seconds: 1));
//       print(i);
//     }
//     if (isFlashOn == false) {
//       await _controller.setFlashMode(FlashMode.off);
//     } else {
//       await _controller.setFlashMode(FlashMode.torch);
//     }

//     if (_controller.value.flashMode == FlashMode.torch) {
//       setState(() {
//         _controller.setFlashMode(FlashMode.off);
//       });
//     }
//     final XFile image = await _controller.takePicture();
//     imagePath = image.path;
//     // Save the image and add a watermark
//     final file = await saveImage(image);
//     final watermarkedFile = await addWatermark(file, "My Watermark");

//     setState(() {
//       imagesList.add(watermarkedFile);
//     });

//     setState(() {
//       isCapturing = false;
//     });
//   }

//   Future<File> addWatermark(File imageFile, String watermarkText) async {
//     // Read the original image as bytes
//     final imageBytes = await imageFile.readAsBytes();

//     // Create a watermark
//     final watermarkedImage = await ImageWatermark.addTextWatermark(
//       imgBytes: imageBytes,
//       watermarkText: watermarkText,
//       color: Colors.white70,
//       dstX: 500,
//       dstY: 500,
//       rightJustify: true,
//     );

//     // Save the watermarked image
//     final watermarkedImageFile =
//         File(imageFile.path.replaceFirst('.png', '_watermarked.png'));
//     await watermarkedImageFile.writeAsBytes(watermarkedImage);

//     return watermarkedImageFile;
//   }

//   Future<File> saveImage(XFile image) async {
//     final downlaodPath = await ExternalPath.getExternalStoragePublicDirectory(
//         ExternalPath.DIRECTORY_DOWNLOADS);
//     final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
//     final file = File('$downlaodPath/$fileName');

//     try {
//       await file.writeAsBytes(await image.readAsBytes());
//     } catch (_) {}

//     return file;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: Colors.black,
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.white,
//         shape: CircleBorder(),
//         onPressed: captureImage,
//         child: const Icon(
//           Icons.camera_alt,
//           size: 40,
//           color: Colors.black87,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       body: Stack(
//         children: [
//           FutureBuilder<void>(
//             future: cameraValue,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 return SizedBox(
//                   width: size.width,
//                   height: size.height,
//                   child: FittedBox(
//                     fit: BoxFit.cover,
//                     child: SizedBox(
//                       width: 100,
//                       child: CameraPreview(_controller),
//                     ),
//                   ),
//                 );
//               } else {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }
//             },
//           ),
//           SafeArea(
//             child: Align(
//               alignment: Alignment.topRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 5, top: 10),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isFlashOn = !isFlashOn;
//                         });
//                       },
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           color: Color.fromARGB(50, 0, 0, 0),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: isFlashOn
//                               ? const Icon(
//                                   Icons.flash_on,
//                                   color: Colors.white,
//                                   size: 30,
//                                 )
//                               : const Icon(
//                                   Icons.flash_off,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isRearCamera = !isRearCamera;
//                         });
//                         isRearCamera ? startCamera(0) : startCamera(1);
//                       },
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           color: Color.fromARGB(50, 0, 0, 0),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: isRearCamera
//                               ? const Icon(
//                                   Icons.camera_rear,
//                                   color: Colors.white,
//                                   size: 30,
//                                 )
//                               : const Icon(
//                                   Icons.camera_front,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomLeft,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 7, bottom: 75),
//                     child: Container(
//                       height: 130,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: imagesList.length,
//                         scrollDirection: Axis.horizontal,
//                         itemBuilder: (BuildContext context, int index) {
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ImageDisplayPage(
//                                       imagePath: imagesList[index].path,
//                                       onRetake: () {
//                                         setState(() {
//                                           imagesList.clear();
//                                         });
//                                       }),
//                                 ),
//                               );
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 5, vertical: 15),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image(
//                                   height: 100,
//                                   width: 100,
//                                   opacity: const AlwaysStoppedAnimation(07),
//                                   image: FileImage(
//                                     File(imagesList[index].path),
//                                   ),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
