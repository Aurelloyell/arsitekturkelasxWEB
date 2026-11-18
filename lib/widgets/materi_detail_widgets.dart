import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/audio_effects_service.dart';

/// App bar shared by the CP detail pages: back/home controls, module number
/// and title, plus an optional tab strip.
class MateriDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String number;
  final String title;
  final TabController? controller;
  final List<Widget> tabs;

  const MateriDetailAppBar({
    super.key,
    required this.number,
    required this.title,
    this.controller,
    this.tabs = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF0F172A), size: 20),
            onPressed: () {
              AudioEffectsService.playClick();
              Navigator.pop(context);
            },
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
              icon: const Icon(Icons.home_rounded,
                  color: Color(0xFF0F172A), size: 20),
              onPressed: () {
                AudioEffectsService.playClick();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              tooltip: 'Halaman Utama',
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0284C7),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      bottom: tabs.isEmpty
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(49),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: TabBar(
                  controller: controller,
                  labelColor: const Color(0xFF0284C7),
                  unselectedLabelColor: const Color(0xFF64748B),
                  indicatorColor: const Color(0xFF0284C7),
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13),
                  tabs: tabs,
                ),
              ),
            ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (tabs.isEmpty ? 0 : 49));
}

/// Self-contained, persistent checklist used by every CP detail page.
class MateriChecklistSection extends StatefulWidget {
  final String storageKey;
  final String title;
  final String description;
  final List<String> items;

  const MateriChecklistSection({
    super.key,
    required this.storageKey,
    required this.title,
    required this.description,
    required this.items,
  });

  @override
  State<MateriChecklistSection> createState() => _MateriChecklistSectionState();
}

class _MateriChecklistSectionState extends State<MateriChecklistSection> {
  final Map<int, bool> _checked = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = <int, bool>{};
    for (int i = 0; i < widget.items.length; i++) {
      loaded[i] = prefs.getBool('${widget.storageKey}_$i') ?? false;
    }
    if (mounted) setState(() => _checked.addAll(loaded));
  }

  Future<void> _toggle(int index) async {
    final bool next = !(_checked[index] ?? false);
    if (next) {
      AudioEffectsService.playSuccess();
    } else {
      AudioEffectsService.playClick();
    }
    setState(() => _checked[index] = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${widget.storageKey}_$index', next);
  }

  @override
  Widget build(BuildContext context) {
    final int completed = _checked.values.where((v) => v).length;
    final int total = widget.items.length;
    final bool allDone = completed == total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_outlined,
                  color: Color(0xFF0284C7)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: allDone
                      ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                      : const Color(0xFF0284C7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completed / $total Selesai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: allDone
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < widget.items.length; i++)
            _buildItem(i, widget.items[i]),
        ],
      ),
    );
  }

  Widget _buildItem(int index, String text) {
    final bool isChecked = _checked[index] ?? false;
    return InkWell(
      onTap: () => _toggle(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isChecked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 22,
              color: isChecked
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isChecked
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF334155),
                  fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Image card that loads from the bundled asset bundle only. The error state
/// stays visible so a missing asset is obvious instead of silently collapsing.
class TechnicalImageCard extends StatelessWidget {
  final String imagePath;
  final String caption;
  final double maxHeight;
  final String? title;
  final String? subtitle;
  final String? description;

  const TechnicalImageCard({
    super.key,
    required this.imagePath,
    required this.caption,
    this.maxHeight = 380,
    this.title,
    this.subtitle,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null || description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        height: 1.4,
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (title != null || subtitle != null || description != null)
            const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: maxHeight),
            color: Colors.white,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: const Color(0xFFF1F5F9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image_outlined,
                          size: 40, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Gambar tidak tersedia: $imagePath',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              caption,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
