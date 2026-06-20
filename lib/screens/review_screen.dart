import 'package:flutter/material.dart';
import '../services/services.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late QuranService _quranService;

  @override
  void initState() {
    super.initState();
    _quranService = QuranService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gözden Geçir'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _quranService.getReviewDueWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviewDue = snapshot.data ?? [];

          if (reviewDue.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tüm kelimeleri gözden geçirdin! 🎉',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Daha sonra tekrar gelmesini bekle',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: reviewDue.length,
              itemBuilder: (context, index) {
                final learned = reviewDue[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade100,
                      ),
                      child: Center(
                        child: Text(
                          '${learned.level}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    title: Text('Kelime ID: ${learned.wordId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Doğruluk: ${learned.accuracy.toStringAsFixed(1)}%'),
                        Text('Deneme: ${learned.totalAttempts}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Başarıyla gözden geçirildi!')),
                        );
                      },
                      child: const Text('Tekrar Et'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
