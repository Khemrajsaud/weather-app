import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch real weather data first
      _weatherData = await _weatherService.fetchWeatherByLocation();
      
      // If no real data (API key not set), use mock data
      if (_weatherData == null) {
        _weatherData = _weatherService.getMockWeatherData();
      }
    } catch (e) {
      _error = e.toString();
      // Use mock data as fallback
      _weatherData = _weatherService.getMockWeatherData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    await fetchWeather();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 