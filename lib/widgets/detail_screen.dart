import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:the_holy_quran/models/ayat.dart';
import 'package:the_holy_quran/models/surah.dart';

class DetailScreen extends StatefulWidget {
  final int noSurat;
  final int? lastAyat;

  const DetailScreen({
    super.key,
    required this.noSurat,
    this.lastAyat,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int currentSurah;
  late int currentAyat;
  late Surah surah;

  late AudioPlayer _audioPlayer;
  int? _playingAyat;

  late final int surahNumber;

  late Future<Surah> _surahFuture;
  final Map<int, GlobalKey> _ayatKeys = {};
  int? lastAyat;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();

    surahNumber = widget.noSurat;
    currentSurah = widget.noSurat;
    currentAyat = 1;

    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _playingAyat = null;
        });
      }
    });

    _surahFuture = _getDetailSurah();
    _loadLastAyat();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  int _globalAyatNumber(int surah, int ayat) {
    const startAyat = [
      0,
      1,
      8,
      295,
      493,
      670,
      789,
      954,
      1160,
      1236,
      1366,
      1474,
      1591,
      1707,
      1751,
      1802,
      1902,
      2029,
      2140,
      2250,
      2349,
      2483,
      2596,
      2673,
      2791,
      2856,
      2932,
      3159,
      3252,
      3341
    ];
    return startAyat[surah - 1] + ayat;
  }

  Future<void> _loadLastAyat() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      lastAyat = prefs.getInt('last_ayat_$surahNumber');
      _hasScrolled = false;
    });
  }

  void _scrollToLastAyatOnce() {
    if (_hasScrolled) return;
    if (lastAyat == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayatKeys[lastAyat!];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
        _hasScrolled = true;
      }
    });
  }

  Future<Surah> _getDetailSurah() async {
    var data = await Dio().get("https://equran.id/api/surat/$surahNumber");
    return Surah.fromJson(json.decode(data.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Surah>(
      future: _surahFuture,
      initialData: null,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xff040C23),
          );
        }
        Surah surah = snapshot.data!;

        if (!_hasScrolled &&
            lastAyat != null &&
            _ayatKeys.containsKey(lastAyat)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToLastAyatOnce();
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xff040C23),
          appBar: _appBar(context: context, Surah: surah),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _details(surah: surah),
              ),
            ],
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final ayat =
                      surah.ayat!.elementAt(index + (surahNumber == 1 ? 1 : 0));

                  final ayatKey =
                      _ayatKeys.putIfAbsent(ayat.nomor, () => GlobalKey());

                  return _ayatItem(
                    key: ayatKey,
                    ayat: ayat,
                  );
                },
                itemCount: surah.jumlahAyat + (surahNumber == 1 ? -1 : 0),
                separatorBuilder: (context, index) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ayatItem({required Key? key, required Ayat ayat}) {
    final bool isLastRead = ayat.nomor == lastAyat;
    final bool isPlaying = ayat.nomor == _playingAyat;

    return Padding(
      key: key,
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isPlaying
                  ? const Color(0xff9055FF).withOpacity(0.25)
                  : const Color(0xff121931),
              borderRadius: BorderRadius.circular(10),
              border: isLastRead
                  ? Border.all(color: const Color(0xff9055FF), width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: const Color(0xff9055FF),
                    borderRadius: BorderRadius.circular(27 / 2),
                  ),
                  child: Center(
                    child: Text(
                      '${ayat.nomor}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xffFFFFFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.share_outlined, color: Colors.white),
                const SizedBox(width: 16),

                // Audio Player Control
                InkWell(
                  onTap: () async {
                    final globalAyat =
                        _globalAyatNumber(surahNumber, ayat.nomor);

                    if (_playingAyat == ayat.nomor) {
                      await _audioPlayer.pause();
                      setState(() {
                        _playingAyat = null;
                      });
                    } else {
                      await _audioPlayer.stop();
                      await _audioPlayer.play(
                        UrlSource(
                          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalAyat.mp3',
                        ),
                      );

                      setState(() {
                        _playingAyat = ayat.nomor;
                      });
                    }
                  },
                  child: Icon(
                    _playingAyat == ayat.nomor
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: isPlaying ? const Color(0xffDF98FA) : Colors.white,
                  ),
                ),
                const SizedBox(width: 16),

                // Toggle Bookmark / Last Read
                InkWell(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();

                    if (isLastRead) {
                      // Jika diklik lagi saat aktif: Hapus penanda
                      await prefs.remove('last_ayat_$surahNumber');

                      final currentLastSurah = prefs.getInt('last_surah');
                      if (currentLastSurah == surahNumber) {
                        await prefs.remove('last_surah');
                      }

                      setState(() {
                        lastAyat = null;
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Penanda terakhir dibaca dihapus'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      // Jika belum aktif: Simpan penanda
                      await prefs.setInt('last_surah', surahNumber);
                      await prefs.setInt('last_ayat_$surahNumber', ayat.nomor);

                      setState(() {
                        lastAyat = ayat.nomor;
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Terakhir dibaca: Surah $surahNumber Ayat ${ayat.nomor}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: Icon(
                    isLastRead ? Icons.bookmark : Icons.bookmark_outline,
                    color: isLastRead ? const Color(0xffDF98FA) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (isPlaying)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'Sedang diputar',
                style: GoogleFonts.poppins(
                  color: const Color(0xffDF98FA),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (isLastRead)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'Terakhir dibaca',
                style: GoogleFonts.poppins(
                  color: const Color(0xffA19CC5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            ayat.ar,
            style: GoogleFonts.amiri(
              color: const Color(0xffFFFFFF),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Text(
            ayat.idn,
            style: GoogleFonts.poppins(
              color: const Color(0xffA19CC5),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _details({required Surah surah}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          children: [
            Container(
              height: 257,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffDF98FA),
                    Color(0xffB070FD),
                    Color(0xff9055FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: .2,
                child: Image.asset(
                  'assets/quran.png',
                  width: 324 - 55,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Text(
                    surah.namaLatin,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.arti,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Divider(
                    color: Colors.white.withOpacity(.35),
                    thickness: 2,
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        surah.tempatTurun.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${surah.jumlahAyat} Ayat",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Image.asset(
                    'assets/p.png',
                    width: 240,
                  ),
                ],
              ),
            )
          ],
        ),
      );

  AppBar _appBar({required BuildContext context, required Surah Surah}) =>
      AppBar(
        backgroundColor: const Color(0xff040C23),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.asset(
                  'assets/back.png',
                  width: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Surah.namaLatin,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Color(0xffFFFFFF),
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
                  ))
            ],
          ),
        ),
      );
}
