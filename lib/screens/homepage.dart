import 'package:audioplayers/audioplayers.dart';
import 'package:co2_detection_app_flutter/co2_progress_ring.dart';
import 'package:co2_detection_app_flutter/helpers/database_helper.dart';
import 'package:co2_detection_app_flutter/screens/login_screen.dart';
import 'package:co2_detection_app_flutter/services/co2_mqtt_service.dart';
import 'package:co2_detection_app_flutter/services/humidity_mqtt_service.dart';
import 'package:co2_detection_app_flutter/services/temperature_mqtt_service.dart';
import 'package:co2_detection_app_flutter/widgets/subscribe_topic_card.dart';
import 'package:co2_detection_app_flutter/widgets/subscribed_to_topic_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class Homepage extends StatefulWidget {
  static const routeName = '/homepage';
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final MqttService mqttService = MqttService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  // final TemperatureMqttService temperatureMqttService =
  //     TemperatureMqttService();
  // final HumidityMqttService humidityMqttService = HumidityMqttService();
  double co2CurrentValue = 0;
  double threshold = 0;
  bool isAlertAcknowledged = false;
  bool isDialogShown = false;
  late String username = "";
  late int? userID = 0;
  final _dbHelper = DatabaseHelper();
  final List<String> topics = ['Temperature', 'Humidity'];
  final Set<String> subscribedTopics = {};
  final Map<String, String> topicValues = {
    "class/maram_marzouki/co2": "N/A",
    "class/maram_marzouki/humidity": "N/A",
    "class/maram_marzouki/temperature": "N/A",
  };
  bool subscribedToTemp = false;
  bool subscribedToHumidity = false;

  String tempValue = "";
  String humidityValue = "";

  @override
  void initState() {
    getUserDetails();
    // loadThreshold();
    super.initState();
    print("USER IDDDDDDDD $userID");
    initNotifications();
    mqttService.onDataReceived = (topic, data) {
      print("CO22222222222 $topic $data");
      if (topic == "class/maram_marzouki/co2") {
        setState(() {
          co2CurrentValue = double.tryParse(data) ?? 0.0;
          print("CO22222222222 $co2CurrentValue");
        });
        if (co2CurrentValue > threshold && !isAlertAcknowledged) {
          _triggerAlert();
          showCo2Notification(co2CurrentValue);
          showAlertDialog();
        }

        // Reset acknowledgment when the CO2 level drops below the threshold
        if (co2CurrentValue <= threshold) {
          isAlertAcknowledged = false;
          isDialogShown = false;
        }
      }
      // if (topic == "class/maram_marzouki/temperature") {
      //   setState(() {
      //     tempValue = data;
      //   });
      // }
      // if (topic == "class/maram_marzouki/humidity") {
      //   setState(() {
      //     humidityValue = data;
      //   });
      // }
    };

    mqttService.connect();
  }

  // Future<void> loadThreshold() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     threshold = prefs.getDouble('threshold') ?? 1000; // Load or use default
  //   });
  // }

  // void updateCO2Value(double value) {
  //   setState(() {
  //     co2CurrentValue = value;
  //   });
  //   saveThreshold(value);
  // }

  void getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? "Unknown";
    userID = prefs.getInt('userId');
    threshold = prefs.getDouble('threshold') ?? 0;
    final savedTopics = await _dbHelper.getSubscriptions(userID!);
    if (savedTopics.isNotEmpty) {
      setState(() {
        subscribedTopics.addAll(savedTopics);
      });
      // Reconnect to each saved subscription
      mqttService.connect().then((_) {
        for (String topic in savedTopics) {
          if (topic == "Humidity") {
            mqttService.onSubscribe(
              "Humidity",
            );
            // mqttService.onDataReceived = (topic, data) {
            //   if (topic == "class/maram_marzouki/temperature") {
            //     setState(() {
            //       topicValues["Temperature"] = data;
            //     });
            //   }
            // setState(() {
            //   topicValues["Temperature"] = data; // Update temperature value
            // });

            // await temperatureMqttService.connect();
          }
          if (topic == "Temperature") {
            mqttService.onSubscribe("Temperature");
            // subscribedToHumidity = true;
            // mqttService.onDataReceived = (topic, data) {
            //   if (topic == "class/maram_marzouki/humidity") {
            //     setState(() {
            //       topicValues["Humidity"] = data;
            //     });
            //   }
            //   // setState(() {
            //   //   topicValues["Humidity"] = data; // Update humidity value
            //   // });
            // }
            // await humidityMqttService.connect();
          }
        }
      });
    }
  }

  void handleSubscribe(String topic) async {
    print("USER ID: $userID");
    setState(() {
      subscribedTopics.add(topic);
    });
    // Connect to the appropriate service for the topic
    if (topic == "Temperature") {
      mqttService.onSubscribe("Temperature");
      // temperatureMqttService.onDataReceived = (data) {
      //   setState(() {
      //     topicValues["Temperature"] = data; // Update value immediately
      //   });
      // };
      // await temperatureMqttService.connect();
    } else if (topic == "Humidity") {
      mqttService.onSubscribe("Humidity");
      // humidityMqttService.onDataReceived = (data) {
      //   setState(() {
      //     topicValues["Humidity"] = data; // Update value immediately
      //   });
      // };
      // await humidityMqttService.connect();
    }

    // Save subscription to the database
    await _dbHelper.saveSubscription(userID!, topic);

    // Trigger a UI refresh after subscription
    setState(() {});
    // if (topic == "Temperature") {
    //   temperatureMqttService.onDataReceived = (data) {
    //     print("DATAAAA $data");
    //     setState(() {
    //       tempValue = data;
    //     });
    //   };
    //   temperatureMqttService.connect();
    // }
    // if (topic == "Humidity") {
    //   humidityMqttService.onDataReceived = (data) {
    //     print("DATAAAA $data");
    //     setState(() {
    //       humidityValue = data;
    //     });
    //   };
    //   humidityMqttService.connect();
    // }
    // await _dbHelper.saveSubscription(userID!, topic);
  }

  void handleUnsubscribe(String topic) async {
    setState(() {
      mqttService.onUnsubscribe(topic);
      subscribedTopics.remove(topic);
    });
    await _dbHelper.deleteSubscription(userID!, topic);
  }

  @override
  void dispose() {
    mqttService.client.disconnect();
    super.dispose();
  }

  void _logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  Future<void> showCo2Notification(double co2Value) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_co2_channel', // channel ID
      'High CO2 Alert', // channel name
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'well_received_action',
          'Well Received',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'High CO2 Level Detected',
      'CO2 level has reached $co2Value ppm!',
      platformChannelSpecifics,
    );
  }

  Future<void> showAlertDialog() async {
    setState(() {
      isDialogShown = true;
    }); // Mark the dialog as shown
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('High CO2 Alert'),
          content: Text('CO2 level has reached $co2CurrentValue ppm!'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _audioPlayer.stop();
                setState(() {
                  isAlertAcknowledged = true; // Mark the alert as acknowledged
                });
                Navigator.of(context).pop();
              },
              child: const Text('Well Received!'),
            ),
          ],
        );
      },
    );
  }

  void updateThreshold(double value) {
    setState(() {
      threshold = value;
    });
    updateThre(value); // Persist the updated threshold
  }

  Future<void> updateThre(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('threshold', value); // Persist value
    await _dbHelper.updateThreshold(userID!, value); // Database update
  }

  // void updateThreshold(double value) {
  //   setState(() {
  //     threshold = value;
  //   });
  //   updateThre(value); // Persist the updated threshold
  // }

  // void _triggerVibration() async {
  //   Vibration.vibrate(duration: 500);
  // }

  void _triggerAlert() async {
    Vibration.vibrate(duration: 500);

    await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    print("USSERRRR: $username $threshold");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // 'It\'s good to see you, $username!',
          "Detection App 🚨",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xffd7e3fc),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xffd7e3fc)),
            onPressed: () => _logoutUser(context),
          ),
        ],
        backgroundColor: const Color(0xff1d3557),
        // backgroundColor: const Color(0xffd7e3fc),
      ),
      backgroundColor: const Color(0xffd7e3fc),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff1d3557),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff1d3557).withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              height: 10,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              child: Container(
                padding: const EdgeInsets.all(5.0),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'It\'s good to see you, $username!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1d3557),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xff1d3557),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xff1d3557).withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ]),
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Threshold: ${threshold.toStringAsFixed(0)} ppm',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(
                                  Icons.mode_edit_outline,
                                  color: Colors.white,
                                  size: 17,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      final TextEditingController
                                          thresholdController =
                                          TextEditingController(
                                              text:
                                                  threshold.toStringAsFixed(0));
                                      return AlertDialog(
                                        title: Text('Set Threshold'),
                                        content: TextField(
                                          controller: thresholdController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              labelText: 'Threshold (ppm)',
                                              fillColor:
                                                  const Color(0xffd7e3fc)),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Color(0xff1d3557)),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              'Save',
                                              style: TextStyle(
                                                  color: Color(0xff1d3557)),
                                            ),
                                            onPressed: () {
                                              final newThreshold =
                                                  double.tryParse(
                                                          thresholdController
                                                              .text) ??
                                                      threshold;
                                              updateThreshold(newThreshold);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Form(
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: TextFormField(
                        //           decoration: InputDecoration(
                        //               labelText: "Threshold",
                        //               border: OutlineInputBorder(
                        //                   borderRadius: BorderRadius.circular(50),
                        //                   borderSide: BorderSide.none),
                        //               fillColor: Colors.white,
                        //               filled: true,
                        //               contentPadding: const EdgeInsets.symmetric(
                        //                   vertical: 9, horizontal: 9)),
                        //         ),
                        //       ),
                        //       const SizedBox(width: 8),
                        //       ElevatedButton(
                        //         onPressed: () {},
                        //         style: ElevatedButton.styleFrom(
                        //             backgroundColor: const Color(0xff1d3557)),
                        //         child: const Icon(
                        //           Icons.done,
                        //           color: Colors.white,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 25),
                        Center(
                          child: Container(
                            height: 260,
                            decoration: BoxDecoration(
                              color: const Color(0xff1d3557),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xff1d3557).withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CO2ProgressRing(
                                co2Level: co2CurrentValue / 10000),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Other topics:',
                          style: TextStyle(
                            color: Color(0xff1d3557),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: topics.length,
                          itemBuilder: (context, index) {
                            final topic = topics[index];
                            return subscribedTopics.contains(topic)
                                ? SubscribedToTopicCard(
                                    topicName: topic,
                                    mqttService: mqttService,
                                    onCO2Update: (value) {
                                      setState(() {
                                        co2CurrentValue = value;
                                      });
                                    },
                                    onUnsubscribe: () =>
                                        handleUnsubscribe(topic),
                                  )
                                : SubscribeTopicCard(
                                    topicName: topic,
                                    onSubscribe: () => handleSubscribe(topic),
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
