// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/theme/background_theme.dart';
import 'package:weather_app/theme/custom_container.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../cubit/search_cubit.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Timer? _debounce;

  String getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('clear')) return 'assets/svg/wi-day-sunny.svg';
    if (description.contains('cloud')) return 'assets/svg/wi-cloudy.svg';
    if (description.contains('rain')) return 'assets/svg/wi-day-rain.svg';
    if (description.contains('thunder')) {
      return 'assets/svg/wi-day-thunderstorm.svg';
    }
    return 'assets/svg/wi-day-sunny.svg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: double.infinity,
        leading: BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            if (state is WeatherLoaded) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.weather.cityName,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      tooltip: "Use current location",
                      onPressed: () {
                        context.read<WeatherCubit>().loadWeather();
                      },
                    ),
                  ],
                ),
              );
            } else if (state is WeatherLoading) {
              return const Center(child: SizedBox());
            } else if (state is WeatherError) {
              return const Text("Error");
            }
            return const SizedBox.shrink();
          },
        ),
      ),

      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          if (state is WeatherInitial) {
            context.read<WeatherCubit>().loadWeather();
            return Center(child: Lottie.asset('assets/json/weather.json'));
          } else if (state is WeatherLoading) {
            return Center(child: Lottie.asset('assets/json/weather.json'));
          } else if (state is WeatherLoaded) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: BackgroundTheme.getGradient(
                        description: state.weather.description,
                        time: DateTime.now(),
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      _buildSearchBar(context),
                      _buildSearchResults(context),
                      Expanded(child: _buildWeatherContent(context, state)),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is WeatherError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(width: 0.1, color: Colors.white),
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search city...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              context.read<SearchCubit>().searchCity(value);
            });
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, searchState) {
        if (searchState.results.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(width: 0.1, color: Colors.white),
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withValues(alpha: 0.04),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchState.results.length,
              itemBuilder: (context, index) {
                final city = searchState.results[index];
                return ListTile(
                  title: Text(
                    '${city["name"]}, ${city["country"]}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  // subtitle: Text(
                  //   'Lat: ${city["lat"]}, Lon: ${city["lon"]}',
                  //   style: const TextStyle(color: Colors.white70, fontSize: 12),
                  // ),
                  onTap: () {
                    context.read<WeatherCubit>().fetchWeather(
                      city["lat"],
                      city["lon"],
                    );
                    context.read<SearchCubit>().emit(SearchState(results: []));
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherLoaded state) {
    String formatTime(DateTime time) => DateFormat('h:mm a').format(time);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Current Weather
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(width: 0.1, color: Colors.white),
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withValues(alpha: 0.04),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${state.weather.temperature.ceil()}°c",
                        style: TextStyle(
                          fontSize: width * 0.15,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        state.weather.description,
                        style: TextStyle(
                          fontSize: width * 0.05,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Feels Like ${state.weather.feels.ceil()}°c',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    getWeatherIcon(state.weather.description),
                    color: Colors.white,
                    height: width * 0.19,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Hourly
            CustomContainer(
              height: height * 0.22,
              width: width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.todayHourly.length,
                itemBuilder: (context, index) {
                  final hourly = state.todayHourly[index];
                  final label = getDayLabel(hourly.date);
                  final time = DateFormat('ha').format(hourly.date);

                  return SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "${hourly.temperature.ceil()}°",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Rain ${(hourly.rainChance * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Humidity ${hourly.humidity.toString()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              getWeatherIcon(hourly.description),
                              color: Colors.white,
                              height: 18,
                            ),
                            Text(
                              hourly.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),

            // Forecast
            CustomContainer(
              height: height * 0.12,
              width: width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.forecast.length,
                itemBuilder: (context, index) {
                  final item = state.forecast[index];
                  final label = getDayLabel(item.date);
                  return SizedBox(
                    width: item.description.contains('cloud') ? 120 : 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "${item.temperature.ceil()}°",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              getWeatherIcon(item.description),
                              color: Colors.white,
                              height: 18,
                            ),
                            Text(
                              item.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CustomContainer(
                      height: 70,
                      width: width / 2.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Weather.getDirectionFromDegree(
                                  state.weather.wind,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "${state.weather.windspeed} m/s",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            'assets/svg/wi-wind-deg.svg',
                            color: Colors.white,
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomContainer(
                      height: 70,
                      width: width / 2.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatTime(state.weather.sunrise)} Sunrise',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${formatTime(state.weather.sunset)} Sunset',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                CustomContainer(
                  height: 155,
                  width: width / 2.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Humidity ${state.weather.humidity} %',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      _divider(),
                      Text(
                        'Visibility ${state.weather.visibility / 1000} km',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      _divider(),
                      Text(
                        'Pressure ${state.weather.pressure} hpa',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      _divider(),
                      Text(
                        'Sea level ${state.weather.sealevel.ceil()} hpa',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(height: 0.3, width: double.infinity, color: Colors.white);

  String getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(date.year, date.month, date.day);
    final diff = forecastDate.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('E').format(date);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
