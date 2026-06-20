import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts flutterTts = FlutterTts();
void main() {
  runApp(const KuranAnlaApp());
}

class KuranAnlaApp extends StatelessWidget {
  const KuranAnlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KuranAnla',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const WordScreen(),
    );
  }
}

class WordScreen extends StatefulWidget {
  const WordScreen({super.key});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  List words = [];
  int currentIndex = 0;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    final String jsonString = await rootBundle.loadString(
      'assets/words/level1.json',
    );

    final data = json.decode(jsonString);

    setState(() {
      words = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final word = words[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("KuranAnla"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: (currentIndex + 1) / words.length,
              minHeight: 12,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(height: 10),

            Text(
              "${currentIndex + 1} / ${words.length}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 40),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Icon(Icons.volume_up, size: 40, color: Colors.green),

                    const SizedBox(height: 20),

                    Text(
                      word["arabic"],
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      word["turkish"],
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      word["example"],
                      style: const TextStyle(fontSize: 24),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (currentIndex < words.length - 1) {
                    setState(() {
                      currentIndex++;
                    });
                  }
                },
                child: const Text("Anladım", style: TextStyle(fontSize: 20)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
