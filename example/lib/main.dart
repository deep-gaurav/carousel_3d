import 'package:carousel_3d/carousel_3d.dart';
import 'package:carousel_3d/controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Carousel3DController controller = Carousel3DController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var itemCount = 5;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Example'),
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.previousPage();
                  },
                  child: Text('previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.nextPage();
                  },
                  child: Text('next'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.jumpToPage(1);
                  },
                  child: Text('Go to page at index 1'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 200,
                width: 300,
                child: Carousel3D(
                  controller: controller,
                  maxHorizontalShift: 100,
                  infiniteScroll: true,
                  itemCount: itemCount,
                  minScaleFactor: 0.1,
                  itemBuilder: (index, z) {
                    return Container(
                      color: HSVColor.fromAHSV(
                              1, (360.0 / itemCount) * index, 1, 0.9)
                          .toColor(),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
