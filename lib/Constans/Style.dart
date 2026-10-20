import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Style {
  //colors
  static Color MainColor = Color(0xff1C6096);
  static Color MainColor2 = Color(0xff1C6096);
  static Color MainColor3 = Color(0xff1C6096);
  static Color SecondryColor = Color(0xffFFCB22);
  static Color SecondryColor2 = Color(0xff1C6096);
  static Color ThirdColor = Color(0xff1C6096);
  static Color MainTextColor = Color(0xff000000);
  static Color MainTextColor2 = Color(0xffFFCB22);
  static Color BlackColor = Color(0xff000000);
  static Color WhiteColor = Color(0xffffffff);
  static Color WhiteBlueColor = Color(0xffe8f1f9);
  static Color GreyColor = Colors.black54;
  static Color LightGreyColor = Colors.black12;
  static Color MediumGreyColor = Colors.black38;
  static Color BlueColor1 = Color(0xffdff1f9);
  static Color BlueColor = Color(0xffd5e5ec);
  static Color GreyColor1 = Color(0xffd8d3d3);
  static Color BorderTextFieldColor = Color(0xffd8d3d3);
  static Color BorderTextFieldFocusedColor = Color(0xffFFCB22);
  //fontsize
  static double FontSize25 = 25.0.sp;
  static double FontSize20 = 20.0.sp;
  static double FontSize18 = 18.0.sp;
  static double FontSize16 = 16.0.sp;
  static double FontSize14 = 16.0.sp;
  static double FontSize12 = 16.0.sp;
  static double FontSize10 = 16.0.sp;

  //textStyle
  static TextStyle Header1 = TextStyle(
      color: WhiteColor, fontSize: 25.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Header2 = TextStyle(
      color: WhiteColor, fontSize: 20.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Header3 = TextStyle(
      color: WhiteColor, fontSize: 18.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Header4 = TextStyle(
      color: WhiteColor, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Header5 = TextStyle(
      color: WhiteColor, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Header6 = TextStyle(
      color: WhiteColor, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Header7 = TextStyle(
      color: WhiteColor, fontSize: 14.0.sp, fontWeight: FontWeight.bold);
  static TextStyle MainText25Bold = TextStyle(
      color: MainTextColor, fontSize: 25.0.sp, fontWeight: FontWeight.bold);
  static TextStyle MainText20Bold = TextStyle(
      color: MainTextColor, fontSize: 20.0.sp, fontWeight: FontWeight.bold);
  static TextStyle MainText18Bold = TextStyle(
      color: MainTextColor, fontSize: 18.0.sp, fontWeight: FontWeight.bold);
  static TextStyle MainText16Bold = TextStyle(
      color: MainTextColor, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle MainText14Bold = TextStyle(
      color: MainTextColor, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle MainText15Bold = TextStyle(
      color: MainTextColor, fontSize: 15.0.sp, fontWeight: FontWeight.bold);
  static TextStyle MainText25 = TextStyle(
      color: MainTextColor, fontSize: 25.0.sp);
  static TextStyle MainText20 = TextStyle(
      color: MainTextColor, fontSize: 20.0.sp);
  static TextStyle MainText18 = TextStyle(
      color: MainTextColor, fontSize: 18.0.sp);
  static TextStyle MainText16 = TextStyle(
      color: MainTextColor, fontSize: 16.0.sp);
  static TextStyle MainText14 = TextStyle(
      color: MainTextColor, fontSize: 16.0.sp);
  static TextStyle MainText12 = TextStyle(
      color: MainTextColor, fontSize: 16.0.sp);
  static TextStyle MainText10 = TextStyle(
      color: MainTextColor, fontSize: 16.0.sp);
  static TextStyle MainText9 = TextStyle(
      color: MainTextColor, fontSize: 9.0.sp);
  static TextStyle MainText8 = TextStyle(
      color: MainTextColor, fontSize: 8.0.sp);
  static TextStyle SecondryText25 = TextStyle(
      color: SecondryColor, fontSize: 25.0.sp);
  static TextStyle SecondryText20 = TextStyle(
      color: SecondryColor, fontSize: 20.0.sp);
  static TextStyle SecondryText18 = TextStyle(
      color: SecondryColor, fontSize: 18.0.sp);
  static TextStyle SecondryText16 = TextStyle(
      color: SecondryColor, fontSize: 16.0.sp);
  static TextStyle SecondryText14 = TextStyle(
      color: SecondryColor, fontSize: 16.0.sp);
  static TextStyle SecondryText12 = TextStyle(
      color: SecondryColor, fontSize: 16.0.sp);
  static TextStyle SecondryText10 = TextStyle(
      color: SecondryColor, fontSize: 16.0.sp);
  static TextStyle GreyText25 = TextStyle(color: GreyColor, fontSize: 25.0.sp);
  static TextStyle GreyText20 = TextStyle(color: GreyColor, fontSize: 20.0.sp);
  static TextStyle GreyText18 = TextStyle(color: GreyColor, fontSize: 18.0.sp);
  static TextStyle GreyText16 = TextStyle(color: GreyColor, fontSize: 16.0.sp);
  static TextStyle GreyText14 = TextStyle(color: GreyColor, fontSize: 16.0.sp);
  static TextStyle GreyText12 = TextStyle(color: GreyColor, fontSize: 16.0.sp);
  static TextStyle GreyText10 = TextStyle(color: GreyColor, fontSize: 16.0.sp);
  static TextStyle Secondry25Bold = TextStyle(
      color: SecondryColor, fontSize: 25.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Secondry20Bold = TextStyle(
      color: SecondryColor, fontSize: 20.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Secondry18Bold = TextStyle(
      color: SecondryColor, fontSize: 18.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Secondry16Bold = TextStyle(
      color: SecondryColor, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Secondry14Bold = TextStyle(
      color: SecondryColor, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle Secondry12Bold = TextStyle(
      color: SecondryColor, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle BlackText25Bold = TextStyle(
      color: Colors.black, fontSize: 25.0.sp, fontWeight: FontWeight.bold);
  static TextStyle BlackText20Bold = TextStyle(
      color: Colors.black, fontSize: 20.0.sp, fontWeight: FontWeight.bold);
  static TextStyle BlackText18Bold = TextStyle(
      color: Colors.black, fontSize: 18.0.sp, fontWeight: FontWeight.bold);
  static TextStyle BlackText16Bold = TextStyle(
      color: Colors.black, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle BlackText14Bold = TextStyle(
      color: Colors.black, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static TextStyle BlackText12Bold = TextStyle(
      color: Colors.black, fontSize: 16.0.sp, fontWeight: FontWeight.bold);
  static double SizeIcon = 3.0.h;
  static double SizeIconPrint = 5.0.h;
  static double SizeIconAppBar = 4.0.h;

  //boxDecoraation
  static BoxDecoration BoxDecoration1 = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Style.MainColor, Style.MainColor2]),
  );

  static BoxDecoration BoxDecorationWithRadius = BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [Style.MainColor2, Style.SecondryColor]),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.0),
        bottomRight: Radius.circular(40.0),
      )
  );

  static BoxDecoration BoxDecorationWithRadiusHome = BoxDecoration(
      color: Colors.white,
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Style.WhiteBlueColor, Style.SecondryColor])
      ,
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(45.0),
        topRight: const Radius.circular(0.0),
        bottomRight: const Radius.circular(45.0),
        bottomLeft: const Radius.circular(0.0),
      )
  );

  static BoxDecoration BoxDecorationWithRadiusOny = BoxDecoration(
      color: Style.WhiteBlueColor,
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(45.0),
        topRight: const Radius.circular(0.0),
        bottomRight: const Radius.circular(45.0),
        bottomLeft: const Radius.circular(0.0),
      )
  );

  static BoxDecoration BoxDecorationNoRadius = BoxDecoration(
      color: Style.WhiteColor,
      border: Border.all(color: Style.SecondryColor),
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
        bottomRight: const Radius.circular(5.0),
        bottomLeft: const Radius.circular(5.0),
      )
  );
  static BoxDecoration BoxDecorationRadius = BoxDecoration(
      color: Colors.black12,
     // border: Border.all(color: Style.MainColor),
      borderRadius: new BorderRadius.all(Radius.circular(10.0))
  );

  static BoxDecoration BoxDecorationPetrolstationProducts = BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Style.MainColor,
            Style.SecondryColor,
            Style.SecondryColor,
            Style.SecondryColor2
          ]),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.0),
        bottomRight: Radius.circular(40.0),
      ));

  static BoxDecoration BoxDecorationWhiteBlue = BoxDecoration(
      color: Style.WhiteColor,
      border: Border.all(color: Style.WhiteBlueColor),
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
        bottomRight: const Radius.circular(5.0),
        bottomLeft: const Radius.circular(5.0),
      )
  );

  static BoxDecoration BoxDecorationBoxShadow = BoxDecoration(
      color: Style.WhiteColor,
      border: Border.all(color:Style.MainTextColor, width: 2.5),
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
        bottomRight: const Radius.circular(5.0),
        bottomLeft: const Radius.circular(5.0),
      ),
      boxShadow: [
        BoxShadow(color:Style.MainTextColor.withOpacity(0.7),
            spreadRadius: 9,
            blurRadius: 9,
            offset: Offset(4, 8))
      ]
  );

  static BoxDecoration BoxDecorationBoxShadowGreyColor = BoxDecoration(
      color: Style.WhiteColor,
      border: Border.all(color: Colors.white, width: 2.5),
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
        bottomRight: const Radius.circular(5.0),
        bottomLeft: const Radius.circular(5.0),
      ),
      boxShadow: [
        BoxShadow(color: Style.GreyColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(1, 1))
      ]
  );

  static BoxDecoration BoxDecorationBlue = BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Style.BlueColor, Style.BlueColor1, Style.BlueColor1]),
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
        bottomRight: const Radius.circular(5.0),
        bottomLeft: const Radius.circular(5.0),
      ),
      boxShadow: [
        BoxShadow(color: Style.LightGreyColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 9,
            offset: Offset(7, 7))
      ]
  );

  static BoxDecoration BoxDecorationLightGreyColor = BoxDecoration(
      color: Style.LightGreyColor,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
        bottomRight: const Radius.circular(5.0),
        bottomLeft: const Radius.circular(5.0),
      ),
      boxShadow: [
        BoxShadow(color: Style.LightGreyColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 9,
            offset: Offset(7, 7))
      ]
  );


  static BoxDecoration ButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Style.MainColor, Style.MainColor2]),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(40.0),
      bottomRight: Radius.circular(40.0),
      topRight: Radius.circular(40.0),
      bottomLeft: Radius.circular(40.0),
    ),);
  static BoxDecoration ButtonSecondryDecoration = BoxDecoration(
    color: Style.SecondryColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(40.0),
      bottomRight: Radius.circular(40.0),
      topRight: Radius.circular(40.0),
      bottomLeft: Radius.circular(40.0),
    ),);
  static BoxDecoration WhiteDecoration = BoxDecoration(
      color: Style.WhiteColor,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(15.0),
        topRight: const Radius.circular(15.0),
        bottomRight: const Radius.circular(15.0),
        bottomLeft: const Radius.circular(15.0),
      ),
      boxShadow: [
        BoxShadow(
            color: Style.LightGreyColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(7, 7))
      ]
  );
static BoxDecoration SecondryColorDecoration = BoxDecoration(
    color: Style.SecondryColor,
    borderRadius: BorderRadius.only(
      topLeft: const Radius.circular(5.0),
      topRight: const Radius.circular(5.0),
      bottomRight: const Radius.circular(5.0),
      bottomLeft: const Radius.circular(5.0),
    ),
    boxShadow: [
      BoxShadow(
          color: Style.LightGreyColor.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(5, 5))
    ]
);
  static BoxDecoration SecondryColorDecorationNoBoxShadow = BoxDecoration(
      color: Style.SecondryColor,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
        bottomRight: const Radius.circular(5.0),
        bottomLeft: const Radius.circular(5.0),
      ),
     border: Border.all(color: Style.LightGreyColor,width: 2.0)

  );

  //Gradient

  static LinearGradient LinearGradient1 = LinearGradient(
      colors: [Style.MainColor2, Style.SecondryColor]);
  static LinearGradient Tab = LinearGradient(
      colors: [Style.MainColor, Style.MainColor.withOpacity(0.7),Style.MainColor,]);
  static Container VerticalLine = Container(
    margin: EdgeInsets.symmetric(horizontal: 2.0.w),
    width: 0.5.w,
    height: 5.0.h,
    color: Colors.black26,
  );
}
