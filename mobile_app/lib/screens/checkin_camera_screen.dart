import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CheckInCameraScreen extends StatefulWidget {
  @override
  _CheckInCameraScreenState createState() => _CheckInCameraScreenState();
}

class _CheckInCameraScreenState extends State<CheckInCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture) return;
    
    try {
      setState(() => _isTakingPicture = true);
      await _initializeControllerFuture;
      
      final image = await _controller!.takePicture();
      
      // Trả đường dẫn ảnh về màn hình trước
      Navigator.pop(context, image.path);
      
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() => _isTakingPicture = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chụp ảnh điểm danh')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(child: CameraPreview(_controller!)),
                Container(
                  padding: EdgeInsets.all(20),
                  child: FloatingActionButton(
                    onPressed: _takePicture,
                    child: _isTakingPicture 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(Icons.camera),
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
