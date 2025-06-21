import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/weather_state.dart';

class SearchByCity extends StatefulWidget {
  const SearchByCity({super.key});

  @override
  State<SearchByCity> createState() => _SearchByCityState();
}

final TextEditingController controller = TextEditingController();

class _SearchByCityState extends State<SearchByCity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          return Column(
            children: [
              // 🔍 Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter city name',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (city) {
                          if (city.isNotEmpty) {
                            context.read<WeatherCubit>().loadWeatherByCity(
                              city.trim(),
                            );
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        final city = controller.text.trim();
                        if (city.isNotEmpty) {
                          context.read<WeatherCubit>().loadWeatherByCity(city);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      tooltip: "Use Current Location",
                      onPressed: () {
                        controller.clear();
                        context.read<WeatherCubit>().loadWeather();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
