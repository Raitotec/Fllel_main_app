
 import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_custom.dart';
 import 'package:intl/intl.dart';

String getFormatDate(DateTime value)
 {
   final DateFormat formatter = DateFormat('yyyy-MM-dd',"en");
   final String Date = formatter.format(value);
   print(Date);
   return Date;
 }

 String getFormatTime(TimeOfDay value)
 {
   DateTime selectedDate = DateTime.now();
   String Time= DateFormat("h:mma").format(DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
       value.hour, value.minute));
   return Time;
 }