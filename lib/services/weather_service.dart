// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import '../models/weather_model.dart';

// class LocationSuggestion {
//   final String name;
//   final String country;
//   final String state;
//   final double lat;
//   final double lon;
//   final String displayName;

//   LocationSuggestion({
//     required this.name,
//     required this.country,
//     required this.state,
//     required this.lat,
//     required this.lon,
//     required this.displayName,
//   });

//   factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
//     final name = json['name'] ?? '';
//     final country = json['country'] ?? '';
//     final state = json['state'] ?? '';

//     String displayName = name;
//     if (state.isNotEmpty && country.isNotEmpty) {
//       displayName = '$name, $state, $country';
//     } else if (country.isNotEmpty) {
//       displayName = '$name, $country';
//     }

//     return LocationSuggestion(
//       name: name,
//       country: country,
//       state: state,
//       lat: json['lat'].toDouble(),
//       lon: json['lon'].toDouble(),
//       displayName: displayName,
//     );
//   }
// }

// class WeatherService {
//   // You'll need to get a free API key from https://openweathermap.org/api
//   final String apiKey =
//       '29db157e189be745577c039ac9187697'; // Replace with your actual key
//   final String baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';
//   final String geoUrl = 'https://api.openweathermap.org/geo/1.0';

//   Future<Position?> getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled.');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       throw Exception('Location permissions are permanently denied');
//     }

//     return await Geolocator.getCurrentPosition();
//   }

//   Future<WeatherData?> fetchWeatherByLocation() async {
//     try {
//       final position = await getCurrentLocation();
//       return await fetchWeather(position!.latitude, position.longitude);
//     } catch (e) {
//       print('Error getting location: $e');
//       // Fallback to London coordinates
//       return await fetchWeather(51.5074, -0.1278);
//     }
//   }

//   Future<WeatherData?> fetchWeather(double lat, double lon) async {
//     final url = Uri.parse(
//       '$baseUrl?lat=$lat&lon=$lon&exclude=minutely,alerts&appid=$apiKey&units=metric',
//     );

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final location = await _getLocationName(lat, lon);
//         return WeatherData.fromJson(data, location);
//       } else {
//         print("Failed to load weather data: ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       print("Error fetching weather: $e");
//       return null;
//     }
//   }

//   Future<String> _getLocationName(double lat, double lon) async {
//     final url = Uri.parse(
//       'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey',
//     );

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final location = data[0];
//           final city = location['name'];
//           final country = location['country'];
//           return '$city, $country';
//         }
//       }
//     } catch (e) {
//       print("Error getting location name: $e");
//     }

//     return 'Unknown Location';
//   }

//   // Search for locations by name
//   Future<List<LocationSuggestion>> searchLocations(String query) async {
//     if (query.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
//       return _getMockLocationSuggestions(query);
//     }

//     final url = Uri.parse('$geoUrl/direct?q=$query&limit=5&appid=$apiKey');

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as List;
//         return data
//             .map((location) => LocationSuggestion.fromJson(location))
//             .toList();
//       } else {
//         print("Failed to search locations: ${response.statusCode}");
//         return _getMockLocationSuggestions(query);
//       }
//     } catch (e) {
//       print("Error searching locations: $e");
//       return _getMockLocationSuggestions(query);
//     }
//   }

//   // Fetch weather by city name
//   Future<WeatherData?> fetchWeatherByCity(String cityName) async {
//     if (apiKey == 'YOUR_API_KEY_HERE') {
//       return _getMockWeatherDataForCity(cityName);
//     }

//     try {
//       // First get coordinates for the city
//       final locations = await searchLocations(cityName);
//       if (locations.isNotEmpty) {
//         final location = locations.first;
//         final weatherData = await fetchWeather(location.lat, location.lon);
//         if (weatherData != null) {
//           // Update location name to match the searched city
//           return WeatherData(
//             current: weatherData.current,
//             hourly: weatherData.hourly,
//             daily: weatherData.daily,
//             location: location.displayName,
//           );
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error fetching weather by city: $e");
//       return _getMockWeatherDataForCity(cityName);
//     }
//   }

//   // Mock location suggestions for testing
//   List<LocationSuggestion> _getMockLocationSuggestions(String query) {
//     final mockLocations = [
//       {
//         'name': 'London',
//         'country': 'GB',
//         'state': '',
//         'lat': 51.5074,
//         'lon': -0.1278,
//       },
//       {
//         'name': 'New York',
//         'country': 'US',
//         'state': 'NY',
//         'lat': 40.7128,
//         'lon': -74.0060,
//       },
//       {
//         'name': 'Tokyo',
//         'country': 'JP',
//         'state': '',
//         'lat': 35.6762,
//         'lon': 139.6503,
//       },
//       {
//         'name': 'Paris',
//         'country': 'FR',
//         'state': '',
//         'lat': 48.8566,
//         'lon': 2.3522,
//       },
//       {
//         'name': 'Sydney',
//         'country': 'AU',
//         'state': 'NSW',
//         'lat': -33.8688,
//         'lon': 151.2093,
//       },
//       {
//         'name': 'Dubai',
//         'country': 'AE',
//         'state': '',
//         'lat': 25.2048,
//         'lon': 55.2708,
//       },
//       {
//         'name': 'Mumbai',
//         'country': 'IN',
//         'state': 'MH',
//         'lat': 19.0760,
//         'lon': 72.8777,
//       },
//       {
//         'name': 'Berlin',
//         'country': 'DE',
//         'state': '',
//         'lat': 52.5200,
//         'lon': 13.4050,
//       },
//       {
//         'name': 'Toronto',
//         'country': 'CA',
//         'state': 'ON',
//         'lat': 43.6532,
//         'lon': -79.3832,
//       },
//       {
//         'name': 'Singapore',
//         'country': 'SG',
//         'state': '',
//         'lat': 1.3521,
//         'lon': 103.8198,
//       },
//     ];

//     return mockLocations
//         .where(
//           (location) => (location['name'] as String).toLowerCase().contains(
//             query.toLowerCase(),
//           ),
//         )
//         .map((location) => LocationSuggestion.fromJson(location))
//         .toList();
//   }

//   // Mock weather data for specific city
//   WeatherData _getMockWeatherDataForCity(String cityName) {
//     final mockData = getMockWeatherData();
//     return WeatherData(
//       current: mockData.current,
//       hourly: mockData.hourly,
//       daily: mockData.daily,
//       location: cityName,
//     );
//   }

//   // Mock data for testing when API key is not available
//   WeatherData getMockWeatherData() {
//     final now = DateTime.now();
//     final current = CurrentWeather(
//       temperature: 22.0,
//       feelsLike: 20.0,
//       humidity: 65,
//       windSpeed: 15.0,
//       visibility: 10000,
//       description: 'Partly cloudy',
//       icon: '02d',
//       dt: now.millisecondsSinceEpoch ~/ 1000,
//     );

//     final hourly = List.generate(24, (index) {
//       final hour = now.add(Duration(hours: index));
//       return HourlyForecast(
//         time: _formatHour(hour),
//         temp: 20.0 + (index % 5),
//         icon: index % 2 == 0 ? '01d' : '02d',
//         description: index % 2 == 0 ? 'Clear' : 'Partly cloudy',
//         pop: 0,
//         dt: hour.millisecondsSinceEpoch ~/ 1000,
//       );
//     });

//     final daily = List.generate(7, (index) {
//       final day = now.add(Duration(days: index));
//       final conditions = [
//         'Mostly Sunny',
//         'Partly Cloudy',
//         'Heavy Rain',
//         'Snow Showers',
//         'Clear Skies',
//         'Overcast',
//         'Sunny',
//       ];
//       final icons = ['01d', '02d', '10d', '13d', '01d', '03d', '01d'];
//       return DailyForecast(
//         day: _formatDay(day),
//         condition: conditions[index],
//         maxTemp: 25.0 - (index * 2),
//         minTemp: 15.0 - (index * 2),
//         icon: icons[index],
//         dt: day.millisecondsSinceEpoch ~/ 1000,
//       );
//     });

//     return WeatherData(
//       current: current,
//       hourly: hourly,
//       daily: daily,
//       location: 'London, UK',
//     );
//   }

//   String _formatHour(DateTime dateTime) {
//     final hour = dateTime.hour;
//     if (hour == 0) return '12 AM';
//     if (hour < 12) return '$hour AM';
//     if (hour == 12) return '12 PM';
//     return '${hour - 12} PM';
//   }

//   String _formatDay(DateTime dateTime) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final forecastDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

//     if (forecastDate == today) return 'Today';

//     final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[dateTime.weekday - 1];
//   }
// }




import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class LocationSuggestion {
  final String name;
  final String country;
  final String state;
  final double lat;
  final double lon;
  final String displayName;

  LocationSuggestion({
    required this.name,
    required this.country,
    required this.state,
    required this.lat,
    required this.lon,
    required this.displayName,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? '';
    final country = json['country'] ?? '';
    final state = json['state'] ?? '';

    String displayName = name;
    if (state.isNotEmpty && country.isNotEmpty) {
      displayName = '$name, $state, $country';
    } else if (country.isNotEmpty) {
      displayName = '$name, $country';
    }

    return LocationSuggestion(
      name: name,
      country: country,
      state: state,
      lat: json['lat'].toDouble(),
      lon: json['lon'].toDouble(),
      displayName: displayName,
    );
  }
}

class WeatherService {
  final String apiKey = '29db157e189be745577c039ac9187697';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/onecall';
  final String geoUrl = 'https://api.openweathermap.org/geo/1.0';

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<WeatherData?> fetchWeatherByLocation() async {
    try {
      final position = await getCurrentLocation();
      return await fetchWeather(position!.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return await fetchWeather(51.5074, -0.1278); // London fallback
    }
  }

  Future<WeatherData?> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl?lat=$lat&lon=$lon&exclude=minutely,alerts&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = await _getLocationName(lat, lon);
        return WeatherData.fromJson(data, location);
      } else {
        print("❌ Failed to load weather data: ${response.statusCode}");
        print("❗ Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Error fetching weather: $e");
      return null;
    }
  }

  Future<String> _getLocationName(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          final city = location['name'];
          final country = location['country'];
          return '$city, $country';
        }
      } else {
        print("❌ Failed to get location name: ${response.statusCode}");
        print("❗ Response body: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error getting location name: $e");
    }

    return 'Unknown Location';
  }

  Future<List<LocationSuggestion>> searchLocations(String query) async {
    if (query.isEmpty || apiKey == '29db157e189be745577c039ac9187697') {
      return _getMockLocationSuggestions(query);
    }

    final url = Uri.parse('$geoUrl/direct?q=$query&limit=5&appid=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map((location) => LocationSuggestion.fromJson(location))
            .toList();
      } else {
        print("❌ Failed to search locations: ${response.statusCode}");
        print("❗ Response body: ${response.body}");
        return _getMockLocationSuggestions(query);
      }
    } catch (e) {
      print("⚠️ Error searching locations: $e");
      return _getMockLocationSuggestions(query);
    }
  }

  Future<WeatherData?> fetchWeatherByCity(String cityName) async {
    if (apiKey == '29db157e189be745577c039ac9187697') {
      return _getMockWeatherDataForCity(cityName);
    }

    try {
      final locations = await searchLocations(cityName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final weatherData = await fetchWeather(location.lat, location.lon);
        if (weatherData != null) {
          return WeatherData(
            current: weatherData.current,
            hourly: weatherData.hourly,
            daily: weatherData.daily,
            location: location.displayName,
          );
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Error fetching weather by city: $e");
      return _getMockWeatherDataForCity(cityName);
    }
  }

  List<LocationSuggestion> _getMockLocationSuggestions(String query) {
    final mockLocations = [
      {
        'name': 'London',
        'country': 'GB',
        'state': '',
        'lat': 51.5074,
        'lon': -0.1278,
      },
      {
        'name': 'New York',
        'country': 'US',
        'state': 'NY',
        'lat': 40.7128,
        'lon': -74.0060,
      },
      {
        'name': 'Tokyo',
        'country': 'JP',
        'state': '',
        'lat': 35.6762,
        'lon': 139.6503,
      },
    ];

    return mockLocations
        .where((location) =>
            (location['name'] as String).toLowerCase().contains(query.toLowerCase()))
        .map((location) => LocationSuggestion.fromJson(location))
        .toList();
  }

  WeatherData _getMockWeatherDataForCity(String cityName) {
    final mockData = getMockWeatherData();
    return WeatherData(
      current: mockData.current,
      hourly: mockData.hourly,
      daily: mockData.daily,
      location: cityName,
    );
  }

  WeatherData getMockWeatherData() {
    final now = DateTime.now();
    final current = CurrentWeather(
      temperature: 22.0,
      feelsLike: 20.0,
      humidity: 65,
      windSpeed: 15.0,
      visibility: 10000,
      description: 'Partly cloudy',
      icon: '02d',
      dt: now.millisecondsSinceEpoch ~/ 1000,
    );

    final hourly = List.generate(24, (index) {
      final hour = now.add(Duration(hours: index));
      return HourlyForecast(
        time: _formatHour(hour),
        temp: 20.0 + (index % 5),
        icon: index % 2 == 0 ? '01d' : '02d',
        description: index % 2 == 0 ? 'Clear' : 'Partly cloudy',
        pop: 0,
        dt: hour.millisecondsSinceEpoch ~/ 1000,
      );
    });

    final daily = List.generate(7, (index) {
      final day = now.add(Duration(days: index));
      final conditions = [
        'Mostly Sunny',
        'Partly Cloudy',
        'Heavy Rain',
        'Snow Showers',
        'Clear Skies',
        'Overcast',
        'Sunny',
      ];
      final icons = ['01d', '02d', '10d', '13d', '01d', '03d', '01d'];
      return DailyForecast(
        day: _formatDay(day),
        condition: conditions[index],
        maxTemp: 25.0 - (index * 2),
        minTemp: 15.0 - (index * 2),
        icon: icons[index],
        dt: day.millisecondsSinceEpoch ~/ 1000,
      );
    });

    return WeatherData(
      current: current,
      hourly: hourly,
      daily: daily,
      location: 'London, UK',
    );
  }

  String _formatHour(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  String _formatDay(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (forecastDate == today) return 'Today';

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dateTime.weekday - 1];
  }
}

