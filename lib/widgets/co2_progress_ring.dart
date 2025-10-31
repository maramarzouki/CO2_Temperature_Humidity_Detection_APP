import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CO2ProgressRing extends StatelessWidget {
  final double co2Level; // The CO2 level as a percentage (0.0 to 1.0)

  CO2ProgressRing({required this.co2Level});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 12.0,
        percent: co2Level,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${(co2Level * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Text(
              "CO2 Level",
              style: TextStyle(fontSize: 16.0, color: Color(0xffd7e3fc)),
            ),
          ],
        ),
        progressColor: co2Level < 0.5
            ? Colors.green
            : (co2Level < 0.75
                ? Colors.orange
                : Colors.red), // color changes based on level
        backgroundColor: Color(0xffd7e3fc),
        circularStrokeCap: CircularStrokeCap.round,
        animation: true,
      ),
    );
  }
}