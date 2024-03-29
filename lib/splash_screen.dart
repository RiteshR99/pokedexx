import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pokedexx/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _navigateToHomePage();
  }

  void _navigateToHomePage() {
    if (context != null) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context!).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned.fill(
              top: 400.0,
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white70,
                  size: 100.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
