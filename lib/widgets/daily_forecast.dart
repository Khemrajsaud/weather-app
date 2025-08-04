import 'package:flutter/material.dart';

class DailyForecastTile extends StatelessWidget {
  final String day;
  final String icon;
  final String condition;
  final String maxTemp;
  final String minTemp;

  const DailyForecastTile({
    required this.day,
    required this.icon,
    required this.condition,
    required this.maxTemp,
    required this.minTemp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network("https://openweathermap.org/img/wn/$icon@2x.png"),
      title: Text(day, style: TextStyle(color: Colors.white)),
      subtitle: Text(condition, style: TextStyle(color: Colors.white70)),
      trailing: Text("$maxTemp° / $minTemp°", style: TextStyle(color: Colors.white)),
    );
  }
}
