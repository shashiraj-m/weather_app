// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/theme/custom_container.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('clear')) {
      return 'assets/svg/wi-day-sunny.svg';
    }
    if (description.contains('cloud')) {
      return 'assets/svg/wi-cloudy.svg';
    }
    if (description.contains('rain')) {
      return 'assets/svg/wi-day-rain.svg';
    }
    // if (description.contains('snow')) return 'assets/weather/snow.jpg';
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
                child: Text(
                  state.weather.cityName,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    color: Colors.white,
                  ),
                ),
              );
            } else if (state is WeatherLoading) {
              return const Text("");
            } else if (state is WeatherError) {
              return const Text("Error");
            }
            return const Text("");
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
                      colors: [Colors.blueGrey, Colors.grey.shade500],
                    ),
                  ),
                ),
                SafeArea(child: _buildWeatherContent(context, state)),
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

  Widget _buildWeatherContent(BuildContext content, WeatherLoaded state) {
    String formatTime(DateTime time) => DateFormat('h:mm a').format(time);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          //  Weather content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${state.weather.temperature.ceil()}°c",
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.15,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            state.weather.description,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Feels Like ${state.weather.feels.ceil()}°c',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        getWeatherIcon(state.weather.description),
                        color: Colors.white,
                        height: MediaQuery.of(context).size.width * 0.19,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "${hourly.temperature.ceil()}°",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Rain ${(hourly.rainChance * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Humidity ${hourly.humidity.toString()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  getWeatherIcon(hourly.description),
                                  color: Colors.white,
                                  height: 18,
                                ),
                                Text(
                                  hourly.description,
                                  style: TextStyle(
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

                CustomContainer(
                  height: height * 0.12,
                  width: width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.forecast.length,
                    itemBuilder: (context, index) {
                      final item = state.forecast[index];
                      final label = getDayLabel(item.date);

                      DateFormat(
                        'EEE,MMM d',
                      ).format(DateTime.parse(item.date.toString()));

                      return SizedBox(
                        width:
                            item.description == 'scattered clouds' ||
                                item.description == 'overcast clouds'
                            ? 120
                            : 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "${item.temperature.ceil()}°",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  getWeatherIcon(item.description),
                                  color: Colors.white,
                                  height: 18,
                                ),
                                Text(
                                  item.description,
                                  style: TextStyle(
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
                SizedBox(height: 15),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Weather.getDirectionFromDegree(
                                      state.weather.wind,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${state.weather.windspeed} m/s",
                                    style: TextStyle(
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
                        SizedBox(height: 15),
                        CustomContainer(
                          height: 70,
                          width: width / 2.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatTime(state.weather.sunrise)} Sunrise',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${formatTime(state.weather.sunset)} Sunset',
                                style: TextStyle(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Humidity ${state.weather.humidity} %',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Container(
                            height: 0.3,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          Text(
                            'Visibility ${state.weather.visibility / 1000} km',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Container(
                            height: 0.3,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          Text(
                            'Pressure ${state.weather.pressure.toString()} hpa',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Container(
                            height: 0.3,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          Text(
                            'Sea level ${state.weather.sealevel.ceil()} hpa',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Container(
                            height: 0.3,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(date.year, date.month, date.day);
    final diff = forecastDate.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('E').format(date); // e.g., Wednesday
  }
}
