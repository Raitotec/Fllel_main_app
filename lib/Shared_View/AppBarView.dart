import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:sizer/sizer.dart';

import '../Constans/Style.dart';
import '../Localization/ScopeModelWrapper.dart';
import '../Models/LanguageModel.dart';
import '../Routes/route_constants.dart';



 AppBarWithlanguage(BuildContext context, String header) {
   return AppBar(
     title: Text(header, style: TextStyle(
         color: Colors.white, fontSize: 22.0.sp, fontWeight: FontWeight.bold)),
     centerTitle: true,
     flexibleSpace: Container(
       decoration: Style.BoxDecoration1,
     ),
     toolbarHeight: 8.0.h,
     elevation: 0,
     leadingWidth: 14.0.w,
     leading: Builder(
       builder: (context) => Padding(
         padding: const EdgeInsets.only(left: 8),
         child: IconButton(
           icon: Icon(
             Icons.menu,
             size: 4.0.h,
             color: Colors.white,
           ),
           onPressed: () => Scaffold.of(context).openDrawer(),
         ),
       ),
     ),
     actions: <Widget>[
       ScopedModelDescendant<AppModel>(
           builder: (context, child, model) =>
               InkWell(child: Padding(
                 padding: EdgeInsets.fromLTRB(1.5.w, 1.5.h, 1.5.w, 0),
                 child: Icon(Icons.language, size: 4.0.h,color: Colors.white,),
               ),
                 onTap: () {
                   model.changeDirection();
                   Navigator.pushNamedAndRemoveUntil(context, splashRoute,(Route<dynamic> r)=>false);

                 },
               )),
     ],
   );
 }

 AppBarWithBack(BuildContext context, String header) {
   return AppBar(
     elevation: 0,
     centerTitle: true,
     title: Text(header,style: Style.Header2,),
     flexibleSpace: Container(
       decoration: Style.BoxDecoration1,
     ),
     toolbarHeight: 8.0.h,

     leadingWidth: 14.w,
     leading: Builder(
         builder: (context) =>IconButton(
           icon: Icon(
             Icons.menu,
             size: 4.h,
             color: Colors.white,
           ),
           onPressed: () => Scaffold.of(context).openDrawer(),
         )),
     actions: <Widget>[
       Padding(
           padding: EdgeInsets.all(1.5.w),
           child: GestureDetector(
             child: Icon(Icons.arrow_forward, color: Colors.white,
                 size: Style.SizeIconAppBar),
             onTap: () => Navigator.pop(context, false),
           )
       ),
     ],
   );

 }

AppBarWithBackOnly(BuildContext context, String header) {
  return AppBar(
    centerTitle: true,
    title: Text(header,style: Style.Header2,),
    flexibleSpace: Container(
      decoration: Style.BoxDecoration1,
    ),
    toolbarHeight: 8.0.h,
    automaticallyImplyLeading: false,
    actions: <Widget>[
      Padding(
          padding: EdgeInsets.all(1.5.w),
          child: GestureDetector(
            child: Icon(Icons.arrow_forward, color: Colors.white,
                size: Style.SizeIconAppBar),
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context, false);
              }
            },
          )
      ),
    ],
  );

}