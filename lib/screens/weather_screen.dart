import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int _currentIndex = 0;
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();
  List<LocationSuggestion> _locationSuggestions = [];
  bool _showSuggestions = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _locationSuggestions.clear();
      });
      return;
    }

    if (query.length >= 2) {
      try {
        final suggestions = await _weatherService.searchLocations(query);
        setState(() {
          _locationSuggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
      } catch (e) {
        print('Error searching locations: $e');
      }
    }
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;

    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });

    await _fetchWeatherForCity(query);
  }

  Future<void> _selectLocation(LocationSuggestion suggestion) async {
    _searchController.text = suggestion.name;
    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });

    await _fetchWeatherForLocation(suggestion.lat, suggestion.lon, suggestion.displayName);
  }

  Future<void> _fetchWeatherForCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weatherData = await _weatherService.fetchWeatherByCity(cityName);
      if (weatherData != null) {
        setState(() {
          _weatherData = weatherData;
        });
      } else {
        setState(() {
          _error = 'Could not find weather data for $cityName';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchWeatherForLocation(double lat, double lon, String locationName) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weatherData = await _weatherService.fetchWeather(lat, lon);
      if (weatherData != null) {
        setState(() {
          _weatherData = WeatherData(
            current: weatherData.current,
            hourly: weatherData.hourly,
            daily: weatherData.daily,
            location: locationName,
          );
        });
      } else {
        setState(() {
          _error = 'Could not fetch weather data for $locationName';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  ElevatedButton(
                    onPressed: _fetchWeather,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : _weatherData == null
          ? Center(child: Text('No weather data available'))
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody(_weatherData!)),
                  _buildBottomNavigation(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WeatherWise',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.notifications_outlined, color: Colors.black87),
                  SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'WL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _showSuggestions = false;
                                _locationSuggestions.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                ),
              ),
              if (_showSuggestions && _locationSuggestions.isNotEmpty)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _locationSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _locationSuggestions[index];
                        return ListTile(
                          leading: Icon(Icons.location_on, color: Colors.blue),
                          title: Text(suggestion.displayName),
                          onTap: () => _selectLocation(suggestion),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(WeatherData weatherData) {
    switch (_currentIndex) {
      case 0:
        return _buildTodayView(weatherData);
      case 1:
        return _buildHourlyView(weatherData);
      case 2:
        return _buildDailyView(weatherData);
      case 3:
        return _buildMoreView();
      default:
        return _buildTodayView(weatherData);
    }
  }

  Widget _buildTodayView(WeatherData weatherData) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildCurrentWeatherCard(weatherData),
          SizedBox(height: 24),
          _buildHourlyForecastSection(weatherData),
          SizedBox(height: 24),
          _buildDailyForecastSection(weatherData),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherData weatherData) {
    final current = weatherData.current;
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFA726)],
        ),
      ),
      child: Stack(
        children: [
          // Background image overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      weatherData.location,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dateFormat.format(now),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                Spacer(),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        _getWeatherIcon(current.icon),
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${current.temperature.round()}°C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherDetail(
                      '${current.feelsLike.round()}°C',
                      Icons.thermostat,
                    ),
                    _buildWeatherDetail(
                      '${current.humidity}%',
                      Icons.water_drop,
                    ),
                    _buildWeatherDetail(
                      '${current.windSpeed.round()} km/h',
                      Icons.air,
                    ),
                    _buildWeatherDetail(
                      '${(current.visibility / 1000).round()} km',
                      Icons.visibility,
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

  Widget _buildWeatherDetail(String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecastSection(WeatherData weatherData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hourly Forecast',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 24,
            itemBuilder: (context, index) {
              final hourly = weatherData.hourly[index];
              return Container(
                width: 80,
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hourly.time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Icon(
                      _getWeatherIcon(hourly.icon),
                      size: 24,
                      color: Colors.blue,
                    ),
                    Text(
                      '${hourly.temp.round()}°C',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${hourly.pop}%',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastSection(WeatherData weatherData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 7,
          itemBuilder: (context, index) {
            final daily = weatherData.daily[index];
            final isToday = daily.day == 'Today';

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToday ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday ? Colors.blue : Colors.grey[200]!,
                ),
              ),
              child: Row(
                children: [
                  if (isToday)
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  if (isToday) SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Text(
                      daily.day,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    _getWeatherIcon(daily.icon),
                    size: 24,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Text(
                      daily.condition,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  Text(
                    '${daily.maxTemp.round()}°',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${daily.minTemp.round()}°',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHourlyView(WeatherData weatherData) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 24,
            itemBuilder: (context, index) {
              final hourly = weatherData.hourly[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        hourly.time,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(hourly.icon),
                      size: 24,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Text(
                        hourly.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    Text(
                      '${hourly.temp.round()}°C',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${hourly.pop}%',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyView(WeatherData weatherData) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Forecast',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              final daily = weatherData.daily[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        daily.day,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(daily.icon),
                      size: 24,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Text(
                        daily.condition,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    Text(
                      '${daily.maxTemp.round()}°',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${daily.minTemp.round()}°',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoreView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'More Options',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Settings and additional features coming soon',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, 'Today'),
          _buildNavItem(1, Icons.access_time, 'Hourly'),
          _buildNavItem(2, Icons.calendar_today, 'Daily'),
          _buildNavItem(3, Icons.more_horiz, 'More'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey[600],
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey[600],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny;
      case '01n':
        return Icons.nightlight_round;
      case '02d':
      case '02n':
        return Icons.cloud;
      case '03d':
      case '03n':
        return Icons.cloud;
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
        return Icons.grain;
      case '10d':
      case '10n':
        return Icons.grain;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.waves;
      default:
        return Icons.wb_sunny;
    }
  }
}
