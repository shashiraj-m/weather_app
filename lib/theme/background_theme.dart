import 'package:flutter/material.dart';

class BackgroundTheme {
  static List<Color> getGradient({
    required String description,
    required DateTime time,
  }) {
    final hour = time.hour;
    final desc = description.toLowerCase();

    // Night
    if (hour >= 20 || hour <= 5) {
      return [Colors.black, Colors.indigo.shade900];
    }

    // Morning (6 AM - 10 AM)
    if (hour >= 6 && hour < 10) {
      return [Colors.deepOrange.shade400, Colors.blue.shade400];
    }

    // Day (10 AM - 4 PM)
    if (hour >= 10 && hour < 16) {
      if (desc.contains("clear")) {
        return [Colors.blue.shade300, Colors.cyan.shade100];
      } else if (desc.contains("cloud")) {
        return [Colors.blueGrey.shade400, Colors.grey.shade600];
      } else if (desc.contains("rain") || desc.contains("drizzle")) {
        return [Colors.blueGrey.shade700, Colors.grey.shade900];
      }
    }

    // Evening (4 PM - 8 PM)
    if (hour >= 16 && hour < 20) {
      return [Colors.blue.shade400, Colors.deepOrange.shade400];
    }

    // Default fallback
    return [Colors.blueGrey, Colors.grey.shade500];
  }
}
