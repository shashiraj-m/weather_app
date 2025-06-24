import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchState {
  final List<Map<String, dynamic>> results;
  final bool loading;

  SearchState({required this.results, this.loading = false});
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState(results: []));

  Future<void> searchCity(String query) async {
    if (query.isEmpty) {
      emit(SearchState(results: []));
      return;
    }

    emit(SearchState(results: [], loading: true));

    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=449aa45cda05bf43ec9ce722f0d5bf2e';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      emit(SearchState(results: data.cast<Map<String, dynamic>>()));
    } else {
      emit(SearchState(results: []));
    }
  }
}
