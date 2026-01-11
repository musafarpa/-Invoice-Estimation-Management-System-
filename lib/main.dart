import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/company_provider.dart';
import 'providers/estimation_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
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
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => EstimationProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, langProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Invoice & Estimation',
            debugShowCheckedModeBanner: false,
            locale: langProvider.locale,
            themeMode: themeProvider.themeMode,
            theme: ThemeProvider.lightTheme.copyWith(
              textTheme: GoogleFonts.montserratTextTheme(
                ThemeProvider.lightTheme.textTheme,
              ),
            ),
            darkTheme: ThemeProvider.darkTheme.copyWith(
              textTheme: GoogleFonts.montserratTextTheme(
                ThemeProvider.darkTheme.textTheme,
              ),
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
