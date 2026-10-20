import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Api/CheckVersionApi.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_View/DrawerView.dart';
import 'main_page.dart';
import 'services_page.dart';
import 'location_station.dart';
import 'loyalty_page.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final _shell = GlobalKey<ScaffoldState>();
  int _page = 0;
  bool _checkedVersion = false;
  @override
  void initState() { super.initState(); _page = widget.initialIndex.clamp(0, 4); }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedVersion) {
      _checkedVersion = true;
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) checkVersion(context); });
    }
  }
  @override
  Widget build(BuildContext context) {
    final ar = LanguageData.languageData == 'ar';
    final labels = ar ? ['الرئيسية', 'المحطات', 'الخدمات', 'المكافآت', 'حسابي']
      : ['Home', 'Stations', 'Services', 'Rewards', 'Account'];
    const icons = [Icons.home_outlined, Icons.location_on_outlined,
      Icons.format_list_bulleted, Icons.card_giftcard, Icons.person_outline];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark, systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(key: _shell, drawer: DrawerList(context), backgroundColor: const Color(0xFFF7FAFD),
        body: SafeArea(child: switch (_page) {
          1 => const MapLocationStationScreen(), 2 => const ServicesPage(id: ''),
          3 => const LoyaltySystemPage(embedded: true),
          4 => const AccountPage(),
          _ => MainScreen(onStations: () => setState(() => _page = 1),
            onServices: () => setState(() => _page = 2), onMenu: () => _shell.currentState?.openDrawer()),
        }),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2EBF3)))),
          child: SafeArea(top: false, child: Row(children: List.generate(5, (index) {
            final selected = index == _page;
            return Expanded(child: InkWell(onTap: () {
              setState(() => _page = index);
            }, child: Padding(padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(selected && index == 0 ? Icons.home_rounded : icons[index],
                  color: selected ? const Color(0xFF1C6096) : const Color(0xFF64748B), size: 25),
                const SizedBox(height: 4),
                Text(labels[index], maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? const Color(0xFF1C6096) : const Color(0xFF64748B))),
                const SizedBox(height: 5),
                Container(width: 22, height: 3, decoration: BoxDecoration(
                  color: selected ? const Color(0xFFFFCB22) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8))),
              ])),
            ));
          }))),
        )),
    );
  }
}
