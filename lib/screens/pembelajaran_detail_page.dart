import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../basic_curriculum_data.dart';
import '../widgets/materi_detail_widgets.dart';

/// Resolves a bundled asset key into a URL that `<model-viewer>` can fetch.
///
/// Flutter web serves assets under an extra `assets/` segment, mirroring
/// `NetworkAssetBundle`. Mobile builds read the bare asset key instead.
String _resolveModelAssetSrc(String assetKey) {
  if (!kIsWeb) return assetKey;
  return Uri.base.resolve('assets/$assetKey').toString();
}

class PembelajaranDetailPage extends StatefulWidget {
  final CPBasicItem item;

  const PembelajaranDetailPage({super.key, required this.item});

  @override
  State<PembelajaranDetailPage> createState() => _PembelajaranDetailPageState();
}

class _PembelajaranDetailPageState extends State<PembelajaranDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeCategoryIndex =
      0; // 0: Semua, 1: Struktur, 2: Arsitektur, 3: Interior, 4: BIM

  // Checklist items
  final List<String> _checklistItems = [
    "Mampu membedakan elemen sub-structure (pondasi, sloof) dan super-structure (kolom, balok, pelat).",
    "Memahami hierarki dan keterkaitan antara gambar 2D (denah) dengan model 3D pada BIM.",
    "Mengetahui fungsi ventilasi silang (cross-ventilation) pada pemodelan eksterior fasad rumah.",
    "Mampu menjelaskan mengapa perubahan satu parameter di BIM dapat mengubah seluruh view.",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: MateriDetailAppBar(
        number: widget.item.number,
        title: widget.item.title,
        controller: _tabController,
        tabs: const [
          Tab(
            iconMargin: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined, size: 18),
                SizedBox(width: 8),
                Text("Materi Lengkap"),
              ],
            ),
          ),
          Tab(
            iconMargin: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.view_in_ar_rounded, size: 18),
                SizedBox(width: 8),
                Text("Model 3D Interaktif"),
              ],
            ),
          ),
          Tab(
            iconMargin: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library_outlined, size: 18),
                SizedBox(width: 8),
                Text("Galeri Gambar Teknis"),
              ],
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMateriTab(isDesktop),
          _build3DModelTab(isDesktop),
          _buildGaleriTab(isDesktop),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: MATERI LENGKAP & SISTEMATIS
  // -------------------------------------------------------------
  Widget _buildMateriTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBanner(),
              const SizedBox(height: 24),
              _buildCurriculumContext(),
              const SizedBox(height: 28),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 4)
                _buildBimOverviewSection(),
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 4)
                const SizedBox(height: 24),
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 1)
                _buildStrukturSection(),
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 1)
                const SizedBox(height: 24),
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 2)
                _buildArsitekturEksteriorSection(),
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 2)
                const SizedBox(height: 24),
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 3)
                _buildInteriorSection(),
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 3)
                const SizedBox(height: 24),
              _buildPerbandingan2Dvs3DBIM(),
              const SizedBox(height: 24),
              MateriChecklistSection(
                storageKey: 'checklist_${widget.item.id}',
                title: 'Uji Pemahaman Materi (Checklist Mandiri Siswa)',
                description:
                    'Pastikan Anda dapat mengidentifikasi hal-hal berikut sebelum melanjutkan ke modul pemodelan terapan (klik untuk menandai checklist):',
                items: _checklistItems,
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFF38BDF8).withOpacity(0.4)),
                ),
                child: const Text(
                  "ATP 1.1 • FASE F",
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "SMK DPIB",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Pemodelan 2D & 3D Bangunan Gedung Berbasis BIM",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Menguasai pemahaman gambar 2D & 3D elemen struktur, arsitektur, interior, dan eksterior gedung rumah sederhana dan bertingkat dengan integrasi teknologi Building Information Modelling.",
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.view_in_ar, size: 18),
                label: const Text("Buka Model 3D"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _tabController.animateTo(2),
                icon: const Icon(Icons.image_outlined, size: 18),
                label: const Text("Lihat Gambar Teknis"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF94A3B8),
                  side: const BorderSide(color: Color(0xFF334155)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumContext() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school_rounded, color: Color(0xFF0284C7), size: 20),
              SizedBox(width: 8),
              Text(
                "Referensi Kurikulum & Alur Tujuan Pembelajaran (ATP)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 650;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildMetaBadge(
                      "Elemen", "Desain Pemodelan Bangunan", isWide),
                  _buildMetaBadge("Fase / Program",
                      "Fase F • 1.4 DPIB (SMKN 3 Yogyakarta)", isWide),
                  _buildMetaBadge(
                      "Alur Tahap", "Tahap 1 • Indikator 1.1", isWide),
                  _buildMetaBadge(
                      "Lingkup Kasus", "Rumah Sederhana & Bertingkat", isWide),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetaBadge(String label, String value, bool isWide) {
    return Container(
      width: isWide ? 230 : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      "Semua Materi",
      "Struktur Bangunan",
      "Arsitektur & Eksterior",
      "Interior Ruang",
      "Teknologi BIM",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = _activeCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _activeCategoryIndex = index);
              },
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFCBD5E1),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  // --- SECTIONS ---

  Widget _buildBimOverviewSection() {
    return _buildCardWrapper(
      title: "Teknologi Building Information Modelling (BIM)",
      tag: "KONSEP FUNDAMENTAL",
      tagColor: const Color(0xFF0284C7),
      icon: Icons.layers_outlined,
      children: [
        const Text(
          "BIM bukanlah sekadar software menggambar atau program 3D modeling visual belaka. BIM adalah proses terpadu berbasis data informasi (Information Rich) di mana seluruh elemen gambar 2D (denah, potongan, tampak) dan model parametrik 3D saling tersinkronisasi otomatis.",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline,
                  color: Color(0xFF16A34A), size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Prinsip Singkronisasi BIM: Ketika Anda mengubah ukuran kolom atau ketebalan dinding di view denah 2D, model 3D dan elevasi potongan akan ter-update seketika secara otomatis tanpa perlu menggambar ulang.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Tiga Pilar Informasi Elemen BIM:",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        _buildBulletPoint("Geometrik (3D Parametrik)",
            "Panjang, lebar, tebal, elevasi peletakan, dan volume fisik elemen."),
        _buildBulletPoint("Material & Mekanikal",
            "Mutu beton (misal: f'c 20 MPa), tulangan baja, nilai isolasi panas, dan tekstur render."),
        _buildBulletPoint("Spesifikasi & Identifikasi",
            "Produsen, kode klasifikasi omniclass/uniclass, biaya perkiraan, dan fase konstruksi."),
      ],
    );
  }

  Widget _buildStrukturSection() {
    return _buildCardWrapper(
      title: "Struktur: Kerangka & Tulang Bangunan",
      tag: "SUB-SISTEM 1",
      tagColor: const Color(0xFFD97706),
      icon: Icons.foundation_rounded,
      children: [
        const Text(
          "Struktur adalah komponen utama yang menahan seluruh beban (beban mati, beban hidup, beban angin, dan gempa) lalu meneruskannya secara aman ke tanah keras. Dalam memodelkan rumah sederhana maupun bertingkat, struktur dibagi menjadi dua bagian hierarki:",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildStructureBox("Sub-Structure (Bawah)", [
                        "Pondasi Dangkal: Batu kali untuk rumah 1 lantai sederhana.",
                        "Pondasi Telapak / Footplate: Beton bertulang untuk rumah bertingkat.",
                        "Sloof: Balok pengikat pondasi untuk meratakan beban dinding.",
                      ])),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildStructureBox("Super-Structure (Atas)", [
                        "Kolom Utama & Praktis: Menahan gaya tekan aksial vertikal.",
                        "Balok & Ringbalk: Mengikat kolom dan menumpu pelat lantai.",
                        "Pelat Lantai (Slab): Lantai beton rumah bertingkat.",
                        "Rangka Kuda-kuda: Penopang beban atap (baja ringan/kayu).",
                      ])),
                    ],
                  )
                : Column(
                    children: [
                      _buildStructureBox("Sub-Structure (Bawah)", [
                        "Pondasi Dangkal: Batu kali untuk rumah 1 lantai sederhana.",
                        "Pondasi Telapak / Footplate: Beton bertulang untuk rumah bertingkat.",
                        "Sloof: Balok pengikat pondasi untuk meratakan beban dinding.",
                      ]),
                      const SizedBox(height: 12),
                      _buildStructureBox("Super-Structure (Atas)", [
                        "Kolom Utama & Praktis: Menahan gaya tekan aksial vertikal.",
                        "Balok & Ringbalk: Mengikat kolom dan menumpu pelat lantai.",
                        "Pelat Lantai (Slab): Lantai beton rumah bertingkat.",
                        "Rangka Kuda-kuda: Penopang beban atap (baja ringan/kayu).",
                      ]),
                    ],
                  );
          },
        ),
      ],
    );
  }

  Widget _buildStructureBox(String title, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706))),
                    Expanded(
                      child: Text(
                        p,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildArsitekturEksteriorSection() {
    return _buildCardWrapper(
      title: "Arsitektur & Eksterior: Fasad, Dinding & Selubung Gedung",
      tag: "SUB-SISTEM 2",
      tagColor: const Color(0xFF059669),
      icon: Icons.cottage_outlined,
      children: [
        const Text(
          "Arsitektur dan eksterior mendefinisikan estetika, fungsi ruang, serta kenyamanan termal dan perlindungan terhadap cuaca luar. Pada rumah sederhana dan bertingkat, pemodelan mencakup:",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 14),
        _buildBulletPoint("Dinding Eksterior & Partisi",
            "Bata merah, hebel (AAC), atau panel precast dengan plester dan acian yang terdefinisi ketebalannya pada BIM."),
        _buildBulletPoint("Fasad & Bukaan (Kusen Pintu/Jendela)",
            "Menentukan tata letak orientasi bukaan terhadap arah matahari (cross ventilation & natural lighting)."),
        _buildBulletPoint("Bentuk Atap Bangunan",
            "Pemodelan geometri atap (pelana, perisai/limasan, datar dak beton) lengkap dengan kemiringan (pitch) dan sistem talang."),
        _buildBulletPoint("Finishing Eksterior",
            "Pemilihan material cat tahan cuaca, batu alam tempel, kisi-kisi penangkal panas (secondary skin), dan kanopi teras."),
      ],
    );
  }

  Widget _buildInteriorSection() {
    return _buildCardWrapper(
      title: "Interior: Tata Ruang, Ergonomi & Kenyamanan",
      tag: "SUB-SISTEM 3",
      tagColor: const Color(0xFF7C3AED),
      icon: Icons.chair_outlined,
      children: [
        const Text(
          "Interior adalah 'nyawa' di dalam rumah. Pemodelan 3D pada BIM memungkinkan desainer dan klien menguji kelayakan tata letak furniture, ketinggian plafon (ceiling height), dan sirkulasi penghuni sebelum fisik gedung dibangun.",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 14),
        _buildBulletPoint("Zonasi & Sirkulasi",
            "Pemisahan zona publik (ruang tamu), semi-privat (ruang keluarga, ruang makan), privat (kamar tidur), dan servis (dapur, KM/WC)."),
        _buildBulletPoint("Ketinggian Plafon & Drop Ceiling",
            "Mempengaruhi kesan lapang ruang dan peletakan titik lampu (lighting plan)."),
        _buildBulletPoint("Pemodelan Tangga (Rumah Bertingkat)",
            "Perhitungan ergonomi aantrede (lebar pijakan 28-30 cm) dan optrede (tinggi tanjakan 16-18 cm) yang aman dan nyaman."),
      ],
    );
  }

  Widget _buildPerbandingan2Dvs3DBIM() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Perbedaan CAD Tradisional vs Pemodelan BIM",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Mengapa kurikulum SMK DPIB Fase F beralih mewajibkan teknologi BIM:",
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),
          Table(
            border: TableBorder.all(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8)),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                children: [
                  _buildTableCell("Aspek", isHeader: true),
                  _buildTableCell("CAD Tradisional (2D Garis)", isHeader: true),
                  _buildTableCell("BIM (Parametrik 2D & 3D)", isHeader: true),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell("Sifat Gambar"),
                  _buildTableCell(
                      "Kumpulan garis independen (line, polyline) tanpa arti fisik."),
                  _buildTableCell(
                      "Objek cerdas bermakna fisik (dinding, kolom, jendela)."),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell("Perubahan Desain"),
                  _buildTableCell(
                      "Manual edit di setiap denah, tampak, dan potongan terpisah."),
                  _buildTableCell(
                      "Otomatis sinkron ke seluruh lembar gambar dan 3D view."),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell("Deteksi Benturan"),
                  _buildTableCell(
                      "Sulit terdeteksi, rawan tabrakan struktur dan utilitas di proyek."),
                  _buildTableCell(
                      "Clash detection otomatis antara balok, pipa, dan arsitektur."),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
          color: isHeader ? const Color(0xFF0F172A) : const Color(0xFF334155),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required String tag,
    required Color tagColor,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: tagColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: tagColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String boldPart, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.arrow_right_rounded,
                size: 20, color: Color(0xFF0284C7)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 14, height: 1.6, color: Color(0xFF334155)),
                children: [
                  TextSpan(
                    text: "$boldPart: ",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: MODEL 3D INTERAKTIF
  // -------------------------------------------------------------
  Widget _build3DModelTab(bool isDesktop) {
    final String glbSrc = _resolveModelAssetSrc(
      "assets/glb/cp1/low_poly_house_3.glb",
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.view_in_ar,
                          color: Color(0xFF0284C7), size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Eksplorasi 3D Model: Rumah Hunian Sederhana",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Putar, perbesar (zoom), dan amati hubungan massa atap, dinding eksterior, jendela, dan pintu pada model 3D di bawah ini.",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3D Viewer Container
              Container(
                height: isDesktop ? 520 : 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    ModelViewer(
                      src: glbSrc,
                      alt: "3D Model Rumah Hunian Sederhana CP1",
                      ar: true,
                      arModes: const ['webxr', 'scene-viewer', 'quick-look'],
                      arScale: ArScale.auto,
                      arPlacement: ArPlacement.floor,
                      autoRotate: true,
                      cameraControls: true,
                      backgroundColor: Colors.transparent,
                    ),
                    // Floating Badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app_outlined,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Sentuh & Tarik untuk Memutar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Observation guide
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Panduan Observasi Siswa pada Model 3D:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildObservationItem(
                      "1. Selubung Atap (Roofing):",
                      "Amati sudut kemiringan atap pelana. Pada pemodelan BIM, sudut ini menentukan area talang dan tampias air hujan.",
                    ),
                    _buildObservationItem(
                      "2. Proporsi Bukaan Fasad:",
                      "Perhatikan posisi jendela dan pintu terhadap dinding. Model 3D memastikan tidak ada tabrakan antara kusen dengan kolom struktur.",
                    ),
                    _buildObservationItem(
                      "3. Transisi Eksterior & Teras:",
                      "Lihat elevasi lantai teras terhadap permukaan tanah luar (level offset).",
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

  Widget _buildObservationItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF0284C7)),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
                fontSize: 14, height: 1.5, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: GALERI GAMBAR TEKNIS
  // -------------------------------------------------------------
  Widget _buildGaleriTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.photo_library_outlined,
                        color: Color(0xFF0284C7), size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gambar Teknis & Proyeksi Aksonometri Bangunan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Referensi visual untuk memahami integrasi antara gambar kerja 2D/3D dengan visualisasi aksonometri potongan gedung.",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Image 1: Aksonometri Bangunan
              _buildImageCard(
                title:
                    "1. Gambar Aksonometri & Potongan Struktural-Arsitektural",
                subtitle:
                    "Visualisasi 3D exploded / aksonometri menunjukkan lapisan pondasi, balok, lantai bertingkat, dan tata interior secara komprehensif.",
                imagePath: "assets/gambar/cp1/02_AXONO_GENERAL.jpg",
                caption: "Sumber Dokumen Teknis: 02_AXONO_GENERAL.jpg",
                isDesktop: isDesktop,
              ),
              const SizedBox(height: 24),

              // Image 2: Apa itu CAD & BIM Software
              _buildImageCard(
                title: "2. Paradigma CAD Tradisional ke Pemodelan Cerdas BIM",
                subtitle:
                    "Evolusi alat bantu desain dari sekadar gambar garis 2D (Computer-Aided Drafting) menuju Building Information Modelling berbasis data parametrik.",
                imagePath: "assets/gambar/cp1/1-What is CAD software_.webp",
                caption: "Sumber Dokumen Teknis: 1-What is CAD software_.webp",
                isDesktop: isDesktop,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required String caption,
    required bool isDesktop,
  }) {
    return TechnicalImageCard(
      imagePath: imagePath,
      caption: caption,
      maxHeight: 550,
      title: title,
      subtitle: subtitle,
    );
  }
}
