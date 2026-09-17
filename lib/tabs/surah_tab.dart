import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_holy_quran/models/surah.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_holy_quran/widgets/detail_screen.dart';

class SurahTab extends StatefulWidget {
  const SurahTab({super.key});

  @override
  State<SurahTab> createState() => _SurahTabState();
}

class _SurahTabState extends State<SurahTab> {
  int? lastSurah;
  int? lastAyat;

  Future<List<Surah>> _getSurahList() async {
    String data = await rootBundle.loadString('assets/datas/list-surah.json');
    return surahFromJson(data);
  }

  @override
  void initState() {
    super.initState();
    _loadLastSurah();
  }

  Future<void> _loadLastSurah() async {
    final prefs = await SharedPreferences.getInstance();
    lastSurah = prefs.getInt('last_surah');
    lastAyat = prefs.getInt('last_ayat');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Surah>>(
      future: _getSurahList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: const Color(0xff040C23), // 🔥 background option
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: const Color(0xffFFFFFF).withOpacity(.15),
            ),
            itemBuilder: (context, index) {
              final surah = snapshot.data![index];
              return _surahItem(
                context: context,
                surah: surah,
                index: index,
                isLastRead: lastSurah == surah.nomor,
              );
            },
          ),
        );
      },
    );
  }

  Widget _surahItem({
    required BuildContext context,
    required Surah surah,
    required int index,
    required bool isLastRead,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_surah', surah.nomor);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailScreen(noSurat: surah.nomor),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // 🔢 nomor surat
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/outline_border.png',
                  width: 38,
                ),
                Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xffFFFFFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // 📘 nama surat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.namaLatin,
                    style: GoogleFonts.poppins(
                      color: const Color(0xffFFFFFF),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

// ✅ BADGE TERAKHIR DIBACA
                  if (isLastRead)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xffD3BBEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Terakhir dibaca',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        surah.tempatTurun.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xffD3BBEB),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${surah.jumlahAyat} Ayat',
                        style: GoogleFonts.poppins(
                          color: const Color(0xffFFFFFF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 🕌 arabic
            Text(
              surah.nama,
              style: GoogleFonts.amiri(
                color: const Color(0xffFFFFFF),
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
