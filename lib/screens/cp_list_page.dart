import 'package:flutter/material.dart';
import '../curriculum_data.dart';
import 'chapter_detail_page.dart';

class CPListPage extends StatelessWidget {
  const CPListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capaian Pembelajaran"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 20),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Kembali',
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.home_rounded, color: Color(0xFF0F172A), size: 20),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                tooltip: 'Halaman Utama',
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: curriculumData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final cp = curriculumData[index];
              return _buildCPCard(context, cp, index + 1);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCPCard(BuildContext context, CPModule cp, int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "CP $index",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    cp.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(cp.description, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Subchapters List
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cp.subChapters.map((sub) {
                return ActionChip(
                  label: Text(sub.title),
                  avatar: const Icon(Icons.play_circle_outline, size: 16),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterDetailPage(
                          cpFolder: cp.folderName,
                          subChapter: sub,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
