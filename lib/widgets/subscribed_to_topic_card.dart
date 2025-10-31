import 'package:co2_detection_app_flutter/services/mqtt_service.dart';
import 'package:flutter/material.dart';

class SubscribedToTopicCard extends StatefulWidget {
  final String topicName;
  final VoidCallback onUnsubscribe;
  final MqttService mqttService;
  final Function(double) onCO2Update;
  const SubscribedToTopicCard({
    super.key,
    required this.topicName,
    required this.onUnsubscribe,
    required this.mqttService,
    required this.onCO2Update,
  });

  @override
  State<SubscribedToTopicCard> createState() => _SubscribedToTopicCardState();
}

class _SubscribedToTopicCardState extends State<SubscribedToTopicCard> {
  String tempValue = "";
  String humidityValue = "";
  double co2Value = 0;
  @override
  void initState() {
    super.initState();
    widget.mqttService.onDataReceived = (topic, data) => {
          if (topic == "class/maram_marzouki/co2")
            {widget.onCO2Update(double.tryParse(data) ?? 0.0)},
          if (topic == "class/maram_marzouki/temperature")
            {
              setState(() {
                tempValue = data;
              })
            },
          if (topic == "class/maram_marzouki/humidity")
            {
              setState(() {
                humidityValue = data;
              })
            }
        };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: widget.onUnsubscribe,
      child: Card(
        color: const Color(0xff1d3557),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.topicName} now',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  if (widget.topicName == "Temperature")
                    const Icon(
                      Icons.thermostat,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 4),
                  if (widget.topicName == "Temperature")
                    Text(
                      '$tempValue°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (widget.topicName == "Humidity")
                    const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 4),
                  if (widget.topicName == "Humidity")
                    Text(
                      '$humidityValue%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
