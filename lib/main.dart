import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/estimation_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/language_provider.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EstimationProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return MaterialApp(
            title: 'Invoice & Estimation',
            debugShowCheckedModeBanner: false,
            locale: langProvider.locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE8F959),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F7F5),
              useMaterial3: true,
              textTheme: GoogleFonts.montserratTextTheme(),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
