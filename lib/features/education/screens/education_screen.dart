import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../data/education_data.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedCategory = 'Semua';

  List<String> get _categories => [
        'Semua',
        ...{for (final topic in EducationData.topics) topic.category},
      ];

  @override
  Widget build(BuildContext context) {
    final topics = EducationData.topics
        .where((t) => _selectedCategory == 'Semua' || t.category == _selectedCategory)
        .toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ScreenHeader(
                eyebrow: 'Edukasi &',
                title: 'Panduan Mitigasi',
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (var i = 0; i < _categories.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    PillChip(
                      label: _categories[i],
                      selected: _selectedCategory == _categories[i],
                      onTap: () => setState(() => _selectedCategory = _categories[i]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: topics.length,
                itemBuilder: (context, index) => _EducationCard(topic: topics[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final EducationTopic topic;

  const _EducationCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showTopicDetail(context, topic),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: p.bg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        topic.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: p.ink,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: p.mut),
                        const SizedBox(width: 4),
                        Caption(topic.readTimeMinutes),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  topic.title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: p.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  topic.summary,
                  style: TextStyle(fontSize: 14, height: 1.45, color: p.mut),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        topic.officialSource,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.4,
                          color: p.mut,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'BACA',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTopicDetail(BuildContext context, EducationTopic topic) {
    final p = context.palette;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: p.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: p.bg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          topic.category,
                          style: TextStyle(fontSize: 11, color: p.ink),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Caption('Waktu baca: ${topic.readTimeMinutes}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    topic.title,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_rounded, size: 16, color: p.ink),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sumber resmi: ${topic.officialSource}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: p.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Poin penting',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...topic.bulletPoints.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: p.amb,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              point,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: p.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: p.line),
                  const SizedBox(height: 16),
                  Text(
                    'Pedoman lengkap',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topic.fullContent,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: p.ink,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
