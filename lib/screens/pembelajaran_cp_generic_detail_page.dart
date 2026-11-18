import 'package:flutter/material.dart';

import '../basic_curriculum_data.dart';
import '../widgets/materi_detail_widgets.dart';

/// Detail view for the CP modules that do not have bespoke 3D/gallery pages.
/// Content comes from the same basicCurriculumList as CP1 and CP2.
class PembelajaranCPGenericDetailPage extends StatelessWidget {
  final CPBasicItem item;

  const PembelajaranCPGenericDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 960;
    final lines = item.content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final String overview = lines.isNotEmpty ? lines.first : item.description;
    final List<String> subTopics = lines
        .skip(1)
        .where((line) => !line.toLowerCase().startsWith('submateri'))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: MateriDetailAppBar(
        number: item.number,
        title: item.title,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 48 : 20,
          vertical: 28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Ringkasan Capaian'),
                const SizedBox(height: 12),
                _buildTextCard(overview),
                const SizedBox(height: 24),
                _buildSectionTitle('Submateri'),
                const SizedBox(height: 12),
                ...subTopics.map((topic) => _buildTopicCard(topic)),
                const SizedBox(height: 24),
                MateriChecklistSection(
                  storageKey: 'checklist_${item.id}',
                  title: 'Uji Pemahaman ${item.number}',
                  description:
                      'Tandai setiap poin yang sudah dapat Anda jelaskan tanpa melihat catatan.',
                  items: _checklistItems(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.number,
              style: const TextStyle(
                color: Color(0xFF7DD3FC),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.subTitle,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildBadge(Icons.school_outlined, item.phase),
              _buildBadge(Icons.category_outlined, item.element),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7DD3FC)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildTextCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.7,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildTopicCard(String topic) {
    final String clean = topic.replaceFirst(RegExp(r'^\d+\.\s*'), '');
    final int colon = clean.indexOf(':');
    final String heading = colon > 0 ? clean.substring(0, colon) : clean;
    final String body = colon > 0 ? clean.substring(colon + 1).trim() : '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _checklistItems() {
    switch (item.id) {
      case 'cp3':
        return const [
          'Mampu menjelaskan prinsip desain arsitektur minimalis.',
          'Mampu mengidentifikasi ciri material arsitektur industrial.',
          'Mampu membedakan pendekatan minimalis dan industrial pada sebuah bangunan.',
        ];
      case 'cp4':
        return const [
          'Mampu menjelaskan orientasi bangunan dan ventilasi silang pada iklim tropis.',
          'Mampu menyebutkan prinsip desain hijau yang relevan untuk bangunan sekolah.',
          'Mampu mengaitkan naungan dan pengelolaan air dengan kenyamanan penghuni.',
        ];
      default:
        return const [
          'Mampu menjelaskan pengertian arsitektur vernakular.',
          'Mampu mengidentifikasi material lokal dan teknik konstruksi tradisional.',
          'Mampu menjelaskan nilai budaya yang terkandung dalam bentuk bangunan lokal.',
        ];
    }
  }
}
