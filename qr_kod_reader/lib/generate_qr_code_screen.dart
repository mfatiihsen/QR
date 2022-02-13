import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_kod_reader/constants.dart';
import 'package:qr_kod_reader/services/advert_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;
import 'package:gallery_saver/gallery_saver.dart';

class GeneraCodeScreen extends StatefulWidget {
  GeneraCodeScreen({Key? key}) : super(key: key);

  @override
  _GeneraCodeScreen createState() => _GeneraCodeScreen();
}

class _GeneraCodeScreen extends State<GeneraCodeScreen> {
  TextEditingController _editingController = TextEditingController();
  String? qr;
  ScreenshotController _screenshotController = ScreenshotController();
  BannerAd? _ad;
  bool? isLoading;
  GlobalKey globalKey = GlobalKey();
  String albumName = 'Media';

  get http => null;

  // reklam eklemek için yazılan kod bloğu
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: AdvertService.bannerAdUnitIdGenerate,
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

  // reklamları kontrol etmek için yazılan kod bloğu
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
      return Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Container(
            child: Column(
              children: [
                Text(
                  "QR Kod Okuyucu",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "MFS software",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                // qr kod oluşturmak için girilen URL textfield kod bloğu
                TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Url girin",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: kPrimaryColor,
                        width: 2,
                      ),
                      gapPadding: 00,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: kPrimaryColor,
                        width: 2,
                      ),
                      gapPadding: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: kPrimaryColor,
                        width: 2,
                      ),
                      gapPadding: 0,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.8),
                    ),
                    suffixIcon: Icon(Icons.qr_code, color: kPrimaryColor),
                  ),
                  controller: _editingController,
                ),
                SizedBox(height: 20),
                SizedBox(height: 40),
                Screenshot(
                  controller: _screenshotController,
                  child: RepaintBoundary(
                    key: globalKey,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border(
                          top: BorderSide(width: 5, color: kPrimaryColor),
                          bottom: BorderSide(width: 5, color: kPrimaryColor),
                          left: BorderSide(width: 5, color: kPrimaryColor),
                          right: BorderSide(width: 5, color: kPrimaryColor),
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: QrImage(
                        backgroundColor: Colors.white,
                        data: '$qr',
                        version: QrVersions.auto,
                        size: 250,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        qr = _editingController.text;
                      });
                    },
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    child: Text(
                      "QR Kodu oluştur",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    onPressed: () {
                      _takeScreenshot();
                    },
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    child: Text(
                      "Paylaş",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // indir butonunun tasarlanması için yazılan kod bloğu
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    onPressed: () {
                      createQrPicture();
                    },
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    child: Text(
                      "İndir",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 70),
                checkForAd(), // reklam gösterimi
              ],
            ),
          ),
        ),
      ),
    );
  }

  // qr kodu gaeleriye kaydetmek için yazılan kod bloğu
  Future<void> createQrPicture() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    // ignore: unnecessary_cast
    ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png)
        as FutureOr<ByteData?>);
    if (byteData != null) {
      final result =
          await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      print(result);
      //_toastInfo(result.toString());
    }
  }

  // qr kod'un ekran görüntüsü alınıp paylaşılması için yazılan kod bloğu
  _takeScreenshot() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    print(pngBytes);
    File imgFile = new File('$directory/qr_code.png');
    imgFile.writeAsBytes(pngBytes);
    Share.shareFiles([imgFile.path], text: 'QR Kodum');
  }

  // kod kalabalığı yapmasınn kullanılmıyor.
  // _toastInfo(String info) {
  //   Fluttertoast.showToast(
  //       msg: "Galeriye Kaydedildi", toastLength: Toast.LENGTH_LONG);
  // }
}
