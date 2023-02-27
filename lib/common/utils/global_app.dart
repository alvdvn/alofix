// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class App {
  static final GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

}
DateFormat ddMMYYYYSlashFormat = DateFormat("dd/MM/yyyy");
DateFormat ddMMYYYYTimeSlashFormat = DateFormat('HH:mm - dd/MM/yyyy');
DateFormat YYYYMMddFormat = DateFormat("yyyy/MM/dd");