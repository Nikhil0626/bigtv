import 'dart:developer';

import 'package:chotanews/aggricator_screens/ad_manager_screen/ad_screen/banner_300x50_size.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
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
    _cron.schedule(Schedule.parse('*/60 * * * *'), () async {
      log("api call started");
      EventRepo().processAndPushEvents();
    });
  }


  void stop() {
    _cron.close();
  }
}
