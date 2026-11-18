class CP1Topic {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String summary;

  const CP1Topic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.summary,
  });
}

class CPBasicItem {
  final String id;
  final String number;
  final String title;
  final String subTitle;
  final String phase;
  final String element;
  final String description;
  final String content;

  const CPBasicItem({
    required this.id,
    required this.number,
    required this.title,
    required this.subTitle,
    required this.phase,
    required this.element,
    required this.description,
    required this.content,
  });
}

const String cp1TextContent = '''
Capaian Pembelajaran 1: Memahami gambar 2D & 3D struktur, arsitektur, interior dan eksterior gedung rumah sederhana dan bertingkat dengan menggunakan teknologi Building Information Modelling (BIM) di bidang desain pemodelan dan informasi bangunan (Fase F - DPIB).
''';

const String cp2TextContent = '''
Capaian Pembelajaran 2: Memahami gambar 2D & 3D konstruksi jalan dan jembatan, anatomi ruang manfaat jalan, kaidah geometrik alinyemen horisontal & vertikal, struktur perkerasan jalan, serta anatomi struktur atas dan bawah jembatan menggunakan teknologi Building Information Modelling (BIM) di bidang desain pemodelan dan informasi bangunan (Fase F - DPIB).
''';

const String cp3TextContent = '''
Capaian Pembelajaran 3: Memahami perkembangan gaya arsitektur populer kekinian, terutama arsitektur minimalis dan arsitektur industrial, serta menerapkannya dalam analisis bentuk, material, dan tata ruang bangunan.

Submateri:
1. Arsitektur Minimalis: prinsip sederhana, fungsi utama, palet warna netral, dan penghematan elemen dekoratif.
2. Arsitektur Industrial: penggunaan baja, beton ekspos, kaca, serta ekspresi struktur dan instalasi yang terbuka.
''';

const String cp4TextContent = '''
Capaian Pembelajaran 4: Memahami arsitektur berbasis lingkungan yang merespons iklim tropis dan prinsip keberlanjutan, termasuk strategi passive design pada bangunan.

Submateri:
1. Arsitektur Tropis: orientasi bangunan, ventilasi silang, naungan, dan pengendalian panas serta kelembapan.
2. Arsitektur Hijau: efisiensi energi, penggunaan material ramah lingkungan, pengelolaan air, dan kenyamanan penghuni.
''';

const String cp5TextContent = '''
Capaian Pembelajaran 5: Memahami kekayaan arsitektur nusantara dan nilai lokal yang terkandung dalam arsitektur vernakular, serta kemungkinan adaptasinya pada desain kontemporer.

Submateri:
1. Arsitektur Vernakular: bentuk, material lokal, teknik konstruksi tradisional, dan penyesuaian terhadap iklim serta budaya setempat.
''';

final List<CPBasicItem> basicCurriculumList = [
  const CPBasicItem(
    id: 'cp1',
    number: 'CP 1',
    title: 'Pemodelan 2D & 3D Gedung Berbasis BIM',
    subTitle: 'Struktur, Arsitektur, Interior & Eksterior Rumah Sederhana dan Bertingkat',
    phase: 'Fase F • Kelas XI / XII SMK DPIB',
    element: 'Desain Pemodelan Bangunan Gedung',
    description:
        'Memahami gambar 2D & 3D struktur, arsitektur, interior dan eksterior gedung rumah sederhana dan bertingkat menggunakan teknologi Building Information Modelling (BIM).',
    content: cp1TextContent,
  ),
  const CPBasicItem(
    id: 'cp2',
    number: 'CP 2',
    title: 'Pemodelan Jalan dan Jembatan Berbasis BIM',
    subTitle: 'Konstruksi Jalan Raya, Geometrik, Perkerasan & Struktur Jembatan',
    phase: 'Fase F • Kelas XI / XII SMK DPIB',
    element: 'Desain Pemodelan Jalan & Jembatan',
    description:
        'Menjelaskan bagian konstruksi jalan & jembatan, klasifikasi teknis, alinyemen geometrik, perkerasan, struktur atas & bawah jembatan serta pemodelan BIM.',
    content: cp2TextContent,
  ),
  const CPBasicItem(
    id: 'cp3',
    number: 'CP 3',
    title: 'Gaya Arsitektur Populer Kekinian',
    subTitle: 'Arsitektur Minimalis dan Arsitektur Industrial',
    phase: 'Fase F • Kelas XI / XII SMK DPIB',
    element: 'Apresiasi Gaya Arsitektur',
    description:
        'Menganalisis ciri visual, material, dan prinsip desain gaya minimalis serta industrial pada bangunan kontemporer.',
    content: cp3TextContent,
  ),
  const CPBasicItem(
    id: 'cp4',
    number: 'CP 4',
    title: 'Arsitektur Berbasis Lingkungan',
    subTitle: 'Respons Iklim Tropis dan Arsitektur Hijau',
    phase: 'Fase F • Kelas XI / XII SMK DPIB',
    element: 'Desain Berkelanjutan',
    description:
        'Memahami strategi desain yang merespons iklim tropis dan prinsip keberlanjutan untuk kenyamanan bangunan.',
    content: cp4TextContent,
  ),
  const CPBasicItem(
    id: 'cp5',
    number: 'CP 5',
    title: 'Arsitektur Nusantara',
    subTitle: 'Kearifan Lokal pada Arsitektur Vernakular',
    phase: 'Fase F • Kelas XI / XII SMK DPIB',
    element: 'Arsitektur Vernakular',
    description:
        'Mengenali bentuk, material, dan teknik konstruksi arsitektur lokal serta nilai budaya yang melekat padanya.',
    content: cp5TextContent,
  ),
];
