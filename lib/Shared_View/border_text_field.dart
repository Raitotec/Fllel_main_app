
import 'package:flutter/material.dart';
import 'package:babco/Constans/Style.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart' as intl;

class BorderTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final Function(String) onChanged;
  final String? hint;
  final bool? password;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? lang;

  const BorderTextField({
    Key? key,
    required this.controller,
     this.label,
    required this.onChanged,
    this.hint,
    this.password,
    this.keyboardType,
    this.validator,
    this.lang
  }) : super(key: key);

  @override
  _GlobalTextFieldState createState() => _GlobalTextFieldState();
}

class _GlobalTextFieldState extends State<BorderTextField> {


  @override
  void initState() {
    super.initState();
    textDirection= (widget.controller!=null && widget.controller.text !=null && widget.controller.text.isNotEmpty)?
    intl.Bidi.detectRtlDirectionality(widget.controller.text)? TextDirection.rtl: TextDirection.ltr:widget.lang=="ar"?TextDirection.rtl:TextDirection.ltr;

    print("*****_GlobalTextField "+widget.controller.text);
  }

  TextDirection textDirection=TextDirection.rtl;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.0.w),
        //  padding: EdgeInsets.symmetric(vertical: 0.0.h, horizontal: 3.0.w),
        decoration:BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.transparent, width: 1.0),
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(5.0),
            topRight: const Radius.circular(5.0),
            bottomRight: const Radius.circular(5.0),
            bottomLeft: const Radius.circular(5.0),
          ),
        ),
        child:  Theme(
            data: Theme.of(context).copyWith(primaryColor: Style.MainColor),
            child: TextFormField(
              maxLines: 3,
              minLines: 1,
              textDirection: textDirection,
              scrollPadding: EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom),
              autovalidateMode :AutovalidateMode.onUserInteraction,
              controller: widget.controller,
              cursorErrorColor:Style.MainColor,
              cursorColor:Style.MainColor,
              style: TextStyle(fontSize: 16.0.sp,fontWeight: FontWeight.bold,color: Style.MainTextColor),
              obscureText: widget.password??false,
              keyboardType: widget.keyboardType??TextInputType.emailAddress,
              decoration: InputDecoration(
                // icon: Icon(Icons.home_work_outlined, size: 3.0.h),
                //  border: InputBorder.none,
                labelText: widget.label,
                labelStyle: TextStyle(fontSize: 16.0.sp,fontWeight: FontWeight.bold,color: Style.MainTextColor),
                hintStyle:  TextStyle(fontSize: 16.0.sp,fontWeight: FontWeight.bold,color: Style.GreyColor),
                hintText: widget.hint??"",
                errorStyle:  TextStyle(fontSize: 16.0.sp,fontWeight: FontWeight.bold,color:Style.MainTextColor),
                border:  OutlineInputBorder(),
               focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Style.MainTextColor, width: 1.0), // Border when focused
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Style.LightGreyColor, width: 1.0), // Border when enabled
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color:Style.MainTextColor, width: 1.0), // Border when there's an error
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color:Style.MainTextColor, width: 1.0), // Border when there's an error
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 2.0.w,vertical: 1.0.h),
                alignLabelWithHint:true,
                /*
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color:Style.MainTextColor, width: 1.0), // Border when there's an error
                ),*/
              ),
              validator: widget.validator,
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              onChanged: (value) {
                print("GlobalTextField  "+ value);
                if(value != null && value.isNotEmpty)
                {
                  setState(() {
                    if(intl.Bidi.detectRtlDirectionality(value))
                    {
                      textDirection=TextDirection.rtl;
                    }
                    else
                    {
                      textDirection= TextDirection.ltr;
                    }
                  });
                }
                // Call the onChanged function passed from the parent
                widget.onChanged(value);
              },
            )));
  }
}