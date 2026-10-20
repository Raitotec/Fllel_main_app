import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Models/PinDataModel.dart';

List<PinDataModel> Get_Pin_test() {
  var obj = <PinDataModel>[];
  var images = <String>[
    "https://images.adsttc.com/media/images/5da3/9ead/3312/fd25/b100/00de/large_jpg/stringio.jpg?1571004070",
    "https://media.istockphoto.com/id/134118323/photo/retro-gas-station.jpg?s=612x612&w=0&k=20&c=RFjBndH3pN7JMdhKLgZop2kkkXvcu26FXKmy5Dy2j_U=",
    "https://cdn.shrm.org/image/upload/c_crop%2Ch_768%2Cw_1365%2Cx_0%2Cy_0/c_fit%2Cf_auto%2Cq_auto%2Cw_767/v1/Legal%20and%20Compliance/Shell_gas_station_e6hhby?databtoa=eyIxNng5Ijp7IngiOjAsInkiOjAsIngyIjoxMzY1LCJ5MiI6NzY4LCJ3IjoxMzY1LCJoIjo3Njh9fQ%3D%3D"
  ];
  LatLng center = LatLng(37.422131, -122.084801);
  for (int i = 1; i < 20; i++) {
    var _PinData = new PinDataModel(
        i,
        "gas  $i",
        "address",
        "12345",
        "4",
        center.latitude + sin(i * pi / 6.0) / 20.0,
        center.longitude + cos(i * pi / 6.0) / 20.0,
        images,
    "ex@ex.com");
    obj.add(_PinData);
  }
  return obj;
}