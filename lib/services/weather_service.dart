import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/weather_model.dart';

class WeatherService {
  static const String apiKey = '449aa45cda05bf43ec9ce722f0d5bf2e';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

 Future<Weather> fetchWeatherByCity(String city) async {
    final url = Uri.parse(
      '$baseUrl/weather?q=$city&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('City not found');
    }
  }

  Future<List<Forecast>> fetchForecastByCity(String city) async {
    final url = Uri.parse(
      '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List items = json.decode(response.body)['list'];
      return items.map((e) => Forecast.fromJson(e)).toList();
    } else {
      throw Exception('Forecast not found');
    }
  }
   Future<Weather> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Weather failed');
    }
  }

  Future<List<Forecast>> fetchForecast(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List items = json.decode(response.body)['list'];
      return items.map((e) => Forecast.fromJson(e)).toList();
    } else {
      throw Exception('Forecast failed');
    }
  }
}
