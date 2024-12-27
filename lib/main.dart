import 'package:flutter/material.dart';

import 'package:green_house/device.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Green House Controller',
        theme: ThemeData(primarySwatch: Colors.blue),
        home:  const BluetoothControlScreen(),
        );
  }
}
