import 'package:flutter/material.dart';

/// Extensions dla BuildContext
extension BuildContextExt on BuildContext {
  /// Pokaż snackbar z wiadomością
  void showSnackBar(String message, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  /// Pokaż error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Extensions dla String
extension StringExt on String {
  /// Ucz pierwszą literę
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Sprawdź czy string zawiera tylko białe znaki
  bool get isBlank => trim().isEmpty;

  /// Limit długości stringa
  String limit(int length, {String suffix = '...'}) {
    if (this.length > length) {
      return substring(0, length - suffix.length) + suffix;
    }
    return this;
  }
}

/// Extensions dla List
extension ListExt<T> on List<T> {
  /// Zwróć first lub null
  T? get firstOrNull => isEmpty ? null : first;

  /// Zwróć last lub null
  T? get lastOrNull => isEmpty ? null : last;

  /// Paginate listę
  List<List<T>> paginate(int pageSize) {
    final pages = <List<T>>[];
    for (int i = 0; i < length; i += pageSize) {
      pages.add(sublist(
        i,
        i + pageSize > length ? length : i + pageSize,
      ));
    }
    return pages;
  }
}

/// Extensions dla Duration
extension DurationExt on Duration {
  /// Konwertuj do formatu MM:SS
  String toTimeString() {
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
