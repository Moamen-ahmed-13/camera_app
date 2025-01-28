import 'package:camera/camera.dart';
import 'package:camera_app/screens/camera_preview.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  await Supabase.initialize(
    url: 'https://dfhjoaazooyocmzfpsdu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmaGpvYWF6b295b2NtemZwc2R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcyODQyMzEsImV4cCI6MjA1Mjg2MDIzMX0.R9LYowbFY0ezBC-m7ZDPY5FMrxMXWKCtZCHIpGFml-U',
  );
  runApp(MyApp(cameras: cameras,));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyCameraApp(cameras: cameras,),
    );
  }
}

