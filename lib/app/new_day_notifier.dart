import 'dart:async';
import 'package:insomnia_checklist/services/utils.dart';

Stream<DateTime> newDayStream(Duration interval) {
  late StreamController<DateTime> controller;
  Timer? timer;
  DateTime prevDate = DateTime.now();

  void tick(Timer _) {
    final now = DateTime.now();
    if (!prevDate.isSameDay(now)) {
      controller.add(now);
    }
    prevDate = now;
  }

  Stream<DateTime> start() {
    timer = Timer.periodic(interval, tick);
    prevDate = DateTime.now();
    return controller.stream;
  }

  Stream<DateTime> stop() {
    timer?.cancel();
    timer = null;
    return controller.stream;
  }

  controller = StreamController<DateTime>(
    onListen: start,
    onPause: stop,
    onResume: start,
    onCancel: stop,
  );

  return controller.stream;
}
