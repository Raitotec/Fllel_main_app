
import 'package:babco/Localization/Translations.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../Constans/Style.dart';

class CustomDropdownButton2<T> extends StatelessWidget {
  CustomDropdownButton2({
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    this.selectedItemBuilder,
    this.hintAlignment,
    this.valueAlignment,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonDecoration,
    this.buttonElevation,
    this.icon,
    this.iconSize,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.itemHeight,
    this.itemPadding,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.dropdownElevation,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    this.offset = Offset.zero,
    super.key,
  });
  final String hint;
  final T? value;
  final List<T> dropdownItems;
  final ValueChanged<T?>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final Alignment? hintAlignment;
  final Alignment? valueAlignment;
  final double? buttonHeight, buttonWidth;
  final EdgeInsetsGeometry? buttonPadding;
  final BoxDecoration? buttonDecoration;
  final int? buttonElevation;
  final Widget? icon;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? itemHeight;
  final EdgeInsetsGeometry? itemPadding;
  final double? dropdownHeight, dropdownWidth;
  final EdgeInsetsGeometry? dropdownPadding;
  final BoxDecoration? dropdownDecoration;
  final int? dropdownElevation;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final Offset offset;
  TextEditingController searchController= new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isDense: true,
        //To avoid long text overflowing.
        isExpanded: true,
        hint: Container(
          alignment: hintAlignment,
          child: Text(
              hint,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Style.GreyText14
          ),
        ),
        value: value,
        items: dropdownItems
            .map((T item) => DropdownMenuItem<T>(
          value: item,
          child: Container(
            alignment: valueAlignment,
            padding: EdgeInsets.symmetric(horizontal: 0.5.w),
            child: Text(
                item.toString(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Style.MainText16Bold
            ),
          ),
        ))
            .toList(),
        onChanged: onChanged,
        selectedItemBuilder: selectedItemBuilder,
        buttonStyleData: ButtonStyleData(
          height: buttonHeight ?? 3.5.h,
          // width: buttonWidth ?? 140,
          padding: EdgeInsets.zero,
          decoration: buttonDecoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
          elevation: buttonElevation,
        ),
        iconStyleData: IconStyleData(
          icon: Icon(Icons.arrow_drop_down,size: 2.5.h,color: Style.MainColor,),
          openMenuIcon: Icon(Icons.arrow_drop_up,size: 2.5.h,color: Style.SecondryColor),
        ),
        dropdownStyleData: DropdownStyleData(
          //Max height for the dropdown menu & becoming scrollable if there are more items. If you pass Null it will take max height possible for the items.
          maxHeight: dropdownHeight ?? 25.0.h,
          width: dropdownWidth ?? 30.0.w,

          padding: dropdownPadding,
          decoration: dropdownDecoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
          elevation: dropdownElevation ?? 8,
          //Null or Offset(0, 0) will open just under the button. You can edit as you want.
          offset: offset,
          scrollbarTheme: ScrollbarThemeData(
            radius: scrollbarRadius ?? const Radius.circular(40),
            thickness: scrollbarThickness != null
                ? MaterialStateProperty.all<double>(scrollbarThickness!)
                : null,
            thumbVisibility: scrollbarAlwaysShow != null
                ? MaterialStateProperty.all<bool>(scrollbarAlwaysShow!)
                : null,
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: itemHeight ?? 5.0.h,
          padding: itemPadding ??  EdgeInsets.only(left: 3.0.w, right: 3.0.w),
        ),
        dropdownSearchData: DropdownSearchData(
          searchInnerWidgetHeight: 5.0.h,
          searchController: searchController,
          searchInnerWidget: Container(
            margin:  EdgeInsets.symmetric(vertical: 1.0.h,horizontal: 2.0.w),
            child: TextFormField(
              maxLines: 1,
              scrollPadding: EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom),
              cursorErrorColor: Style.SecondryColor,
              cursorColor: Style.SecondryColor,
              controller: searchController,
              style: Style.MainText16,
              decoration: InputDecoration(
                // hintText: getTranslated(context, "search"),
                  labelText: Translations.of(context)!.search,
                  labelStyle:Style.MainText16,
                  hintStyle: Style.MainText16.copyWith(color: Style.MediumGreyColor),
                  errorStyle: Style.MainText14.copyWith(color: Colors.red),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Style.BorderTextFieldFocusedColor, width: 1.0), // Border when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Style.BorderTextFieldColor, width: 1.0), // Border when enabled
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0), // Border when there's an error
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0), // Border when there's an error
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.0.h,horizontal: 2.0.w)
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value
                .toString()
                .toLowerCase()
                .contains(searchValue.toLowerCase());
          },

        ),
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            searchController.clear();
          }
        },
      ),
    );
  }
}