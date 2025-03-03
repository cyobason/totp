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

}