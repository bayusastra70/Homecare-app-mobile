import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:homecare_app/pages/tabs/home_tab.dart';
import 'package:homecare_app/pages/tabs/layanan_tab.dart';
import 'package:homecare_app/pages/tabs/profile_tab.dart';
import 'package:homecare_app/pages/tabs/pesanan_tab.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;
  final bool showSuccess;

  const DashboardPage({
    Key? key,
    this.initialIndex = 0,
    this.showSuccess = false,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showSuccess && !_dialogShown) {
        _dialogShown = true;
        SmartDialog.show(
          builder:
              (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF2E7D32),
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Checkout Berhasil",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pesanan Anda telah berhasil dibuat.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => SmartDialog.dismiss(),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF2E7D32),
                      ),
                      child: const Text("Tutup"),
                    ),
                  ],
                ),
              ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const HomeTab(),
      PesananTab(showSuccess: widget.showSuccess),
      const ProfileTab(),
      const LayananTab(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: const Color(0xFF9E9E9E),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_rounded),
            label: 'Layanan',
          ),
        ],
      ),
    );
  }
}
