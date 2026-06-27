import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class LiveScannerScreen extends StatefulWidget {
  const LiveScannerScreen({Key? key}) : super(key: key);

  @override
  State<LiveScannerScreen> createState() => _LiveScannerScreenState();
}

class _LiveScannerScreenState extends State<LiveScannerScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  
  late AnimationController _animationController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _initCamera();
    
    // Setup laser animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        debugPrint('No cameras found.');
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scan() async {
    // Simulate capturing and AI processing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing Image with AI Model...'), duration: Duration(seconds: 1)),
    );
    
    await Future.delayed(const Duration(seconds: 2)); // Mock processing time
    
    if (mounted) {
      Navigator.pop(context, 'Indian Mackerel'); // Return mocked species detection
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Species Scanner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (_isCameraInitialized && _controller != null)
            CameraPreview(_controller!)
          else
            const Center(child: CircularProgressIndicator(color: Color(0xFF00796B))),
          
          // Dark Overlay with transparent cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.srcOut),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.red, // This becomes transparent due to BlendMode
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Scanner UI (Corners & Laser)
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 300,
              width: 300,
              child: Stack(
                children: [
                  // Corner indicators
                  CustomPaint(
                    size: const Size(300, 300),
                    painter: ScannerOverlayPainter(),
                  ),
                  // Animated Laser line
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _laserAnimation.value * 290,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676), // Bright Green
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Center the fish inside the frame',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                FloatingActionButton.large(
                  onPressed: _isCameraInitialized ? _scan : null,
                  backgroundColor: const Color(0xFF00796B),
                  child: const Icon(Icons.document_scanner, color: Colors.white, size: 36),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double length = 40.0;
    final double radius = 24.0;

    // Top Left
    canvas.drawArc(Rect.fromLTWH(0, 0, radius * 2, radius * 2), 3.14, 1.57, false, paint);
    canvas.drawLine(Offset(0, radius), Offset(0, length), paint);
    canvas.drawLine(Offset(radius, 0), Offset(length, 0), paint);

    // Top Right
    canvas.drawArc(Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2), -1.57, 1.57, false, paint);
    canvas.drawLine(Offset(size.width, radius), Offset(size.width, length), paint);
    canvas.drawLine(Offset(size.width - radius, 0), Offset(size.width - length, 0), paint);

    // Bottom Left
    canvas.drawArc(Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2), 1.57, 1.57, false, paint);
    canvas.drawLine(Offset(0, size.height - radius), Offset(0, size.height - length), paint);
    canvas.drawLine(Offset(radius, size.height), Offset(length, size.height), paint);

    // Bottom Right
    canvas.drawArc(Rect.fromLTWH(size.width - radius * 2, size.height - radius * 2, radius * 2, radius * 2), 0, 1.57, false, paint);
    canvas.drawLine(Offset(size.width, size.height - radius), Offset(size.width, size.height - length), paint);
    canvas.drawLine(Offset(size.width - radius, size.height), Offset(size.width - length, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
