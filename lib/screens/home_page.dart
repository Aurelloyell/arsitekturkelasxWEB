import 'package:flutter/material.dart';
import '../services/audio_effects_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMuted = AudioEffectsService.isMuted;

  void _toggleMute() {
    setState(() {
      _isMuted = AudioEffectsService.toggleMute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Navigation Bar with Audio toggle
              _buildTopNav(context, isDesktop, isTablet),

              // Grand Display Background Hero Showcase with smooth entry
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40.0 : (isTablet ? 24.0 : 16.0),
                      vertical: isDesktop ? 28.0 : 18.0,
                    ),
                    child: _buildHeroDisplayBackground(context, isDesktop, isTablet),
                  ),
                ),
              ),

              // Feature Highlights Row (BIM 3D, Standar Industri, Interactive Quiz)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40.0 : (isTablet ? 24.0 : 16.0),
                      vertical: 16.0,
                    ),
                    child: _buildFeaturesSection(context, isDesktop, isTablet),
                  ),
                ),
              ),

              const SizedBox(height: 36),
              // Footer note
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== TOP NAVIGATION =====================
  Widget _buildTopNav(BuildContext context, bool isDesktop, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40.0 : (isTablet ? 24.0 : 16.0),
              vertical: 14.0,
            ),
            child: Row(
              children: [
                // Brand logo + text
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.architecture_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "ARsitektur ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: "X",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0284C7),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      "Media Pembelajaran Interaktif",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Sound Effect Mute/Unmute Button with hover & click feedback
                Tooltip(
                  message: _isMuted ? "Aktifkan Suara" : "Matikan Suara",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _toggleMute,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isMuted ? const Color(0xFFF1F5F9) : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isMuted ? const Color(0xFFCBD5E1) : const Color(0xFFBAE6FD),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            size: 16,
                            color: _isMuted ? const Color(0xFF64748B) : const Color(0xFF0284C7),
                          ),
                          if (isDesktop) ...[
                            const SizedBox(width: 6),
                            Text(
                              _isMuted ? "Sound Off" : "Sound On",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _isMuted ? const Color(0xFF64748B) : const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDesktop ? "Fase F • Kurikulum Merdeka" : "Fase F DPIB",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== HERO DISPLAY BACKGROUND =====================
  Widget _buildHeroDisplayBackground(
      BuildContext context, bool isDesktop, bool isTablet) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 16 * (1.0 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.16),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Architectural Display Background Image
                Positioned.fill(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Cinematic Gradient scrim
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDesktop
                          ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: [0.0, 0.55, 0.85, 1.0],
                              colors: [
                                Color(0xF50B132B),
                                Color(0xEA0F172A),
                                Color(0x990F172A),
                                Color(0x550F172A),
                              ],
                            )
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.45, 1.0],
                              colors: [
                                Color(0xF50B132B),
                                Color(0xEE0F172A),
                                Color(0xD90F172A),
                              ],
                            ),
                    ),
                  ),
                ),

                // Smooth ambient static aura
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0284C7).withValues(alpha: 0.14),
                    ),
                  ),
                ),

                // Foreground Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 52.0 : (isTablet ? 36.0 : 22.0),
                    vertical: isDesktop ? 48.0 : (isTablet ? 38.0 : 28.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Status Pill
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.layers_rounded, size: 15, color: Color(0xFF38BDF8)),
                                SizedBox(width: 8),
                                Text(
                                  "SMK DPIB • DESAIN PEMODELAN INFORMASI BANGUNAN",
                                  style: TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isDesktop) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.view_in_ar_rounded, size: 14, color: Color(0xFF38BDF8)),
                                  SizedBox(width: 6),
                                  Text(
                                    "3D BIM Parametric Ready",
                                    style: TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Headline
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isDesktop ? 760 : double.infinity),
                        child: Text(
                          "Kuasai Desain & Pemodelan Bangunan Berbasis BIM",
                          style: TextStyle(
                            fontSize: isDesktop ? 44 : (isTablet ? 34 : 27),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.18,
                            letterSpacing: -0.8,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isDesktop ? 680 : double.infinity),
                        child: Text(
                          "Pelajari teknik pemodelan arsitektur 2D, visualisasi 3D parametrik, konstruksi jalan & jembatan, hingga pengujian pemahaman melalui kuis interaktif secara komprehensif.",
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14.5,
                            color: const Color(0xFFCBD5E1),
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),

                      // Action Buttons
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isDesktop ? 680 : double.infinity),
                        child: _buildActionButtons(context, isDesktop),
                      ),

                      const SizedBox(height: 34),
                      const Divider(color: Color(0x2BFFFFFF), height: 1),
                      const SizedBox(height: 20),

                      // Quick Highlights inside the Display Banner
                      _buildHeroQuickBadges(isDesktop, isTablet),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== CONSISTENT BUTTONS WITH SOUND & SMOOTH ANIMATION =====================
  Widget _buildActionButtons(BuildContext context, bool isDesktop) {
    const double buttonHeight = 52.0;

    final primaryBtn = _SmoothHeroButton(
      label: "Mulai Belajar",
      icon: Icons.menu_book_rounded,
      backgroundColor: const Color(0xFF0284C7),
      foregroundColor: Colors.white,
      borderColor: const Color(0xFF38BDF8),
      isPrimary: true,
      onTap: () {
        AudioEffectsService.playClick();
        Navigator.pushNamed(context, '/pembelajaran');
      },
    );

    final secondaryBtn = _SmoothHeroButton(
      label: "Materi Lanjutan",
      icon: Icons.explore_rounded,
      backgroundColor: const Color(0xFFE76F51),
      foregroundColor: Colors.white,
      borderColor: const Color(0xFFF4A261),
      isPrimary: false,
      onTap: () {
        AudioEffectsService.playClick();
        Navigator.pushNamed(context, '/cp_list');
      },
    );

    final quizBtn = _SmoothHeroButton(
      label: "Arena Kuis",
      icon: Icons.sports_esports_rounded,
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      foregroundColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.35),
      isPrimary: false,
      onTap: () {
        AudioEffectsService.playClick();
        Navigator.pushNamed(context, '/quiz');
      },
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: SizedBox(height: buttonHeight, child: primaryBtn)),
          const SizedBox(width: 14),
          Expanded(child: SizedBox(height: buttonHeight, child: secondaryBtn)),
          const SizedBox(width: 14),
          Expanded(child: SizedBox(height: buttonHeight, child: quizBtn)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: buttonHeight, child: primaryBtn),
          const SizedBox(height: 12),
          SizedBox(height: buttonHeight, child: secondaryBtn),
          const SizedBox(height: 12),
          SizedBox(height: buttonHeight, child: quizBtn),
        ],
      );
    }
  }

  // ===================== QUICK BADGES =====================
  Widget _buildHeroQuickBadges(bool isDesktop, bool isTablet) {
    final badges = [
      _BadgeInfo(Icons.domain_rounded, "CP 1 • Pemodelan Gedung BIM"),
      _BadgeInfo(Icons.alt_route_rounded, "CP 2 • Pemodelan Jalan & Jembatan"),
      _BadgeInfo(Icons.quiz_rounded, "Multiplayer JamHood Room"),
    ];

    if (isDesktop || isTablet) {
      return Wrap(
        spacing: 24,
        runSpacing: 12,
        children: badges.map((b) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(b.icon, size: 16, color: const Color(0xFF38BDF8)),
              const SizedBox(width: 8),
              Text(
                b.text,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: badges.map((b) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(b.icon, size: 15, color: const Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                Text(
                  b.text,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
  }

  // ===================== FEATURE HIGHLIGHTS =====================
  Widget _buildFeaturesSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    final features = [
      _FeatureData(
        icon: Icons.view_in_ar_rounded,
        title: "Model 3D Interaktif",
        desc:
            "Eksplorasi bangunan gedung dan infrastruktur jalan secara real-time langsung di browser web.",
        badgeColor: const Color(0xFF0284C7),
      ),
      _FeatureData(
        icon: Icons.assignment_turned_in_rounded,
        title: "Standar Industri & ATP",
        desc:
            "Materi kurikulum terstruktur sesuai capaian pembelajaran Fase F DPIB dengan cek mandiri.",
        badgeColor: const Color(0xFF10B981),
      ),
      _FeatureData(
        icon: Icons.sports_esports_rounded,
        title: "Arena Kuis JamHood",
        desc:
            "Latihan solo terarah atau tanding multiplayer bersama kelas melalui PIN room interaktif.",
        badgeColor: const Color(0xFF8B5CF6),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: features
            .asMap()
            .entries
            .map((entry) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _SmoothFeatureCard(
                      data: entry.value,
                    ),
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        children: features
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _SmoothFeatureCard(
                    data: entry.value,
                  ),
                ))
            .toList(),
      );
    }
  }

  // ===================== FOOTER =====================
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: const Center(
        child: Text(
          "ARsitektur X • Media Pembelajaran SMK DPIB (Desain Pemodelan dan Informasi Bangunan)",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ===================== SMOOTH HARDWARE-ACCELERATED HERO BUTTON =====================
class _SmoothHeroButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SmoothHeroButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_SmoothHeroButton> createState() => _SmoothHeroButtonState();
}

class _SmoothHeroButtonState extends State<_SmoothHeroButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0);

    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _isHovered = true);
          AudioEffectsService.playHover();
        },
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutQuad,
            child: Material(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              elevation: widget.isPrimary ? (_isHovered ? 4 : 2) : 0,
              shadowColor: widget.backgroundColor.withValues(alpha: 0.4),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(14),
                hoverColor: Colors.white.withValues(alpha: 0.12),
                splashColor: Colors.white.withValues(alpha: 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isHovered ? Colors.white : widget.borderColor,
                      width: _isHovered ? 1.8 : 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: widget.foregroundColor, size: 20),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            color: widget.foregroundColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== SMOOTH HARDWARE-ACCELERATED FEATURE CARD =====================
class _SmoothFeatureCard extends StatefulWidget {
  final _FeatureData data;

  const _SmoothFeatureCard({
    required this.data,
  });

  @override
  State<_SmoothFeatureCard> createState() => _SmoothFeatureCardState();
}

class _SmoothFeatureCardState extends State<_SmoothFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _isHovered = true);
          AudioEffectsService.playHover();
        },
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutQuad,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.data.badgeColor.withValues(alpha: 0.4)
                  : const Color(0xFFE2E8F0),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.data.badgeColor.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                scale: _isHovered ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 140),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.data.badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.data.icon, color: widget.data.badgeColor, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.data.desc,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeInfo {
  final IconData icon;
  final String text;
  _BadgeInfo(this.icon, this.text);
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String desc;
  final Color badgeColor;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.desc,
    required this.badgeColor,
  });
}
