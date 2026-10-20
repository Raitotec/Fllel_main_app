
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:babco/Localization/Translations.dart';
import 'package:geolocator/geolocator.dart';

import '../Shared_View/AlertView.dart';

class LocationData {
  static Position? currentLocation;
}

Future<Position?>getLocationData(BuildContext context)async
{
  try {


  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      print('Location services are disabled.');

      AlertView(context,"error",Translations.of(context)!.ErrorTitle,Translations.of(context)!.errorLocation);
      return Future.error('Location services are disabled.');

    }

    permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      print("Ex ----");
      permission = await Geolocator.requestPermission();
      print("&&&&");
      print(permission);
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        AlertView(context,"error",Translations.of(context)!.ErrorTitle,Translations.of(context)!.errorLocation);
        print('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
      else if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
     //   permission = await Geolocator.requestPermission();
       await AlertView(context,"error",Translations.of(context)!.ErrorTitle,Translations.of(context)!.errorLocation);
        AppSettings.openAppSettings(type: AppSettingsType.location);
        print( 'Location permissions are permanently denied, we cannot request permissions.');
        return Future.error(
            'Location permissions are permanently deniedForever, we cannot request permissions.');
      }

    }

    if (permission == LocationPermission.deniedForever) {
      await AlertView(context,"error",Translations.of(context)!.ErrorTitle,Translations.of(context)!.errorLocation);
      AppSettings.openAppSettings(type: AppSettingsType.location);
      print( 'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently deniedForever, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
 //   return await Geolocator.getCurrentPosition();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    LocationData.currentLocation = position;
    print( position.latitude);
    print( position.longitude);
    return position;
  }
  catch(e)
  {
    print("Ex ----"+e.toString());
    AlertView(context,"error",Translations.of(context)!.ErrorTitle,Translations.of(context)!.errorLocation);
    return null;
  }
}