import 'package:flutter/material.dart';
import 'package:auth_totp/auth_totp.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'dart:core';

class ShowCodePage extends StatefulWidget {
  final String secretKey;
  const ShowCodePage({super.key, required this.secretKey});

  @override
  ShowCodePageState createState() => ShowCodePageState();
}

class ShowCodePageState extends State<ShowCodePage> with TickerProviderStateMixin {

  String code = '';
  final int _duration = 30;
  final CountDownController _controller = CountDownController();
  int remainingSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(code, style: const TextStyle(fontSize: 24, letterSpacing: 1.0, color: Color(0xFF2151D1))),
        const SizedBox(width: 5),
        CircularCountDownTimer(
          duration: _duration,
          initialDuration: remainingSeconds,
          controller: _controller,
          width: 24,
          height: 24,
          ringColor: Colors.grey[300]!,
          ringGradient: null,
          fillColor: const Color(0xFF2151D1),
          fillGradient: null,
          backgroundColor: const Color(0xFF6A8CE8),
          backgroundGradient: null,
          strokeWidth: 5.0,
          strokeCap: StrokeCap.round,
          textStyle: const TextStyle(
            fontSize: 10.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textFormat: CountdownTextFormat.S,
          isReverse: true,
          isReverseAnimation: true,
          isTimerTextShown: true,
          autoStart: true,
          onComplete: () {
            _controller.restart();
            generateTOTPCode();
          },
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    generateTOTPCode();
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int leftSeconds = timestamp % _duration;
    setState(() {
      remainingSeconds = leftSeconds;
    });
  }

  void generateTOTPCode(){
    var codeValue = AuthTOTP.generateTOTPCode(
        secretKey: widget.secretKey,
        interval: 30
    );
    setState(() {
      code = codeValue;
    });
  }

  /*
  final int _duration = 30;
  final CountDownController _controller = CountDownController();
  int remainingSeconds = 0;
  bool showQr = false;
  String qrCodeUrl = '';
  late BuildContext bc;

  @override
  void initState() {
    super.initState();
    generateTOTPCode();
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int leftSeconds = timestamp % _duration;
    setState(() {
      remainingSeconds = leftSeconds;
    });
    getQRCodeUrl();
  }

  void getQRCodeUrl(){
    var account = widget.item['account'].toString();
    var appName = account.isNotEmpty ? account : '未命名';
    var secretKey = widget.item['secretKey'];
    var issuer = widget.item['issuer'];
    var data = 'otpauth://totp/$appName?secret=$secretKey&issuer=$issuer&app=$account';
    var urlValue= 'https://api.qrserver.com/v1/create-qr-code/?data=${Uri.encodeComponent(data)}';
    setState(() {
      qrCodeUrl = urlValue;
    });
  }

  void generateTOTPCode(){
    var codeValue = AuthTOTP.generateTOTPCode(
        secretKey: widget.item['secretKey'],
        interval: 30
    );
    setState(() {
      code = codeValue;
    });
  }

  void deleteTotp() async {
    var db = await getDb();
    await db.delete('MyAuth', where: 'id = ?', whereArgs: [widget.item['id']]);
    await db.close();
    close();
  }

  void close(){
    Navigator.pop(bc);
  }

  @override
  Widget build(BuildContext context) {
    bc = context;
    var account = widget.item['account'].toString();
    return Scaffold(
        appBar: AppBar(
          title: Text(account.isNotEmpty ? account : '未命名',
              style: const TextStyle(color: Colors.white)),
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
          actions: [
            widget.edit ? IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.white,
                onPressed: () async {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (BuildContext buildContext, Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return TDAlertDialog(
                        content: '删除后数据将不可恢复!',
                        rightBtnAction: () {
                          Navigator.pop(context);
                          deleteTotp();
                        },
                      );
                    },
                  );
                }
            ) : Container(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: (){
                  if (!widget.edit){
                    return;
                  }
                  setState(() {
                    showQr = !showQr;
                  });
                },
                child: Row(
                  children: [
                    Text(widget.item['issuer'], style: const TextStyle(fontSize: 20, color: Colors.grey)),
                    const SizedBox(width: 5),
                    widget.edit ? const Icon(Icons.qr_code, size: 18, color: Colors.grey) : Container(),
                  ],
                ),
              ),
              Center(
                child: CircularCountDownTimer(
                  duration: _duration,
                  initialDuration: remainingSeconds,
                  controller: _controller,
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 3,
                  ringColor: Colors.grey[300]!,
                  ringGradient: null,
                  fillColor: const Color(0xFF2151D1),
                  fillGradient: null,
                  backgroundColor: const Color(0xFF6A8CE8),
                  backgroundGradient: null,
                  strokeWidth: 20.0,
                  strokeCap: StrokeCap.round,
                  textStyle: const TextStyle(
                    fontSize: 33.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textFormat: CountdownTextFormat.S,
                  isReverse: true,
                  isReverseAnimation: true,
                  isTimerTextShown: true,
                  autoStart: true,
                  onComplete: () {
                    _controller.restart();
                    generateTOTPCode();
                  },
                ),
              ),
              Center(
                child: Text(code, style: const TextStyle(fontSize: 64, letterSpacing: 10.0, color: Color(0xFF2151D1))),
              ),
              widget.edit && showQr ? Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.network(
                        qrCodeUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],
              ) : Container()
            ],
          ),
        )
    );
  }*/
}