import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_holy_quran/navigation/main_navigation.dart';
import 'package:the_holy_quran/utils/username_validator.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController namecontroller = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  bool isFocused = false;
//
  void dispose() {
    _nameFocus.dispose();
    namecontroller.dispose();
    super.dispose();
  }

//
  @override
  void initState() {
    super.initState();

    _nameFocus.addListener(() {
      setState(() {
        isFocused = _nameFocus.hasFocus;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nameFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MENCEGAH KEYBOARD MENGGESER / MENDORONG LAYOUT DI ANDROID
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xff040C23),
      body: SafeArea(
        child: SingleChildScrollView(
          // Memastikan scroll tidak memantul acak yang bikin posisi bergeser
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 65, left: 25, right: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Assalamu’alaikum',
                      style: GoogleFonts.poppins(
                        color: const Color(0xffFFFFFF),
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset(
                      'assets/moon.png',
                      width: 26,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Selamat datang di Quran App',
                  style: GoogleFonts.poppins(
                    color: const Color(0xffA19CC5),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 80),
                Text(
                  'Belajar Al-Qur’an jadi lebih mudah dan menyenangkan!',
                  style: GoogleFonts.poppins(
                    color: const Color(0xffA19CC5),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 13),
                Form(
                  key: _formkey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    autofocus: true,
                    validator: UsernameValidator.validate,
                    controller: namecontroller,
                    textCapitalization: TextCapitalization.words,
                    focusNode: _nameFocus,
                    onTap: () {
                      setState(() {
                        isFocused = true;
                      });
                    },
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffFFFFFF),
                    ),
                    decoration: InputDecoration(
                        hintText: isFocused ? "" : "Masukan Username",
                        prefixText: isFocused ? "Nama : " : null,
                        fillColor: const Color(0xff040C23),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 14),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: const BorderSide(
                                color: Color(0xff672CBC), width: 2.5)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: const BorderSide(
                                color: Color(0xff672CBC), width: 2.5)),
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xffFFFFFF),
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
                const SizedBox(height: 55),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 450,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xff672CBC),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 5),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/splash.png',
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: -23,
                      right: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MainNavigation(
                                  username: namecontroller.text.trim(),
                                ),
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xffF9B091),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Mulai Belajar',
                              style: GoogleFonts.poppins(
                                color: const Color(0xff091945),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
