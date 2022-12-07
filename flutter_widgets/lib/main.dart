import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Zoom Image'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TransformationController controller;
  TapDownDetails? tabDownDetails;

  late AnimationController animationController;
  Animation<Matrix4>? animation;

  @override
  void initState() {
    super.initState();
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        controller.value = animation!.value;
      });
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: buildImage(),
        ),
      ),
    );
  }

  Widget buildImage() => GestureDetector(
        onDoubleTapDown: (details) => tabDownDetails = details,
        onDoubleTap: () {
          final position = tabDownDetails!.localPosition;

          final double scale = 3;
          final x = -position.dx * (scale - 1);
          final y = -position.dy * (scale - 1);

          final zoomed = Matrix4.identity()
            ..translate(x, y)
            ..scale(scale);
          final end = controller.value.isIdentity() ? zoomed : Matrix4.identity();
          animation = Matrix4Tween(
            begin: controller.value,
            end: end,
          ).animate(CurveTween(curve: Curves.easeOut).animate(animationController));
          animationController.forward(from: 0);
        },
        child: Column(
          children: [
            InteractiveViewer(
                clipBehavior: Clip.none,
                transformationController: controller,
                panEnabled: false,
                scaleEnabled: false,
                child: AspectRatio(aspectRatio: 1, child: Image.asset('images/catimage.jpg'))),
          ],
        ),
      );
}
