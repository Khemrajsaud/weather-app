import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String time;
  final String icon;
  final String temp;

  const HourlyForecastCard({required this.time, required this.icon, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(time, style: TextStyle(color: Colors.white, fontSize: 12)),
          Image.network("https://openweathermap.org/img/wn/$icon@2x.png", height: 40),
          Text("$temp°C", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
