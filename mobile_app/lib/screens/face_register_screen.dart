import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

enum LivenessStep {
  initial,
  turnLeft,
  turnRight,
  lookStraight,
  readyToCapture,
}

class FaceRegisterScreen extends StatefulWidget {
  @override
  _FaceRegisterScreenState createState() => _FaceRegisterScreenState();
}

class _FaceRegisterScreenState extends State<FaceRegisterScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessingImage = false;
  final ApiService _apiService = ApiService();
  
  // Face Detector
  late FaceDetector _faceDetector;
  LivenessStep _currentStep = LivenessStep.initial;
  String _instructionText = "Vui lòng nhìn thẳng vào camera";
  
  // Progress
  double _progress = 0.0;
  bool _isCaptured = false;

  @override
  void initState() {
    super.initState();
    _initFaceDetector();
    _initCamera();
  }

  void _initFaceDetector() {
    final options = FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: false,
      enableContours: false,
      enableTracking: true, // Enable tracking to keep consistent ID
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
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
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    _isCameraInitialized = true;
    if (mounted) setState(() {});

    _controller!.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingImage || _isCaptured) return;
    _isProcessingImage = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isNotEmpty) {
        _checkLiveness(faces.first);
      } else {
         if (mounted && _currentStep != LivenessStep.initial) {
             setState(() {
                 _instructionText = "Không tìm thấy khuôn mặt";
             });
         }
      }
    } catch (e) {
      print("Error processing face: $e");
    } finally {
      _isProcessingImage = false;
    }
  }

   void _checkLiveness(Face face) {
    if (_isCaptured) return;

    // Head Euler Angle Y: Rotation around vertical axis (Looking Left/Right)
    // Left: > 10, Right: < -10 (Adjust thresholds as needed)
    // Note: Android mirrors front camera preview usually, so values might be flipped visually. 
    // Let's test standard values:
    // Left: Positive Y
    // Right: Negative Y
    final double? rotY = face.headEulerAngleY;
    
    if (rotY == null) return;

    if (mounted) {
      setState(() {
        switch (_currentStep) {
          case LivenessStep.initial:
            if (rotY.abs() < 10) {
              _currentStep = LivenessStep.turnLeft;
              _instructionText = "Bước 1: Quay từ từ sang TRÁI";
              _progress = 0.25;
            }
            break;
            
          case LivenessStep.turnLeft:
            if (rotY > 30) { // Đã quay trái đủ
               _currentStep = LivenessStep.turnRight;
               _instructionText = "Tốt! Bước 2: Quay từ từ sang PHẢI";
               _progress = 0.5;
            }
            break;
            
          case LivenessStep.turnRight:
            if (rotY < -30) { // Đã quay phải đủ
               _currentStep = LivenessStep.lookStraight;
               _instructionText = "Tuyệt vời! Bước 3: Nhìn thẳng vào Camera";
               _progress = 0.75;
            }
            break;
            
          case LivenessStep.lookStraight:
             if (rotY.abs() < 10) {
               _currentStep = LivenessStep.readyToCapture;
               _instructionText = "Giữ nguyên! Đang chụp ảnh...";
               _progress = 1.0;
               _autoCapture();
             }
            break;
            
          case LivenessStep.readyToCapture:
            // Do nothing, waiting for capture
            break;
        }
      });
    }
  }

  Future<void> _autoCapture() async {
    if (_isCaptured) return;
    _isCaptured = true;

    try {
      // Dừng stream để chụp ảnh full resolution
      await _controller!.stopImageStream();
      
      // Delay a bit for stability
      await Future.delayed(Duration(milliseconds: 500));
      
      final XFile image = await _controller!.takePicture();
      
       // Upload Logic
       await _uploadFace(image.path);

    } catch (e) {
      print(e);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi chụp ảnh: $e')));
         _resetProcess();
      }
    }
  }

  Future<void> _uploadFace(String filePath) async {
       final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson == null) return;
      final user = jsonDecode(userJson);

      print('Sending photo for user: ${user['id']}');

      final result = await _apiService.registerFace(user['id'].toString(), filePath);

      if (mounted) {
        if (result['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng ký khuôn mặt thành công!')));
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Lỗi đăng ký')));
          _resetProcess();
        }
      }
  }

  void _resetProcess() async {
     _isCaptured = false;
     _currentStep = LivenessStep.initial;
     _progress = 0.0;
     _instructionText = "Vui lòng nhìn thẳng vào camera";
     await _controller!.startImageStream(_processCameraImage);
     setState(() {});
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    
    final  orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
    };
    
    // final rotationCompensation = (sensorOrientation - orientations[_controller!.value.deviceOrientation]! + 360) % 360;
    // Simplification for portrait mode usually used in mobile apps
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
     if (format == null) return null; // NV21 for Android

    final bytes = _concatenatePlanes(image.planes);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // Android rotation
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  @override
  void dispose() {
    _faceDetector.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký Khuôn mặt')),
      body: Column(
        children: [
          Expanded(
            child: _isCameraInitialized 
              ? CameraPreview(_controller!)
              : Center(child: CircularProgressIndicator()),
          ),
          Container(
             color: Colors.black87,
             padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
             child: Column(
               children: [
                 Text(
                   _instructionText,
                   style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                   textAlign: TextAlign.center,
                 ),
                 SizedBox(height: 20),
                 LinearProgressIndicator(value: _progress, minHeight: 10),
                 SizedBox(height: 10),
                 Text(
                   "Trạng thái: ${_currentStep.name.toUpperCase()}",
                   style: TextStyle(color: Colors.grey, fontSize: 12),
                 )
               ],
             ),
          )
        ],
      ),
    );
  }
}
