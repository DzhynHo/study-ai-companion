import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/datasources/local_data_source.dart';
import 'data/datasources/groq_client.dart';
import 'data/repositories/study_repository_impl.dart';
import 'domain/repositories/study_repository.dart';
import 'presentation/bloc/study_bloc.dart';
import 'presentation/pages/splash_page.dart';
import 'core/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final localDataSource = HiveLocalDataSource();
  try {
    await localDataSource.init();
  } catch (_) {
    await Future.delayed(const Duration(seconds: 2));
    await localDataSource.init();
  }

  final repository = StudyRepositoryImpl(
    groqClient: GroqClient(apiKey: AppConfig.groqApiKey),
    localDataSource: localDataSource,
  );

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final StudyRepository repository;
  const MyApp({required this.repository, super.key});

  static const _primary = Color(0xFF283C86);
  static const _secondary = Color(0xFF45A247);

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.syneMonoTextTheme();

    final textTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 57, fontWeight: FontWeight.bold, color: _primary),
      displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 45, fontWeight: FontWeight.bold, color: _primary),
      displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 36, fontWeight: FontWeight.bold, color: _primary),
      headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 26, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.spaceGrotesk(
          fontSize: 14, fontWeight: FontWeight.w500),
    );

    return BlocProvider(
      create: (_) => StudyBloc(repository: repository),
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          primary: _primary,
          secondary: _secondary,
          brightness: Brightness.light,
        ),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
          hintStyle: GoogleFonts.syneMono(fontSize: 13, color: Colors.grey),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _secondary,
          foregroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _primary.withValues(alpha: 0.08),
          labelStyle: GoogleFonts.syneMono(fontSize: 12, color: _primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const SplashPage(),
      ),
    );
  }
}
