import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_holy_quran/models/surah.dart';
import 'package:the_holy_quran/tabs/juzamma_tab.dart';
import 'package:the_holy_quran/tabs/surah_tab.dart';
import 'package:the_holy_quran/widgets/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Pastikan import model Surah kamu di bagian atas
// import 'package:the_holy_quran/models/surah.dart'; // sesuaikan path model Surah

  Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSurahNo = prefs.getInt('last_surah');

    if (lastSurahNo == null) return null;

    final lastAyat = prefs.getInt('last_ayat_$lastSurahNo');
    if (lastAyat == null) return null;

    // Load daftar surah dari json local / API kamu
    // Contoh jika memakai rootBundle dari assets:
    String dataStr = await DefaultAssetBundle.of(context)
        .loadString('assets/datas/list-surah.json');
    List<Surah> surahList = surahFromJson(dataStr);

    // Cari surah yang nomornya cocok
    Surah currentSurah = surahList.firstWhere((s) => s.nomor == lastSurahNo);

    return {
      'surah': currentSurah, // Menyimpan objek Surah
      'ayat': lastAyat,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040C23),
      appBar: _appBar(),
      body: DefaultTabController(
        length: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _greeting(widget.username),
              ),
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xff040C23),
                automaticallyImplyLeading: false,
                shape: Border(
                    bottom: BorderSide(
                        width: 3,
                        color: const Color(0xffFFFFFF).withOpacity(.15))),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: _tab(),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                const SurahTab(),
                JuzammaTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TabBar _tab() {
    return TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: const Color(0xffA19CC5).withOpacity(0.70),
        labelColor: Colors.white,
        indicatorColor: const Color(0xff672CBC),
        indicatorWeight: 4,
        dividerColor: const Color(0xff040C23),
        tabs: [
          _tabItem(label: 'Surah'),
          _tabItem(label: 'Juzamma'),
        ]);
  }

  Tab _tabItem({required String label}) {
    return Tab(
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Column _greeting(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assalamualaikum',
          style: GoogleFonts.poppins(
            color: Color(0xffA19CC5),
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          username,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),

        // banner lama kamu

        const SizedBox(height: 24),
        Stack(
          children: [
            // Background Banner Gradient
            Container(
              height: 135,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffDF98FA),
                    Color(0xffB070FD),
                    Color(0xff9055FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Gambar Al-Qur'an di kanan bawah
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                'assets/quran.png',
                width: 155,
                fit: BoxFit.contain,
              ),
            ),

            // Konten Teks Lanjutkan Bacaan
            FutureBuilder<Map<String, dynamic>?>(
              future: getLastRead(),
              builder: (context, snapshot) {
                final data = snapshot.data;
                final Surah? surah = data?['surah'];
                final int? ayat = data?['ayat'];

                return Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: data == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(
                                    noSurat: surah!.nomor,
                                    lastAyat: ayat!,
                                  ),
                                ),
                              );
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 1. Label Last Read
                            Row(
                              children: [
                                const Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Last Read',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 2. Nama Surah (Menggunakan namaLatin dari model Surah)
                            Text(
                              surah != null ? surah.namaLatin : 'Belum Ada',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // 3. Nomor Ayat
                            Text(
                              ayat != null ? 'Ayat No: $ayat' : 'Ayat No: -',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        )
      ],
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: const Color(0xff040C23),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/sort.png',
                    width: 24,
                  )),
              const SizedBox(width: 8),
              const Text(
                'Quran App',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Image.asset(
                  'assets/search.png',
                  width: 24,
                ),
              ),
            ],
          ),
        ),
      );
}
