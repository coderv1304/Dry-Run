import 'package:flutter/material.dart';

import 'design/design_gallery.dart';
import 'design/dr_theme.dart';

void main() {
  runApp(const DryRunApp());
}

class DryRunApp extends StatelessWidget {
  const DryRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dry Run',
      debugShowCheckedModeBanner: false,
      theme: drThemeData(brightness: Brightness.light),
      darkTheme: drThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const DesignGallery(),
    );
  }
}
