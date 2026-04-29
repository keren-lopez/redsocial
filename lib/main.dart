import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/post_list_screen.dart';

void main() {
  runApp(const RedSocialApp());
}

class RedSocialApp extends StatelessWidget {
  const RedSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7B2CFF),
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF7B2CFF),
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF0D0D0D),
      ),
    );

    return MaterialApp(
      title: 'RedSocial',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF0D0D0D),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE5E5E5),
          thickness: 1,
          space: 1,
        ),
      ),
      home: const PostListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
