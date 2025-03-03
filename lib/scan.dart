import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'db.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  QRScannerPageState createState() => QRScannerPageState();
}

class QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController? controller;
  String? qrCodeResult;
  bool fetch = false;
  late BuildContext bc;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void parseOTPAuth(String url) async {
    var uri = Uri.parse(url);
    var parameters = uri.queryParameters;
    var app = parameters['app'] ?? '未命名';
    var secret = parameters['secret'];
    var issuer = parameters['issuer'] ?? '未命名';
    var db = await getDb();
    await db.insert('MyAuth', {
      'account': app,
      'secretKey': secret,
      'issuer': issuer,
    });
    await db.close();
    close();
  }

  void close(){
    Navigator.pop(context);
  }

  void error(String value) async{
    controller?.stop();
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return TDConfirmDialog(
          content: value,
          action: (){
            Navigator.pop(context);
            Navigator.pop(bc);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bc = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("扫一扫",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2151D1),
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller!,
              onDetect: (args) {
                Vibration.vibrate(duration: 100);
                if (!fetch){
                  fetch = true;
                  var value = args.barcodes[0].displayValue.toString();
                  if (!value.contains('otpauth://')){
                    error(value);
                  }else{
                    parseOTPAuth(value);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}