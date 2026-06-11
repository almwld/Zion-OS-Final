import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/lock_screen.dart';
import 'models/app_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZionOSApp());
}

class ZionOSApp extends StatelessWidget {
  const ZionOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppModel(),
      child: MaterialApp(
        title: 'Zion OS 2027',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFF00BCD4),
          colorScheme: const ColorScheme.dark(primary: Color(0xFF00BCD4)),
        ),
        home: const LockScreen(),
      ),
    );
  }
}
