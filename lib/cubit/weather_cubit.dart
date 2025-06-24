import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/model/forecast_model.dart';

import '../services/weather_service.dart';
import '../services/location_service.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherService weatherService;
  final LocationService locationService;

  WeatherCubit(this.weatherService, this.locationService)
    : super(WeatherInitial());

  void loadWeather() async {
    try {
      emit(WeatherLoading());

      final position = await locationService.getCurrentLocation();

      final weather = await weatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      final forecastRaw = await weatherService.fetchForecast(
        position.latitude,
        position.longitude,
      );

      final forecast = _getDailyForecasts(forecastRaw);
      final todayHourly = _getFiveDayThreeHourlyForecast(forecastRaw);
      emit(WeatherLoaded(weather, forecast, todayHourly));
    } catch (e) {
      print(e);
      emit(WeatherError("Failed to load current location weather."));
    }
  }

  void loadWeatherByCity(String city) async {
    try {
      emit(WeatherLoading());
      final weather = await weatherService.fetchWeatherByCity(city);
      final forecastRaw = await weatherService.fetchForecastByCity(city);
      final forecast = _getDailyForecasts(forecastRaw);
      final todayHourly = _getFiveDayThreeHourlyForecast(forecastRaw);
      emit(WeatherLoaded(weather, forecast, todayHourly));
    } catch (e) {
      emit(WeatherError("City not found."));
    }
  }

  List<Forecast> _getDailyForecasts(List<Forecast> forecasts) {
    final Map<String, Forecast> result = {};

    for (var forecast in forecasts) {
      final dateKey = DateFormat('yyyy-MM-dd').format(forecast.date);

      // Only pick one forecast per day, preferably closest to 12 PM
      if (!result.containsKey(dateKey) ||
          (forecast.date.hour - 12).abs() <
              (result[dateKey]!.date.hour - 12).abs()) {
        result[dateKey] = forecast;
      }
    }

    // Sort
    final sortedForecasts = result.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedForecasts.take(6).toList();
  }

  List<Forecast> _getFiveDayThreeHourlyForecast(List<Forecast> forecasts) {
    final now = DateTime.now();

    // Filter next 5 days from now
    return forecasts
        .where(
          (f) =>
              f.date.isAfter(now) &&
              f.date.isBefore(now.add(const Duration(days: 5))),
        )
        .toList();
  }

  Future<void> fetchWeather(double lat, double lon) async {
    try {
      emit(WeatherLoading());

      final weather = await weatherService.fetchWeather(lat, lon);
      final forecast = await weatherService.fetchForecast(lat, lon);

      final todayHourly = _getFiveDayThreeHourlyForecast(forecast);

      emit(WeatherLoaded(weather, forecast, todayHourly));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}
