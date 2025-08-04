# WeatherWise - Flutter Weather App

A beautiful and modern weather application built with Flutter that displays current weather conditions, hourly forecasts, and daily forecasts.

## Features

- 🌤️ Current weather display with temperature, humidity, wind speed, and visibility
- 📅 7-day daily forecast
- ⏰ 24-hour hourly forecast
- 📍 Location-based weather (GPS)
- 🎨 Modern, clean UI design
- 🔄 Pull-to-refresh functionality
- 📱 Responsive design for mobile devices

## Screenshots

The app features a clean, modern design with:
- Current weather card with gradient background
- Hourly forecast with scrollable cards
- Daily forecast with detailed information
- Bottom navigation with Today, Hourly, Daily, and More tabs

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Get OpenWeatherMap API Key

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Get your API key
4. Replace `YOUR_API_KEY_HERE` in `lib/services/weather_service.dart` with your actual API key

### 3. Location Permissions

The app requires location permissions to show weather for your current location. Make sure to:

- Enable location services on your device
- Grant location permissions when prompted

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── weather_model.dart    # Weather data models
├── screens/
│   └── weather_screen.dart   # Main weather screen
├── services/
│   ├── weather_service.dart  # API service for weather data
│   └── weather_provider.dart # State management
└── widgets/
    ├── hourly_forecast.dart  # Hourly forecast widget
    └── daily_forecast.dart   # Daily forecast widget
```

## Dependencies

- `flutter`: Core Flutter framework
- `provider`: State management
- `http`: HTTP requests for API calls
- `geolocator`: Location services
- `intl`: Date and time formatting
- `permission_handler`: Handle permissions
- `cached_network_image`: Image caching

## API Usage

The app uses the OpenWeatherMap One Call API 3.0 to fetch weather data. The API provides:
- Current weather conditions
- Hourly forecasts for 48 hours
- Daily forecasts for 7 days

## Mock Data

If no API key is provided or the API is unavailable, the app will display mock weather data for demonstration purposes.

## Contributing

Feel free to contribute to this project by:
- Reporting bugs
- Suggesting new features
- Submitting pull requests

## License

This project is open source and available under the MIT License.
