import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CO2ProgressRing extends StatelessWidget {
  final double co2Level; // The CO2 level as a percentage (0.0 to 1.0)

  CO2ProgressRing({required this.co2Level});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularPercentIndicator(
        radius: 120.0, // Size of the circle
        lineWidth: 12.0, // Thickness of the circle
        percent: co2Level, // Progress value between 0.0 and 1.0
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${(co2Level * 100).toStringAsFixed(0)}%", // Display CO2 percentage
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
                : Colors.red), // Color changes based on level
        // backgroundColor: Colors.grey[300]!,
        backgroundColor: Color(0xffd7e3fc),
        circularStrokeCap: CircularStrokeCap.round, // Rounded ends
        animation: true, // Smooth animation on load
      ),
    );
  }
}

// import 'package:co2_detection_app_flutter/services/co2_mqtt_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:percent_indicator/percent_indicator.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> initNotifications() async {
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }

// class CO2ProgressRing extends StatefulWidget {
//   // final double co2Level; // The CO2 level as a percentage (0.0 to 1.0)
//   final MqttService mqttService;
//   final ValueChanged<double> onCo2DataReceived;

//   const CO2ProgressRing(this.mqttService, this.onCo2DataReceived, {super.key});

//   @override
//   State<CO2ProgressRing> createState() => _CO2ProgressRingState();
// }

// class _CO2ProgressRingState extends State<CO2ProgressRing> {
//   double co2CurrentValue = 0;
//   double threshold = 5000;
//   bool isAlertAcknowledged = false;
//   bool isDialogShown = false;
//   @override
//   void initState() {
//     widget.mqttService.onDataReceived = (topic, data) => {
//           if (topic == "class/maram_marzouki/co2")
//             {
//               setState(() {
//                 co2CurrentValue = double.tryParse(data) ?? 0.0;
//                 if (co2CurrentValue > threshold && !isAlertAcknowledged) {
//                   showCo2Notification(co2CurrentValue);
//                   showAlertDialog();
//                 }

//                 // Reset acknowledgment when the CO2 level drops below the threshold
//                 if (co2CurrentValue <= threshold && isAlertAcknowledged) {
//                   isAlertAcknowledged = false;
//                   isDialogShown = false;
//                 }
//               })
//             }
//         };
//     super.initState();
//   }

//   Future<void> showCo2Notification(double co2Value) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'high_co2_channel', // channel ID
//       'High CO2 Alert', // channel name
//       importance: Importance.max,
//       priority: Priority.high,
//       actions: <AndroidNotificationAction>[
//         AndroidNotificationAction(
//           'well_received_action',
//           'Well Received',
//           showsUserInterface: true,
//           cancelNotification: true,
//         ),
//       ],
//     );
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.show(
//       0, // Notification ID
//       'High CO2 Level Detected',
//       'CO2 level has reached $co2Value ppm!',
//       platformChannelSpecifics,
//     );
//   }

//   Future<void> showAlertDialog() async {
//     setState(() {
//       isDialogShown = true;
//     }); // Mark the dialog as shown
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('High CO2 Alert'),
//           content: Text('CO2 level has reached $co2CurrentValue ppm!'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   isAlertAcknowledged = true; // Mark the alert as acknowledged
//                 });
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Well Received!'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("cO222222 $co2CurrentValue");
//     double percentage = (co2CurrentValue / 10000).clamp(0.0, 1.0);
//     return Center(
//       child: CircularPercentIndicator(
//         radius: 120.0, // Size of the circle
//         lineWidth: 12.0, // Thickness of the circle
//         percent: percentage, // Progress value between 0.0 and 1.0
//         center: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "${(co2CurrentValue / 100).toStringAsFixed(1)}%", // Display CO2 percentage
//               style: const TextStyle(
//                   fontSize: 24.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white),
//             ),
//             const Text(
//               "CO2 Level",
//               style: TextStyle(fontSize: 16.0, color: Color(0xffd7e3fc)),
//             ),
//           ],
//         ),
//         progressColor: co2CurrentValue < 5000
//             ? Colors.green
//             : (co2CurrentValue < 7500
//                 ? Colors.orange
//                 : Colors.red), // Color changes based on level
//         // backgroundColor: Colors.grey[300]!,
//         backgroundColor: Color(0xffd7e3fc),
//         circularStrokeCap: CircularStrokeCap.round, // Rounded ends
//         animation: true, // Smooth animation on load
//       ),
//     );
//   }
// }

