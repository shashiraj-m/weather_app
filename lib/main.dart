import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/location_cubit.dart';
import 'package:weather_app/cubit/search_cubit.dart';
import 'cubit/weather_cubit.dart';
import 'screens/weather_screen.dart';
import 'services/weather_service.dart';
import 'services/location_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Switzer'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => WeatherCubit(WeatherService(), LocationService()),
          ),
          BlocProvider(create: (_) => LocationCubit()..fetchLocation()),
          BlocProvider(create: (_) => SearchCubit()),
        ],
        child: const WeatherScreen(),
      ),
    );
  }
}
