import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/study_bloc.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF283C86);
  static const _secondary = Color(0xFF45A247);

  static const _features = [
    ('📄', 'Wgraj PDF lub zdjęcia notatek'),
    ('💬', 'Rozmawiaj z AI o materiałach'),
    ('📇', 'Generuj fiszki automatycznie'),
    ('❓', 'Twórz quizy jednym kliknięciem'),
    ('🎓', 'Tryb egzaminacyjny z AI'),
  ];

  final List<bool> _visible = List.filled(_features.length, false);
  bool _showButton = false;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 600));
    for (int i = 0; i < _features.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 480));
      setState(() => _visible[i] = true);
    }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _dotsController.stop();
    setState(() => _showButton = true);
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  void _start(BuildContext context) {
    context.read<StudyBloc>().add(const LoadSubjectsEvent());
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomePage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primary, Color(0xFF1E5F74), _secondary],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildFeatureList(),
              const SizedBox(height: 24),
              _buildLoader(),
              const Spacer(),
              _buildButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Text('📚', style: TextStyle(fontSize: 44)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'EduChat',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Twój inteligentny asystent do nauki',
          style: GoogleFonts.syneMono(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_features.length, (i) {
          final (emoji, text) = _features[i];
          return AnimatedOpacity(
            opacity: _visible[i] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 350),
            child: AnimatedSlide(
              offset: _visible[i] ? Offset.zero : const Offset(0, 0.35),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      text,
                      style: GoogleFonts.syneMono(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoader() {
    if (_showButton) return const SizedBox(height: 20);
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final offset = (_dotsController.value - i * 0.25).clamp(0.0, 1.0);
            final scale = 0.6 + 0.6 * (1 - (offset - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6 + 0.4 * scale),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context) {
    return AnimatedOpacity(
      opacity: _showButton ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedSlide(
        offset: _showButton ? Offset.zero : const Offset(0, 0.3),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: _showButton ? () => _start(context) : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Zaczynamy',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded,
                    color: _secondary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
