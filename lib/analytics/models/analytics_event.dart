import 'dart:convert';
import 'package:uuid/uuid.dart';

class AnalyticsEvent {
  final String eventId;
  final String eventName;
  final DateTime dateTime;
  final String appVersion;
  final Map<String, dynamic> properties;

  AnalyticsEvent({
    String? eventId,
    required this.eventName,
    DateTime? dateTime,
    required this.appVersion,
    Map<String, dynamic>? properties,
  })  : eventId = eventId ?? const Uuid().v4(),
        dateTime = dateTime ?? DateTime.now().toUtc(),
        properties = properties ?? {};

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'eventName': eventName,
        'dateTime': dateTime.toUtc().toIso8601String(),
        'appVersion': appVersion,
        'properties': properties,
      };

  String toJsonString() => jsonEncode(toJson());

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      appVersion: json['appVersion'] as String,
      properties: json['properties'] != null
          ? Map<String, dynamic>.from(json['properties'] as Map)
          : {},
    );
  }
}
