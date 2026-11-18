import 'package:flutter/material.dart';
import '../basic_curriculum_data.dart';
import '../widgets/materi_detail_widgets.dart';

class PembelajaranCP2DetailPage extends StatefulWidget {
  final CPBasicItem item;

  const PembelajaranCP2DetailPage({super.key, required this.item});

  @override
  State<PembelajaranCP2DetailPage> createState() =>
      _PembelajaranCP2DetailPageState();
}

class _PembelajaranCP2DetailPageState extends State<PembelajaranCP2DetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeCategoryIndex =
      0; // 0: Semua, 1: Klasifikasi & Ruang, 2: Geometrik Jalan, 3: Perkerasan Jalan, 4: Struktur Jembatan, 5: Pemodelan BIM

  // Checklist items khusus CP2
  final List<String> _checklistItems = [
    "Mampu membedakan hierarki ruang jalan: Ruang Manfaat Jalan (Rumaja), Ruang Milik Jalan (Rumija), dan Ruang Pengawasan Jalan (Ruwasja).",
    "Memahami 3 jenis alinyemen tikungan horisontal (Full Circle, Spiral-Circle-Spiral, Spiral-Spiral) dan kelandaian alinyemen vertikal.",
    "Menguasai susunan 4 lapis perkerasan lentur dari tanah dasar (subgrade), subbase, base course, hingga lapis aus permukaan aspal (wearing course).",
    "Mampu mengidentifikasi komponen struktur atas jembatan (girder, diafragma, pelat lantai kendaraan, kerb, tiang sandaran railing).",
    "Mampu menjelaskan fungsi struktur bawah jembatan (pangkal jembatan/abutment dengan dinding sayap, serta pilar/pier penopang tengah).",
    "Memahami fungsi bangunan pelengkap jembatan (jalan pendekat/oprit, plat injak approach slab, talud revetment, pipa drainase, dan patok penuntun).",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                Text("Materi Lengkap CP 2"),
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
                Text("Galeri Gambar Teknis & Tipikal"),
              ],
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMateriTab(isDesktop),
          _buildGaleriTab(isDesktop),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: MATERI LENGKAP JALAN & JEMBATAN
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

              // Bagian 1: Klasifikasi & Ruang Jalan
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 1) ...[
                _buildKlasifikasiJalanSection(),
                const SizedBox(height: 24),
                _buildRuangJalanSection(),
                const SizedBox(height: 24),
              ],

              // Bagian 2: Perencanaan Geometrik Jalan
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 2) ...[
                _buildGeometrikJalanSection(),
                const SizedBox(height: 24),
              ],

              // Bagian 3: Struktur Perkerasan Jalan
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 3) ...[
                _buildPerkerasanJalanSection(),
                const SizedBox(height: 24),
              ],

              // Bagian 4: Anatomi Struktur Jembatan Lengkap
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 4) ...[
                _buildStrukturJembatanSection(),
                const SizedBox(height: 24),
              ],

              // Bagian 5: Integrasi Pemodelan BIM Jalan & Jembatan
              if (_activeCategoryIndex == 0 || _activeCategoryIndex == 5) ...[
                _buildBimRoadBridgeSection(),
                const SizedBox(height: 24),
              ],

              // Checklist Uji Pemahaman Siswa CP2
              MateriChecklistSection(
                storageKey: 'checklist_${widget.item.id}',
                title: 'Uji Pemahaman Materi CP 2 (Checklist Mandiri Siswa)',
                description:
                    'Tandai setiap poin kompetensi konstruksi jalan & jembatan di bawah ini untuk menguji kesiapan pemodelan BIM Anda (klik untuk menandai checklist):',
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
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
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
                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                ),
                child: const Text(
                  "ATP 1.2 • TAHAP 2 • FASE F",
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
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "SMK DPIB (Teknik Konstruksi)",
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
            "Pemodelan Konstruksi Jalan dan Jembatan dengan BIM",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Pelajari kaidah teknis klasifikasi jalan, anatomi ruang jalan (Damaja, Damija, Dawasja), geometrik alinyemen horisontal & vertikal, lapisan perkerasan aspal lentur, serta konstruksi struktur atas dan bawah jembatan sesuai standar PU.",
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.image_outlined, size: 18),
            label: const Text("Lihat Galeri 38 Gambar Teknis"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF38BDF8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
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
                "Referensi Bahan Ajar & Kurikulum",
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
                      "Sumber Acuan",
                      "Bhn Ajar Menggambar Jalan & Jembatan (Weni Murfihenni, PPPPTK BMTI)",
                      isWide),
                  _buildMetaBadge("Elemen Keahlian",
                      "Desain Pemodelan Jalan & Jembatan (DPIB)", isWide),
                  _buildMetaBadge("Regulasi & Standar",
                      "Permen PU No. 19/2011 & PP No. 34/2006", isWide),
                  _buildMetaBadge(
                      "Target Kompetensi",
                      "Pemodelan Trase Jalan, Profil Melintang & Struktur Jembatan",
                      isWide),
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
      "Klasifikasi & Ruang Jalan",
      "Geometrik Jalan",
      "Perkerasan Jalan",
      "Struktur Jembatan",
      "Pemodelan BIM",
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

  // --- MATERI SECTIONS ---

  Widget _buildKlasifikasiJalanSection() {
    return _buildCardWrapper(
      title: "1. Klasifikasi Jalan Raya Berdasarkan Ketentuan Teknis",
      tag: "SISTEM TRANSPORTASI",
      tagColor: const Color(0xFF0284C7),
      icon: Icons.alt_route_rounded,
      children: [
        const Text(
          "Jalan adalah prasarana transportasi darat yang meliputi segala bagian jalan, termasuk bangunan pelengkap dan perlengkapannya yang diperuntukkan bagi lalu lintas. Menurut regulasi bina marga, jalan dikelompokkan menurut 4 klasifikasi utama:",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 16),
        _buildBulletPoint("A. Sistem Jaringan Jalan",
            "Jalan Primer (melayani distribusi nasional antar pusat simpul kegiatan) dan Jalan Sekunder (pelayanan distribusi barang/jasa dalam kawasan perkotaan)."),
        _buildBulletPoint("B. Fungsi Jalan",
            "Jalan Arteri (jarak jauh, kecepatan tinggi, akses dibatasi), Kolektor (jarak sedang, pengumpul/pembagi), Lokal (jarak dekat, kecepatan rendah), dan Lingkungan (pelayanan lingkungan setempat)."),
        _buildBulletPoint("C. Status Pengelolaan",
            "Jalan Nasional, Jalan Provinsi, Jalan Kabupaten, Jalan Kota, dan Jalan Desa."),
        _buildBulletPoint("D. Kelas & Muatan Sumbu Terberat (MST)",
            "Jalan Kelas Khusus (> 10 ton), Kelas I (maks 10 ton), Kelas II (maks 8 ton, panjang max 12m), dan Kelas III (maks 8 ton, panjang max 9m)."),
        const SizedBox(height: 14),
        _buildInlineImage(
          "assets/gambar/cp2/Jalan/Gambar 1 Sketsa Hierarki Jalan.png",
          "Gambar 1: Sketsa Hierarki dan Hubungan Jaringan Jalan Primer dan Sekunder",
        ),
      ],
    );
  }

  Widget _buildRuangJalanSection() {
    return _buildCardWrapper(
      title: "2. Bagian-Bagian dan Ruang Jalan (Damaja, Damija, Dawasja)",
      tag: "ANATOMI RUANG JALAN",
      tagColor: const Color(0xFF059669),
      icon: Icons.view_column_rounded,
      children: [
        const Text(
          "Dalam perencanaan teknik sipil dan BIM, ruang jalan dibagi menjadi tiga zona hukum dan teknis yang sangat ketat:",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoBox(
                          "Rumaja (Ruang Manfaat Jalan)",
                          const Color(0xFF0284C7),
                          [
                            "Meliputi badan jalan, bahu jalan, saluran tepi drainase, dan ambang pengaman.",
                            "Tinggi bebas vertikal min. 5 meter di atas permukaan jalan.",
                            "Kedalaman bawah min. 1,5 meter di bawah permukaan perkerasan.",
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildInfoBox(
                          "Rumija (Ruang Milik Jalan)",
                          const Color(0xFFD97706),
                          [
                            "Ruang milik negara yang dibatasi oleh patok batas Rumija.",
                            "Diperuntukkan untuk pelebaran jalur lalu lintas di masa depan.",
                            "Kebutuhan pengamanan konstruksi, RTH lansekap, dan penempatan utilitas kota.",
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildInfoBox(
                          "Ruwasja (Ruang Pengawasan)",
                          const Color(0xFF7C3AED),
                          [
                            "Ruang di luar Rumija untuk menjamin ruang pandang bebas pengemudi.",
                            "Batas dari tepi badan jalan: Arteri Primer min 15m, Kolektor min 10m, Lokal min 7m.",
                            "Pada jembatan: 100 meter ke arah hulu dan hilir sungai.",
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildInfoBox(
                        "Rumaja (Ruang Manfaat Jalan)",
                        const Color(0xFF0284C7),
                        [
                          "Meliputi badan jalan, bahu jalan, saluran tepi drainase, dan ambang pengaman.",
                          "Tinggi bebas vertikal min. 5 meter di atas permukaan jalan.",
                          "Kedalaman bawah min. 1,5 meter di bawah permukaan perkerasan.",
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoBox(
                        "Rumija (Ruang Milik Jalan)",
                        const Color(0xFFD97706),
                        [
                          "Ruang milik negara yang dibatasi oleh patok batas Rumija.",
                          "Diperuntukkan untuk pelebaran jalur lalu lintas di masa depan.",
                          "Kebutuhan pengamanan konstruksi, RTH lansekap, dan penempatan utilitas kota.",
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoBox(
                        "Ruwasja (Ruang Pengawasan)",
                        const Color(0xFF7C3AED),
                        [
                          "Ruang di luar Rumija untuk menjamin ruang pandang bebas pengemudi.",
                          "Batas dari tepi badan jalan: Arteri Primer min 15m, Kolektor min 10m, Lokal min 7m.",
                          "Pada jembatan: 100 meter ke arah hulu dan hilir sungai.",
                        ],
                      ),
                    ],
                  );
          },
        ),
        const SizedBox(height: 16),
        _buildInlineImage(
          "assets/gambar/cp2/Jalan/Gambar 3 Tipikal Damaja, Damija dan Dawasja.png",
          "Gambar 3 & 4: Tipikal Pembagian Ruang Damaja, Damija, dan Dawasja serta Potongan Melintang Jalan",
        ),
      ],
    );
  }

  Widget _buildGeometrikJalanSection() {
    return _buildCardWrapper(
      title: "3. Perencanaan Geometrik Jalan (Alinyemen Horisontal & Vertikal)",
      tag: "GEOMETRIK JALAN",
      tagColor: const Color(0xFFEA580C),
      icon: Icons.timeline_rounded,
      children: [
        const Text(
          "Kaidah geometrik berfokus pada keselamatan pengemudi saat bermanuver pada kecepatan rencana:",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 14),
        _buildBulletPoint("Alinyemen Horisontal (Trase Situasi)",
            "Proyeksi garis sumbu jalan pada bidang datar horisontal yang terdiri atas bagian lurus (tangen) dan bagian lengkung (tikungan)."),
        _buildBulletPoint("Tikungan Full Circle (FC)",
            "Tikungan busur lingkaran tunggal, diaplikasikan pada radius jari-jari (Rc) yang besar."),
        _buildBulletPoint("Tikungan Spiral - Circle - Spiral (SCS)",
            "Tikungan yang menghubungkan garis lurus dengan busur lingkaran melalui spiral peralihan untuk mengurangi sentakan gaya sentrifugal kendaraan secara bertahap."),
        _buildBulletPoint("Tikungan Spiral - Spiral (SS)",
            "Dua lengkung spiral saling bertemu tanpa busur lingkaran tengah untuk tikungan tajam."),
        _buildBulletPoint("Alinyemen Vertikal (Profil Memanjang)",
            "Elevasi sumbu jalan yang memperhitungkan kelandaian positif (tanjakan), kelandaian negatif (turunan), lengkung vertikal cembung, dan cekung untuk memastikan jarak pandang henti."),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;
            return isWide
                ? Row(
                    children: [
                      Expanded(
                        child: _buildInlineImage(
                          "assets/gambar/cp2/Jalan/Gambar 7 tikungan Full Circle (FC).jpeg",
                          "Tikungan Full Circle (FC)",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInlineImage(
                          "assets/gambar/cp2/Jalan/Gambar 8 tikungan Spiral - Circle Spiral.jpeg",
                          "Tikungan Spiral-Circle-Spiral (SCS)",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInlineImage(
                          "assets/gambar/cp2/Jalan/Gambar 10 Alinyemen Vertikal.jpeg",
                          "Alinyemen Vertikal (Profil Memanjang)",
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildInlineImage(
                        "assets/gambar/cp2/Jalan/Gambar 8 tikungan Spiral - Circle Spiral.jpeg",
                        "Tikungan Spiral-Circle-Spiral (SCS)",
                      ),
                      const SizedBox(height: 12),
                      _buildInlineImage(
                        "assets/gambar/cp2/Jalan/Gambar 10 Alinyemen Vertikal.jpeg",
                        "Alinyemen Vertikal (Profil Memanjang)",
                      ),
                    ],
                  );
          },
        ),
      ],
    );
  }

  Widget _buildPerkerasanJalanSection() {
    return _buildCardWrapper(
      title:
          "4. Struktur dan Lapisan Perkerasan Jalan Lentur (Flexible Pavement)",
      tag: "TEKNOLOGI PERKERASAN",
      tagColor: const Color(0xFFD97706),
      icon: Icons.layers_rounded,
      children: [
        const Text(
          "Perkerasan jalan berfungsi menerima beban gandar roda kendaraan dan menyebarkannya ke lapisan bawah hingga ke tanah dasar. Susunan perkerasan lentur dari bawah ke atas terdiri dari:",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 16),
        _buildBulletPoint("1. Tanah Dasar (Subgrade)",
            "Lapisan tanah asli atau urugan setebal 30 cm yang dipadatkan hingga 100% kepadatan kering maksimum (AASHTO T 99) dengan daya dukung CBR minimum 6%."),
        _buildBulletPoint("2. Lapis Pondasi Bawah (Subbase Course)",
            "Campuran agregat kelas B/S yang berfungsi menyebarkan beban roda ke tanah dasar, lapis peresapan air, dan pencegah naiknya partikel halus tanah."),
        _buildBulletPoint("3. Lapis Pondasi Atas (Base Course)",
            "Batu pecah agregat kelas A yang menahan gaya lintang utama dan bantalan langsung di bawah aspal."),
        _buildBulletPoint("4. Lapis Permukaan Aspal (Surface Course)",
            "Terdiri atas Asphalt Concrete - Binder Course (AC-BC tebal 6 cm) dan Asphalt Concrete - Wearing Course (AC-WC tebal 4 cm) sebagai lapisan aus kedap air penahan gesekan ban."),
        const SizedBox(height: 16),
        _buildInlineImage(
          "assets/gambar/cp2/Perkerasan_Jalan/Gambar 19 bagian perkerasan jalan.jpeg",
          "Gambar 19: Struktur Lapisan Perkerasan Lentur, Kaku, dan Komposit",
        ),
        const SizedBox(height: 12),
        _buildInlineImage(
          "assets/gambar/cp2/Perkerasan_Jalan/Gambar 20 contoh potongan melintang jalan dengan lapis perkerasan jalan aspal.jpeg",
          "Gambar 20: Detail Potongan Melintang Lapis Perkerasan Aspal beserta Bahu Jalan & Kemiringan",
        ),
      ],
    );
  }

  Widget _buildStrukturJembatanSection() {
    return _buildCardWrapper(
      title:
          "5. Anatomi Struktur Jembatan Lengkap (Superstructure & Substructure)",
      tag: "KONSTRUKSI JEMBATAN",
      tagColor: const Color(0xFF7C3AED),
      icon: Icons.commit_rounded,
      children: [
        const Text(
          "Jembatan adalah konstruksi yang menghubungkan rintangan fisik seperti sungai, lembah, atau jalan lain. Komponen jembatan terbagi dalam dua hierarki utama:",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoBox(
                          "Struktur Atas (Superstructure)",
                          const Color(0xFF0284C7),
                          [
                            "Slab Lantai Kendaraan: Menahan langsung beban roda kendaraan.",
                            "Gelagar (Girder): Gelagar baja atau PCI prategang penyangga lantai.",
                            "Balok Diafragma: Mengakukan girder lateral terhadap gaya puntir.",
                            "Trotoar & Kerb: Jalur pejalan kaki samping jembatan.",
                            "Tiang Sandaran (Railing): Tinggi 0,9 m, penahan beban 100 kg/m.",
                            "Elastomeric Bearing Pad: Karet peredam benturan ke abutment.",
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildInfoBox(
                          "Struktur Bawah (Substructure)",
                          const Color(0xFF16A34A),
                          [
                            "Pangkal Jembatan (Abutment): Penumpu ujung jembatan & penahan tanah timbunan (back wall, breast wall, wing wall).",
                            "Pilar Jembatan (Pier): Penopang tengah di aliran sungai jika bentang jembatan panjang (pier head, kolom, pile cap).",
                            "Fondasi Jembatan: Meneruskan beban ke tanah keras (tiang pancang, bored pile, sumuran caisson).",
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildInfoBox(
                        "Struktur Atas (Superstructure)",
                        const Color(0xFF0284C7),
                        [
                          "Slab Lantai Kendaraan: Menahan langsung beban roda kendaraan.",
                          "Gelagar (Girder): Gelagar baja atau PCI prategang penyangga lantai.",
                          "Balok Diafragma: Mengakukan girder lateral terhadap gaya puntir.",
                          "Trotoar & Kerb: Jalur pejalan kaki samping jembatan.",
                          "Tiang Sandaran (Railing): Tinggi 0,9 m, penahan beban 100 kg/m.",
                          "Elastomeric Bearing Pad: Karet peredam benturan ke abutment.",
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoBox(
                        "Struktur Bawah (Substructure)",
                        const Color(0xFF16A34A),
                        [
                          "Pangkal Jembatan (Abutment): Penumpu ujung jembatan & penahan tanah timbunan (back wall, breast wall, wing wall).",
                          "Pilar Jembatan (Pier): Penopang tengah di aliran sungai jika bentang jembatan panjang (pier head, kolom, pile cap).",
                          "Fondasi Jembatan: Meneruskan beban ke tanah keras (tiang pancang, bored pile, sumuran caisson).",
                        ],
                      ),
                    ],
                  );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          "Bangunan Pelengkap & Pengaman Jembatan:",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        _buildBulletPoint("Jalan Pendekat (Oprit) & Plat Injak (Approach Slab)",
            "Mencegah perbedaan penurunan elevasi (settlement) antara jalan dan kepala jembatan."),
        _buildBulletPoint("Talud Pelindung (Revetment)",
            "Melindungi tanah abutment dari erosi gerusan air sungai (scouring)."),
        _buildBulletPoint("Saluran Drainase Jembatan",
            "Pipa pembuang air hujan dari lantai jembatan untuk mencegah lapuknya perkerasan aspal."),
        _buildBulletPoint("Patok Penuntun & Lampu Penerangan",
            "Pemandu visual lalu lintas saat melintasi jembatan di malam hari."),
        const SizedBox(height: 16),
        _buildInlineImage(
          "assets/gambar/cp2/Umum/Gambar_Page_42_Item_1.jpeg",
          "Gambar Anatomi Komponen Jembatan: Superstructure, Substructure, Bearing, Pier & Abutment",
        ),
      ],
    );
  }

  Widget _buildBimRoadBridgeSection() {
    return _buildCardWrapper(
      title: "6. Penerapan Teknologi BIM pada Desain Jalan & Jembatan",
      tag: "INTEGRASI BIM INFRASTRUKTUR",
      tagColor: const Color(0xFF2563EB),
      icon: Icons.hub_rounded,
      children: [
        const Text(
          "Penerapan BIM pada jalan dan jembatan (Civil 3D & OpenBridge / Revit Structure) membawa revolusi dari CAD konvensional 2D:",
          style: TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 14),
        _buildBulletPoint("Koridor Parametrik Jalan",
            "Penampang tipikal (subassembly: lajur, bahu, talud cut/fill) terikat dinamis pada sumbu trase. Jika kurva alinyemen digeser, volume galian dan timbunan (cut & fill) terkalkulasi otomatis."),
        _buildBulletPoint("Model Struktural Parametrik Jembatan",
            "Girder, pier head, pilar, dan abutment tersinkronisasi dengan elevasi profil jalan jembatan."),
        _buildBulletPoint("Deteksi Tabrakan (Clash Detection)",
            "Memeriksa benturan antara pipa utilitas kota di bawah trotoar dengan struktur abutment atau tiang pancang sebelum pelaksanaan lapangan."),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 2: GALERI GAMBAR TEKNIS & TIPIKAL CP 2
  // -------------------------------------------------------------
  Widget _buildGaleriTab(bool isDesktop) {
    final galleryItems = [
      {
        "title": "Gambar 1: Sketsa Hierarki Jaringan Jalan Primer & Sekunder",
        "category": "Jalan",
        "path": "assets/gambar/cp2/Jalan/Gambar 1 Sketsa Hierarki Jalan.png",
        "desc":
            "Hubungan antar simpul jasa distribusi nasional, regional, hingga permukiman perkotaan.",
      },
      {
        "title": "Gambar 3: Tipikal Damaja, Damija, dan Dawasja",
        "category": "Jalan",
        "path":
            "assets/gambar/cp2/Jalan/Gambar 3 Tipikal Damaja, Damija dan Dawasja.png",
        "desc":
            "Batas ruang manfaat jalan (+5m ruang bebas atas dan -1,5m bawah), ruang milik jalan, dan ruang pengawasan.",
      },
      {
        "title": "Gambar 4: Bagian-Bagian Manfaat Jalan & Drainase",
        "category": "Jalan",
        "path":
            "assets/gambar/cp2/Jalan/Gambar 4 Bagian-Bagian Manfaat Jalan.jpeg",
        "desc":
            "Penampang melintang badan jalan, trotoar, bahu jalan, jalur tepian, dan saluran samping.",
      },
      {
        "title": "Gambar 6: Alinyemen Horisontal Trase Jalan",
        "category": "Jalan",
        "path": "assets/gambar/cp2/Jalan/Gambar 6 Alinyemen horisontal.jpeg",
        "desc":
            "Visualisasi trase tikungan jalan raya dan transisi superelevasi kemiringan melintang.",
      },
      {
        "title": "Gambar 7: Tikungan Full Circle (FC)",
        "category": "Jalan",
        "path":
            "assets/gambar/cp2/Jalan/Gambar 7 tikungan Full Circle (FC).jpeg",
        "desc":
            "Lengkung tikungan lingkaran penuh dengan titik TC (Tangent to Circle) dan CT (Circle to Tangent).",
      },
      {
        "title": "Gambar 8: Tikungan Spiral - Circle - Spiral (SCS)",
        "category": "Jalan",
        "path":
            "assets/gambar/cp2/Jalan/Gambar 8 tikungan Spiral - Circle Spiral.jpeg",
        "desc":
            "Tikungan dengan spiral peralihan masuk, busur lingkaran tengah, dan spiral keluar.",
      },
      {
        "title": "Gambar 9: Tikungan Spiral - Spiral (SS)",
        "category": "Jalan",
        "path": "assets/gambar/cp2/Jalan/Gambar 9 Tikungan Spiral Spiral.jpeg",
        "desc":
            "Dua lengkung spiral tanpa busur lingkaran untuk medan tikungan yang sempit.",
      },
      {
        "title": "Gambar 10: Alinyemen Vertikal (Profil Memanjang)",
        "category": "Jalan",
        "path": "assets/gambar/cp2/Jalan/Gambar 10 Alinyemen Vertikal.jpeg",
        "desc":
            "Profil tanjakan, turunan, dan lengkung cembung/cekung pada elevasi sumbu jalan.",
      },
      {
        "title": "Gambar 11: Potongan Melintang Jalan Perkotaan 2-Lajur-2-Arah",
        "category": "Jalan",
        "path":
            "assets/gambar/cp2/Jalan/Gambar 11 Tipikal penampang melintang jalan perkotaan 2-lajur-2-arah tak terbagi.jpeg",
        "desc":
            "Penampang jalan tak terbagi lengkap dengan trotoar dan batas pagar persil.",
      },
      {
        "title":
            "Gambar 12: Potongan Melintang Lengkap dengan Jalur Hijau & Sepeda",
        "category": "Jalan",
        "path":
            "assets/gambar/cp2/Jalan/Gambar 12 Tipikal potongan melintang jalan 2-lajur-2-arah tak terbagi, yang.jpeg",
        "desc":
            "Jalur lalu lintas, jalur tepian, jalur hijau, jalur sepeda, dan saluran samping di bawah trotoar.",
      },
      {
        "title": "Gambar 15: Tipikal Median Jalan yang Diturunkan",
        "category": "Jalan",
        "path":
            "assets/gambar/cp2/Jalan/Gambar 15 Tipikal Median Jalan yang diturunkan.jpeg",
        "desc":
            "Median cekung (diturunkan) dengan kemiringan lereng 6-15% sebagai drainase alami.",
      },
      {
        "title": "Gambar 16: Tipikal Median Jalan yang Ditinggikan",
        "category": "Jalan",
        "path":
            "assets/gambar/cp2/Jalan/Gambar 16 Tipikal Median Jalan yang Ditinggikan.jpeg",
        "desc":
            "Median fisik ditinggikan dengan kerb dan jalur tepian untuk keselamatan pemisah arah.",
      },
      {
        "title": "Gambar 19: Bagian Lapisan Perkerasan Jalan",
        "category": "Perkerasan Jalan",
        "path":
            "assets/gambar/cp2/Perkerasan_Jalan/Gambar 19 bagian perkerasan jalan.jpeg",
        "desc":
            "Perbandingan perkerasan lentur (aspal), kaku (beton semen), dan komposit.",
      },
      {
        "title": "Gambar 20: Potongan Melintang Perkerasan Aspal Jalan",
        "category": "Perkerasan Jalan",
        "path":
            "assets/gambar/cp2/Perkerasan_Jalan/Gambar 20 contoh potongan melintang jalan dengan lapis perkerasan jalan aspal.jpeg",
        "desc":
            "Ketebalan AC-WC (4 cm), AC-BC (6 cm), Aggregat Kelas A (20 cm), Kelas B (20 cm), Kelas S (15 cm), dan Selected Embankment.",
      },
      {
        "title": "Gambar 21: Sandaran dan Tiang Sandaran Jembatan (Railing)",
        "category": "Struktur Jembatan",
        "path":
            "assets/gambar/cp2/Jembatan/Gambar 21 Sandaran dan Tiang Sandaran.jpeg",
        "desc":
            "Pipa sandaran pengaman pejalan kaki dan tiang penumpu di trotoar jembatan.",
      },
      {
        "title": "Gambar 22: Kerb Jembatan dan Trotoar",
        "category": "Struktur Jembatan",
        "path": "assets/gambar/cp2/Jembatan/Gambar 22 Kerb.jpeg",
        "desc":
            "Peninggian tepi trotoar pembatas jalur lalu lintas kendaraan jembatan.",
      },
      {
        "title": "Gambar 26: Gelagar Baja Struktur Atas Jembatan",
        "category": "Struktur Jembatan",
        "path": "assets/gambar/cp2/Jembatan/Gambar 26 Gelagar Baja.jpeg",
        "desc":
            "Gelagar memanjang baja yang menyangga pelat lantai kendaraan jembatan.",
      },
      {
        "title": "Gambar 27: Abutment (Pangkal Jembatan)",
        "category": "Struktur Jembatan",
        "path":
            "assets/gambar/cp2/Jembatan/Gambar 27 Abutment (Pangkal Jembatan).jpeg",
        "desc":
            "Konstruksi pangkal jembatan penahan tanah timbunan oprit dan penumpu girder ujung.",
      },
      {
        "title": "Gambar 28 & 29: Pilar Jembatan & Bagian-Bagiannya",
        "category": "Struktur Jembatan",
        "path":
            "assets/gambar/cp2/Jembatan/Gambar 29 Bagian-Bagian Pilar Jembatan.jpeg",
        "desc":
            "Kepala pilar (pier head), korbel jacking, tumpuan bearing, kolom pilar, dan tiang pancang pilecap.",
      },
      {
        "title": "Gambar 30: Saluran Pipa Drainase Jembatan",
        "category": "Bangunan Pelengkap",
        "path": "assets/gambar/cp2/Umum/Gambar 30 saluran drainase.jpeg",
        "desc":
            "Sistem drainase pipa pembuangan air hujan di bawah lantai jembatan.",
      },
      {
        "title": "Gambar 31: Oprit (Jalan Pendekat) Jembatan",
        "category": "Bangunan Pelengkap",
        "path": "assets/gambar/cp2/Jembatan/Gambar 31 Oprit Jembatan.jpeg",
        "desc":
            "Bagian jalan transisi penghubung perkerasan dengan struktur kepala jembatan.",
      },
      {
        "title": "Gambar 32: Talud Pelindung Abutment (Revetment)",
        "category": "Bangunan Pelengkap",
        "path": "assets/gambar/cp2/Jembatan/Gambar 32 talud jembatan.jpeg",
        "desc":
            "Pasangan batu pelindung tebing sungai di sekitar abutment dari bahaya penggerusan air.",
      },
      {
        "title": "Gambar 33: Patok Penuntun (Guide Post)",
        "category": "Bangunan Pelengkap",
        "path": "assets/gambar/cp2/Umum/Gambar 33 Patok penuntun.jpeg",
        "desc":
            "Rambu patok penunjuk jalan di sepanjang oprit jembatan untuk keamanan malam hari.",
      },
      {
        "title":
            "Gambar Ringkasan: Anatomi Komponen Lengkap Konstruksi Jembatan",
        "category": "Struktur Jembatan",
        "path": "assets/gambar/cp2/Umum/Gambar_Page_42_Item_1.jpeg",
        "desc":
            "Diagram integrasi superstructure (deck, girder, expansion joint), substructure (pier, abutment), bearing, dan foundation.",
      },
    ];

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
                            "Galeri Gambar Teknis Konstruksi Jalan & Jembatan (CP 2)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Dokumentasi lengkap standar tipikal penampang melintang, alinyemen geometrik tikungan, lapisan perkerasan aspal, serta detail konstruksi jembatan.",
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
              for (var item in galleryItems) ...[
                _buildGalleryCard(
                  title: item["title"]!,
                  category: item["category"]!,
                  imagePath: item["path"]!,
                  desc: item["desc"]!,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE UI HELPERS ---

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
            color: Colors.black.withValues(alpha: 0.02),
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
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: tagColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag.toUpperCase(),
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
              ),
            ],
          ),
          const SizedBox(height: 16),
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

  Widget _buildInfoBox(String title, Color accentColor, List<String> points) {
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
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: accentColor)),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                          fontSize: 13, height: 1.5, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineImage(String imagePath, String caption) {
    return TechnicalImageCard(
      imagePath: imagePath,
      caption: caption,
      maxHeight: 380,
    );
  }

  Widget _buildGalleryCard({
    required String title,
    required String category,
    required String imagePath,
    required String desc,
    required bool isDesktop,
  }) {
    final fileName = imagePath.split('/').last;

    return TechnicalImageCard(
      imagePath: imagePath,
      caption: 'Sumber Dokumen Teknis: $fileName',
      maxHeight: 520,
      title: title,
      subtitle: category,
      description: desc,
    );
  }
}
