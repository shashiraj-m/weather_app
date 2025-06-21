import 'package:intl/intl.dart';

class Forecast {
  final DateTime date;
  final double temperature;
  final String description;
  final String time;
  final String dayLabel;
  final double rainChance;
  final int humidity;
  Forecast({
    required this.date,
    required this.temperature,
    required this.description,
    required this.time,
    required this.dayLabel,
    required this.rainChance,
    required this.humidity
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['dt_txt']);
    final timeFormatted = DateFormat('h a').format(date); // Example: 3 PM

    return Forecast(
      date: date,
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      time: timeFormatted,
      dayLabel: getDayLabel(date),
      rainChance: (json['pop'] ?? 0.0).toDouble(), humidity:  json['main']['humidity'].toInt(),
    );
  }

  static String getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final input = DateTime(date.year, date.month, date.day);
    final diff = input.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEEE').format(date); // e.g., "Wednesday"
  }
}
