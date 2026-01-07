import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototipo/screens/txt2img_tab.dart';
import 'img2img_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bordado Bot'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Texto', style: GoogleFonts.montserrat()),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 18),
                  const SizedBox(width: 4),
                  Text('Imagem', style: GoogleFonts.montserrat()),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Imagem', style: GoogleFonts.montserrat()),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 18),
                  const SizedBox(width: 4),
                  Text('Imagem', style: GoogleFonts.montserrat()),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [Txt2ImgTab(), Img2ImgTab()],
      ),
    );
  }


}
