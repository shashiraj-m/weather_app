import 'package:equatable/equatable.dart';
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/weather_model.dart';

abstract class WeatherState extends Equatable {
  @override
  List<Object?> get props => [];

 
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;
  final List<Forecast> forecast;
final List<Forecast> todayHourly;
  WeatherLoaded(this.weather, this.forecast,this.todayHourly);

  @override
 @override
  List<Object?> get props => [weather, forecast, todayHourly];

}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}
