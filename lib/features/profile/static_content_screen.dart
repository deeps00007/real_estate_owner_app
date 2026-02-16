import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ContentSection {
  final String title;
  final String body;

  const ContentSection({required this.title, required this.body});
}

class StaticContentScreen extends StatelessWidget {
  final String title;
  final List<ContentSection> sections;
  final String? lastUpdated;

  const StaticContentScreen({
    super.key,
    required this.title,
    required this.sections,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                // Header info (Last updated)
                if (index == 0 && lastUpdated != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      'Last Updated: $lastUpdated',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.1),
                  );
                }

                final sectionIndex = lastUpdated != null ? index - 1 : index;
                final section = sections[sectionIndex];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child:
                      Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (section.title.isNotEmpty) ...[
                                Text(
                                  section.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Text(
                                section.body,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          )
                          .animate(delay: (100 * index).ms)
                          .fadeIn()
                          .slideY(begin: 0.1, curve: Curves.easeOutQuad),
                );
              }, childCount: sections.length + (lastUpdated != null ? 1 : 0)),
            ),
          ),
        ],
      ),
    );
  }
}
