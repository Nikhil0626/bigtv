import 'dart:async';
import 'dart:developer';

import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:cron/cron.dart';

class EventCron {
  static final EventCron _instance = EventCron._internal();
  final _cron = Cron();
  Timer? _hourlyTimer;
  bool _isRunning = false;

  factory EventCron() {
    return _instance;
  }

  EventCron._internal();

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // 1. Check and send on app open if >= 1 hour has elapsed since last sync
    AnalyticsService.instance.checkAndSendOnAppOpen();
    EventRepo().processAndPushEvents();

    // 2. Cron: schedule for every 1 hour (at minute 0 of every hour)
    _cron.schedule(Schedule.parse('0 * * * *'), () async {
      log("[EventCron] Hourly cron triggered at minute 0");
      await AnalyticsService.instance.sendStoredEvents(force: true);
      await EventRepo().processAndPushEvents();
    });

    // 3. Periodic timer: every 1 hour (continuous 60-minute duration while app remains open)
    _hourlyTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      log("[EventCron] 1-hour periodic timer triggered");
      await AnalyticsService.instance.sendStoredEvents(force: true);
      await EventRepo().processAndPushEvents();
    });
  }

  void stop() {
    _cron.close();
    _hourlyTimer?.cancel();
    _hourlyTimer = null;
    _isRunning = false;
  }
}

