import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_kod_reader/constants.dart';
import 'package:qr_kod_reader/generate_qr_code_screen.dart';
import 'package:qr_kod_reader/services/advert_service.dart';

import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: kPrimaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String scannerQrCode = '';
  String? link;
  String? message;
  BannerAd? _ad;
  bool? isLoading;
  late Permission permission;
  PermissionStatus permissionStatus = PermissionStatus.denied;

  void _listenForPermission() async {
    final status = await Permission.storage.status;
    setState(() {
      permissionStatus = status;
    });
    switch (status) {
      case PermissionStatus.denied:
        requestForPermission();
        break;

      case PermissionStatus.granted:
        break;

      case PermissionStatus.limited:
        Navigator.pop(context);
        break;

      case PermissionStatus.restricted:
        Navigator.pop(context);
        break;
      case PermissionStatus.permanentlyDenied:
        Navigator.pop(context);
        break;
    }
  }

  Future<void> requestForPermission() async {
    final status = await Permission.storage.request();
    setState(() {
      permissionStatus = status;
    });
  }

  @override
  void initState() {
    super.initState();
    _listenForPermission();
    // reklam gösterimi kodları
    _ad = BannerAd(
      adUnitId: AdvertService.bannerAdUnitIdMain,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            isLoading = true;
          });
        },
        onAdFailedToLoad: (_, error) {
          print('Ad Failed to Load with Error  $error');
        },
      ),
    );

    _ad!.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  // reklam gösterimi
  Widget checkForAd() {
    if (isLoading == true) {
      return Container(
        child: AdWidget(
          ad: _ad!,
        ),
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.width.toDouble(),
        alignment: Alignment.bottomCenter,
      );
    } else {
      return Container(
        padding: EdgeInsets.only(
          top: 40,
        ),
        child: Text(""),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // appbar kısmı ve üstteki yazılar
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Container(
            child: Column(
              children: [
                Text(
                  "QR Kod Okuyucu ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "MFS sofware",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  height: 350,
                  width: 350,
                  // ana sayfadaki resmin gösterimi için yazılan kod bloğu
                  child: Image.asset(
                    "assets/images/qr.jpg",
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "QR Kod Oluşturma ve QR Kod okutma \nişlemini aşağıdan yapabilirsiniz.",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 80),
                //  qr kod butonunu oluşturmak için yazılan kod bloğu
                Container(
                  width: double.infinity,
                  height: 50,
                  // ignore: deprecated_member_use
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    onPressed: () {
                      print("Oluştur butonuna tıklandı");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => GeneraCodeScreen(),
                        ),
                      );
                    },
                    color: Colors.white,
                    child: Text(
                      "QR Kod Oluştur",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                // qr kod okumak için yazılan butonunun kod bloğu
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    onPressed: () {
                      print("Okuyucuya tıklandı");
                      scanQR();
                    },
                    color: Colors.white,
                    child: Text(
                      "QR Kod Okuyucu",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                checkForAd(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // qr kodu okumak için yazılan kod bloğu
  // qr kodu okuttuktan sonra ekrana url ile çıkar alert dialogun da yazıdlığı kod bloğu
  Future<void> scanQR() async {
    try {
      scannerQrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Çıkış',
        true,
        ScanMode.QR,
      );
      print(scannerQrCode);

      showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Icon(
              Icons.check_circle_outline,
              color: kPrimaryColor,
              size: 50,
            ),
            actions: [
              Column(
                children: [
                  Center(
                    child: Text(
                      scannerQrCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    // ignore: deprecated_member_use
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 40,
                          // ignore: deprecated_member_use
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: kPrimaryColor,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: Text(
                                  "Kapat",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 40,
                          // ignore: deprecated_member_use
                          child: RaisedButton(
                            onPressed: () {
                              openUrl();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: kPrimaryColor,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: Text(
                                  "Git",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    } on PlatformException {}
  }

  // qr kod ile taratılan 'bağlantıya'
  // gitmek için yazıla  kod bloğu
  Future openUrl() async {
    String url = scannerQrCode;
    await launch(url);
  }
}
