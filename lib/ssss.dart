import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translated_app/clippath.dart';
import 'package:translated_app/clippathleft.dart';
import 'package:translator/translator.dart';

import 'clippath.dart';

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
      onTap: () => print('flutter'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'voice': HighlightedWord(
      onTap: () => print('voice'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    'subscribe': HighlightedWord(
      onTap: () => print('subscribe'),
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    'like': HighlightedWord(
      onTap: () => print('like'),
      textStyle: const TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'comment': HighlightedWord(
      onTap: () => print('comment'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  late stt.SpeechToText _speech;
  bool _isListening = false;
  var _text = "";
  var _trans;
  double _confidence = 1.0;
  String from = "en";
  String to = "ar";
  String titlefrom = "English";
  String titleto = "Arabic";
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    translator = GoogleTranslator();
  }

  GoogleTranslator translator = GoogleTranslator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
        actions: [
          InkWell(
            onTap: () {
              setState(() {
                titlefrom == "English"
                    ? titlefrom = "Arabic"
                    : titlefrom = "English";
                titleto == "Arabic" ? titleto = "English" : titleto = "Arabic";

                titlefrom == "English" ? from = "en" : from = "ar";
                titleto == "Arabic" ? to = "ar" : to = "en";
              });
            },
            child: const Icon(
              Icons.compare_arrows_sharp,
              size: 30,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          InkWell(
            onTap: () {
              setState(() {
                _trans = null;
              });
            },
            child: const Icon(
              Icons.refresh,
              size: 30,
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ClipPath(
              clipper: TsClip1(),
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 100,
                decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(50, 50),
                      topLeft: Radius.elliptical(50, 50),
                    )),
                child: Text(
                  titlefrom,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            AvatarGlow(
              animate: _isListening,
              glowColor: Theme.of(context).primaryColor,
              endRadius: 75.0,
              duration: const Duration(milliseconds: 2000),
              repeatPauseDuration: const Duration(milliseconds: 100),
              repeat: true,
              child: FloatingActionButton(
                onPressed: _listen,
                child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              ),
            ),
            ClipPath(
              clipper: DiscussionRightClip(),
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 100,
                decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.elliptical(50, 50),
                      topRight: Radius.elliptical(50, 50),
                    )),
                child: Text(
                  titleto,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
            child: TextHighlight(
              text: _trans == null ? 'buttom to spacke' : _trans.toString(),
              locale: Locale(to),
              words: _highlights,
              textStyle: const TextStyle(
                fontSize: 32.0,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // TextHighlight(
          //   text: _text,
          //   locale: Locale(to),
          //   words: _highlights,
          //   textStyle: const TextStyle(
          //     fontSize: 32.0,
          //     color: Colors.black,
          //     fontWeight: FontWeight.w400,
          //   ),
          // ),
        ]),
      ),
    );
  }

  void trans() {
    translator.translate(_text, from: from, to: to).then((value) {
      setState(() {
        _trans = value.toString();
      });
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          localeId: from,
          onResult: (val) => setState(() {
            trans();
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
