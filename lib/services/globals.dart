import 'package:logger/logger.dart';

enum TestingEnum { none, unit, integration }

// ignore: non_constant_identifier_names
TestingEnum global_testing_active = TestingEnum.none;

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    printEmojis: false,
  ),
);
