import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({Key? key, required this.onInitializationComplete})
      : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>   
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller for 60 seconds
    _controller = AnimationController(
      vsync: this,  
      duration: const Duration(seconds: 18),       
    );

    // Scale Animation (Zoom out)
    _scaleAnimation = Tween<double>(begin: 1.8, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),  
    );

    // Opacity Animation (Fade out)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate when animation finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onInitializationComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: const Text(
                  "DATAPP",
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold, // Bold text
                    color: Color.fromARGB(255, 2, 45, 80),
                  ),
                ),
              ),
            ); 
          },
        ),
      ),
    );
  }
}
