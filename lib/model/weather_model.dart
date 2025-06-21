class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double feels;
  final int wind;
  final double windspeed;
  final DateTime sunrise;
  final DateTime sunset;
  final int humidity;
  final int pressure;
  final double sealevel;
  final int visibility;
  Weather({
    required this.icon,
    required this.feels,
    required this.wind,
    required this.windspeed,
    required this.sunrise,
    required this.sunset,
    required this.temperature,
    required this.description,
    required this.cityName,
    required this.humidity,
    required this.pressure,
required this.sealevel,
required this.visibility,
  });
  factory Weather.fromJson(Map<String, dynamic> json) {
    final int timezoneOffset = json['timezone'];
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      feels: json['main']['feels_like'].toDouble(),
      wind: json['wind']['deg'].toInt(),
      windspeed: json['wind']['speed'].toDouble(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] + timezoneOffset) * 1000,
        isUtc: true,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunset'] + timezoneOffset) * 1000,
        isUtc: true,
      ), humidity: json['main']['humidity'].toInt(), pressure: json['main']['pressure'].toInt(), sealevel: json['main']['sea_level'].toDouble(), visibility: json['visibility'],
    );
  }
  static String getDirectionFromDegree(int deg) {
    const directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"];
    return directions[((deg % 360) / 45).round()];
  }
}
