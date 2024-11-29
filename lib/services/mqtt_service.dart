import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String broker = 'broker.hivemq.com';
  // final String topic = 'class/maram_marzouki/co2';
  final List<String> topics = [
    'class/maram_marzouki/co2',
    'class/maram_marzouki/temperature',
    'class/maram_marzouki/humidity'
  ];
  final int port = 1883;
  late MqttServerClient client;

  Function(String, String)? onDataReceived;

  MqttService() {
    client = MqttServerClient(
        broker, 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
    client.port = port;
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.autoReconnect = true; // Enable auto-reconnect
    client.logging(on: true);
  }

  Future<void> connect() async {
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    try {
      await client.connect();
    } catch (e) {
      print('MQTT client connection failed - $e');
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage recMessage =
          messages[0].payload as MqttPublishMessage;
      final topic = messages[0].topic;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

      print("Received message on $topic: $payload");
      if (onDataReceived != null) {
        onDataReceived!(topic, payload);
      }
    });
    // client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
    //   final MqttPublishMessage recMessage =
    //       messages[0].payload as MqttPublishMessage;
    //   final payload =
    //       MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
    //   print("Received CO2 MESSAGE: $payload in ${messages[0]}");
    //   if (onDataReceived != null) {
    //     onDataReceived!(payload);
    //   }
    // });
  }

  void onConnected() {
    print('Connected to the MQTT broker');
    client.subscribe(topics[0], MqttQos.atMostOnce);
    print('Subscribed to ${topics[0]}');
  }

  void onSubscribe(String topic) {
    if (topic == "Temperature") {
      client.subscribe(topics[1], MqttQos.atMostOnce);
    }
    if (topic == "Humidity") {
      client.subscribe(topics[2], MqttQos.atMostOnce);
    }
  }

  void onUnsubscribe(String topic) {
    if (topic == "Temperature") {
      client.unsubscribe(topics[1]);
    }
    if (topic == "Humidity") {
      client.unsubscribe(topics[2]);
    }
  }

  void onDisconnected() {
    print("disconnected from the MQTT broker");
    // print('Disconnected from broker, attempting to reconnect...');
    // Future.delayed(const Duration(seconds: 5), () async {
    //   try {
    //     await client.connect();
    //     print('Reconnected to broker');
    //     client.subscribe('class/maram_marzouki/co2', MqttQos.atMostOnce);
    //   } catch (e) {
    //     print('Reconnection failed: $e');
    //     onDisconnected(); // Retry until successful
    //   }
    // });
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
