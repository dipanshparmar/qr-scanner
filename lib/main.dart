import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// controllers
import './controllers/controllers.dart';

// providers
import './providers/providers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SavedScansProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF424242),
          textSelectionTheme: const TextSelectionThemeData(
            selectionColor: Color(0xFF424242),
            selectionHandleColor: Color(0xFF212121),
          ),
          fontFamily: 'Capriola',
        ),
        home: const BottomNavBarController(),
      ),
    );
  }
}
