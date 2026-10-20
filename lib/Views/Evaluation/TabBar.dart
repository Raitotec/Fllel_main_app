
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../Constans/Style.dart';

class TabItem {
  final String label;
  final IconData icon;

  TabItem({
    required this.label,
    required this.icon,
  });
}

class AnimatedTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;


  const AnimatedTabBar({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          tabs.length,
              (index) => Expanded(
            child: _buildTabItem(
              tab: tabs[index],
              isActive: selectedIndex == index,
              onTap: () => onTabChanged(index),
            ),
          ),
        ),
      ),
    );

  }

  Widget _buildTabItem({
    required TabItem tab,
    required bool isActive,
    required VoidCallback onTap,
  }) {

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 50),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 1.3.h),
        decoration: BoxDecoration(
          gradient: isActive ?  Style.Tab : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                tab.icon,
                key: ValueKey(isActive),
                color: isActive
                    ? ( Colors.white)
                    : ( Style.GreyColor),
                size: 3.0.h,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              tab.label,
              style: TextStyle(
                color: isActive
                    ? ( Colors.white)
                    : ( Style.MainTextColor),
                fontSize: 16.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );

  }

}
