import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_holy_quran/models/surah.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_holy_quran/widgets/detail_screen.dart';

class JuzammaTab extends StatefulWidget {
  @override
  State<JuzammaTab> createState() => _JuzammaTabState();
}

class _JuzammaTabState extends State<JuzammaTab> {
// (✔) PENANDA SESUDAH BACA =>C
  // int? lastSurah;
  // int? lastAyat;

  // (3).
  Future<List<Surah>> _getJuzammaList() async {
    String data = await rootBundle.loadString(
      'assets/datas/list-surah.json',
    );

    List<Surah> allSurah = surahFromJson(data);

    return allSurah.where((surah) {
      return surah.nomor >= 78;
    }).toList();
  }

//  @override
//   void initState() {
//     super.initState();
//     _loadLastSurah();
//   }

//   Future<void> _loadLastSurah() async {
//     final prefs = await SharedPreferences.getInstance();
//     lastSurah = prefs.getInt('last_surah');
//     lastAyat = prefs.getInt('last_ayat');
//     setState(() {});
//   }

  @override
  Widget build(BuildContext context) {
    // W <c>=> (2).
    return FutureBuilder<List<Surah>>(
        future: _getJuzammaList(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // M => c = _surahItem | divider
          return Container(
            color: const Color(0xff040C23), //becround option
            child: ListView.separated(
                // + = => | detailscreen
                itemBuilder: (context, index) {
                  final Surah = snapshot.data![index];
                  return _surahItem(
                    context: context,
                    surah: Surah,
                    index: index,
                    //  isLastRead: lastSurah == surah.nomor,
                  );
                },
                separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: const Color(0xffFFFFFF).withOpacity(.15),
                    ),
                itemCount: snapshot.data!.length),
          );
        }));
  }

// =_surahItem
  Widget _surahItem({
    required BuildContext context,
    required Surah surah,
    required int index,
    // required bool isLastRead,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_surah', surah.nomor);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailScreen(noSurat: surah.nomor)));
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

                  //  if (isLastRead)
                  //     Container(
                  //       margin: EdgeInsets.only(left: 6),
                  //       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),

                  //       decoration: BoxDecoration(
                  //         color: Colors.amber,
                  //         borderRadius: BorderRadius.circular(6),
                  //       ),

                  //       child: Text(
                  //         'Terakhir dibaca',
                  //         // (24) badge penanda surah terakhir dibaca

                  //         style: GoogleFonts.poppins(
                  //           color: Colors.white,
                  //           fontSize: 11,
                  //         ),
                  //       ),
                  //     ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        surah.tempatTurun.name,
                        // (✔) menampilkan tempat turun (Mekkah / Madinah)
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xffDFCBF4).withOpacity(0.80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${surah.jumlahAyat} Ayat',
                        // (✔) menampilkan jumlah ayat dalam surat
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
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            )
          ],
        ),
      ),
    );
  }
}
