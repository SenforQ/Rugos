import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'Home_page.dart';
import 'Record_page.dart';
import 'Magic_page.dart';
import 'Message_page.dart';
import 'Profile_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleShape = StadiumBorder();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD2B48C)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: capsuleShape,
            backgroundColor: const Color(0xFFD2B48C),
            foregroundColor: Colors.white,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: capsuleShape,
            backgroundColor: const Color(0xFFD2B48C),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: capsuleShape,
            foregroundColor: const Color(0xFFD2B48C),
            side: const BorderSide(color: Color(0xFFD2B48C)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: capsuleShape,
            foregroundColor: const Color(0xFFD2B48C),
          ),
        ),
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: const TabBarView(
          children: [
            HomePage(),
            RecordPage(),
            MagicPage(),
            MessagePage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(33),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 28,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFFD2B48C).withValues(alpha: 0.18),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(33),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(33),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.82),
                        width: 1.2,
                      ),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
                      labelColor: const Color(0xFFD2B48C),
                      unselectedLabelColor: const Color(0xFFC8C8C8),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      tabs: const [
                        Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_rounded, size: 22),
                              SizedBox(height: 4),
                              Icon(Icons.circle, size: 5),
                            ],
                          ),
                        ),
                        Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.radio_button_unchecked_rounded, size: 22),
                              SizedBox(height: 4),
                              Icon(Icons.circle, size: 5),
                            ],
                          ),
                        ),
                        Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_outlined, size: 22),
                              SizedBox(height: 4),
                              Icon(Icons.circle, size: 5),
                            ],
                          ),
                        ),
                        Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 22),
                              SizedBox(height: 4),
                              Icon(Icons.circle, size: 5),
                            ],
                          ),
                        ),
                        Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline_rounded, size: 22),
                              SizedBox(height: 4),
                              Icon(Icons.circle, size: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
