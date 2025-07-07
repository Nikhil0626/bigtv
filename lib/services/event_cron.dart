import 'dart:developer';

import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:cron/cron.dart';

class EventCron {
  static final EventCron _instance = EventCron._internal();
  final _cron = Cron();

  factory EventCron() {
    return _instance;
  }

  EventCron._internal();

  void start() {

   EventRepo().processAndPushEvents();
    _cron.schedule(Schedule.parse('*/15 * * * *'), () async {
      log("api call started");
      EventRepo().processAndPushEvents();
    });
  }



  void stop() {
    _cron.close();
  }
}
