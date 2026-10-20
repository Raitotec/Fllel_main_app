import 'dart:math';

double RoundDouble(double val, int places){
  num mod = pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}