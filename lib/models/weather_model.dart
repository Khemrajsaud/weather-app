class WeatherData {
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final String location;

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.location,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String location) {
    return WeatherData(
      current: CurrentWeather.fromJson(json['current']),
      hourly: (json['hourly'] as List)
          .take(24)
          .map((hour) => HourlyForecast.fromJson(hour))
          .toList(),
      daily: (json['daily'] as List)
          .take(7)
          .map((day) => DailyForecast.fromJson(day))
          .toList(),
      location: location,
    );
  }
}

class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final String description;
  final String icon;
  final int dt;

  CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.description,
    required this.icon,
    required this.dt,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: json['temp'].toDouble(),
      feelsLike: json['feels_like'].toDouble(),
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(),
      visibility: json['visibility'] ?? 10000,
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      dt: json['dt'],
    );
  }
}

class HourlyForecast {
  final String time;
  final double temp;
  final String icon;
  final String description;
  final int pop; // probability of precipitation
  final int dt;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.icon,
    required this.description,
    required this.pop,
    required this.dt,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    return HourlyForecast(
      time: _formatHour(dateTime),
      temp: json['temp'].toDouble(),
      icon: json['weather'][0]['icon'],
      description: json['weather'][0]['description'],
      pop: (json['pop'] * 100).round(),
      dt: json['dt'],
    );
  }

  static String _formatHour(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}

class DailyForecast {
  final String day;
  final String condition;
  final double maxTemp;
  final double minTemp;
  final String icon;
  final int dt;

  DailyForecast({
    required this.day,
    required this.condition,
    required this.maxTemp,
    required this.minTemp,
    required this.icon,
    required this.dt,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    return DailyForecast(
      day: _formatDay(dateTime),
      condition: json['weather'][0]['main'],
      maxTemp: json['temp']['max'].toDouble(),
      minTemp: json['temp']['min'].toDouble(),
      icon: json['weather'][0]['icon'],
      dt: json['dt'],
    );
  }

  static String _formatDay(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (forecastDate == today) return 'Today';
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dateTime.weekday - 1];
  }
}
