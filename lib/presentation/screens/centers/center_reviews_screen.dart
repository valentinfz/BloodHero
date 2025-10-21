import 'package:flutter/material.dart';

class CenterReviewsScreen extends StatelessWidget {
  static const String name = 'center_reviews_screen';
  final String? centerName;

  const CenterReviewsScreen({super.key, this.centerName});

  @override
  Widget build(BuildContext context) {
    final title = centerName ?? 'Reseñas del centro';
    final reviews = const [
      _Review(
        author: 'María López',
        rating: 5,
        comment: 'Excelente atención y muy profesionales.',
      ),
      _Review(
        author: 'Carlos Díaz',
        rating: 4,
        comment: 'Todo muy bien, sólo demoraron un poco en recibirnos.',
      ),
      _Review(
        author: 'Lucía Pérez',
        rating: 5,
        comment: 'Instalaciones impecables y personal amable.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: Text(review.author[0]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(review.comment),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: reviews.length,
      ),
    );
  }
}

class _Review {
  final String author;
  final int rating;
  final String comment;

  const _Review({
    required this.author,
    required this.rating,
    required this.comment,
  });
}
