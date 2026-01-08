// lib/quiz_data.dart

class QuizQuestion {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation = "",
  });
}

// ==========================================
// 📝 DATA BANK SOAL (50 SOAL)
// ==========================================

final List<QuizQuestion> masterQuizList = [
  // --- K3 (Keselamatan & Kesehatan Kerja) ---
  QuizQuestion(
    id: "q1",
    text: "Alat-alat untuk pencegahan kecelakaan kerja dapat digolongkan menjadi beberapa kelompok, Kecuali?",
    options: [
      "Alat-alat pengobatan",
      "Alat-alat deteksi (alarm atau sirine)",
      "Alat-alat antisipasi kebakaran",
      "Alat-alat keselamatan",
      "Alat-alat pelindung diri"
    ],
    correctIndex: 0, 
  ),
  QuizQuestion(
    id: "q2",
    text: "Suatu kejadian yang tidak terduga dan tidak sengaja sehingga mengakibatkan kerugian materi dan immateri yaitu?",
    options: [
      "Kecelakaan",
      "Benturan",
      "Kecerobohan",
      "Kegagalan",
      "Keburukan"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q3",
    text: "Safety belt dapat berfungsi sebagai?",
    options: [
      "Alat pencegah jatuh dari ketinggian",
      "Alat pelindung badan",
      "Alat pelindung kepala",
      "Alat pelindung tertimpa dari benda yang jatuh",
      "Alat pelindung dari terpapar radiasi"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q4",
    text: "Yang bukan termasuk jenis kecelakaan kerja adalah?",
    options: [
      "Digigit anjing gila",
      "Jatuh dari ketinggian",
      "Terkena paku, terpukul, kena pecahan kaca dan batu",
      "Kesetrum listrik",
      "Tenggelam"
    ],
    correctIndex: 0,
  ),

  // --- Macam-macam Bangunan ---
  QuizQuestion(
    id: "q5",
    text: "Salah satu konstruksi yang termasuk dalam jenis bangunan gedung adalah?",
    options: ["Hotel", "Jembatan", "Pelabuhan", "Lapangan parkir", "Jalan"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q6",
    text: "Yang termasuk kepada bangunan milik negara adalah?",
    options: [
      "Kantor bupati", 
      "Sekolah",
      "Rumah ibadah",
      "Hotel",
      "Rumah tempat tinggal"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q7",
    text: "Bagian dari jalan yang berfungsi sebagai pembatas jalan yang biasanya ditanami rumput dan tumbuh-tumbuhan disebut?",
    options: [
      "Median jalan",
      "Zebra cross",
      "Badan Jalan",
      "Bahu jalan",
      "Lajur jalan"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q8",
    text: "Pengertian jembatan adalah?",
    options: [
      "Konstruksi yang berfungsi untuk melewatkan lalu lintas yang terputus akibat adanya hambatan berupa sungai, lembah, dll",
      "Konstruksi untuk lalu lintas udara yang tersendat",
      "Konstruksi untuk lalu lintas air yang tersendat",
      "Konstruksi untuk pejalan kaki yang tersendat",
      "Konstruksi untuk mempermudah lalu lintas kendaraan"
    ],
    correctIndex: 0,
  ),

  // --- Kayu ---
  QuizQuestion(
    id: "q9",
    text: "Kayu merupakan salah satu bahan konstruksi yang bersumber dari?",
    options: ["Hutan", "Kebun", "Toko bangunan", "Bangsal kayu", "Semak belukar"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q10",
    text: "Salah satu kekurangan kayu sebagai bahan bangunan adalah?",
    options: [
      "Bisa terbakar",
      "Mudah dalam pengerjaannya",
      "Mudah didapat",
      "Bersifat kaku",
      "Ringan"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q11",
    text: "Yang termasuk produk kayu olahan adalah?",
    options: [
      "Kayu lapis (plywood)",
      "Kayu balok",
      "Kayu profil",
      "Papan",
      "Kayu gelondongan"
    ],
    correctIndex: 0,
  ),

  // --- Beton ---
  QuizQuestion(
    id: "q12",
    text: "Fungsi semen pada campuran beton yaitu sebagai?",
    options: [
      "Bahan pengikat",
      "Bahan pengisi",
      "Bahan pemadat",
      "Bahan pelengkap",
      "Bahan baku"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q13",
    text: "Fungsi besi tulangan pada beton adalah?",
    options: [
      "Sebagai penahan gaya tarik",
      "Sebagai penahan gaya tekan",
      "Untuk memperkuat beton",
      "Supaya beton tahan lama",
      "Sebagai bahan tambahan"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q14",
    text: "Perbandingan campuran beton 1:3:5 artinya?",
    options: [
      "1 semen : 3 pasir : 5 kerikil",
      "1 kerikil : 3 pasir : 5 semen",
      "1 pasir : 3 semen : 5 kerikil",
      "1 pasir : 3 kerikil : 5 semen",
      "1 semen : 3 kerikil : 5 pasir"
    ],
    correctIndex: 0,
  ),

  // --- Baja & Logam ---
  QuizQuestion(
    id: "q15",
    text: "Berikut ini kelebihan besi atau baja sebagai bahan konstruksi, kecuali?",
    options: [
      "Perlu perawatan khusus",
      "Bentuknya lebih ramping",
      "Cocok untuk struktur bentangan panjang",
      "Tersedia berbagai ukuran",
      "Bisa dibongkar pasang"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q16",
    text: "Yang bukan merupakan jenis-jenis baja profil adalah?",
    options: ["Profil A", "Profil C", "Profil H", "Profil I", "Profil L"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q17",
    text: "Baja berbentuk lembaran tipis dan lebar disebut?",
    options: ["Baja pelat", "Baja siku", "Baja profil", "Baja batang", "Balok besi"],
    correctIndex: 0,
  ),

  // --- MEKTEK (Mekanika Teknik) ---
  QuizQuestion(
    id: "q18",
    text: "Struktur bangunan yang bersifat kaku adalah?",
    options: [
      "Balok, pelengkung dan cangkang",
      "Rangka, membran, dan jaring",
      "Kabel, membran dan tenda",
      "Kabel, kubah dan jaring",
      "Kolom, kabel dan membran"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q19",
    text: "Klasifikasi elemen struktur berdasarkan sifatnya, yaitu?",
    options: [
      "Elemen kaku dan tidak kaku",
      "Elemen garis dan permukaan",
      "Elemen garis dan tidak kaku",
      "Elemen kayu, dan beton",
      "Elemen baja dan kayu"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q20",
    text: "Bahan utama untuk membentuk struktur bangunan adalah?",
    options: [
      "Kayu, beton dan baja",
      "Kayu, beton dan karet",
      "Beton, karet dan bambu",
      "Beton, bambu dan kayu",
      "Baja, bambu dan beton"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q21",
    text: "Jembatan gantung kekuatannya terletak pada kabel. Kelebihan elemen kabel adalah?",
    options: [
      "Kuat menahan gaya tarik",
      "Kuat menahan gaya tekan",
      "Tidak melentur",
      "Bisa diikat",
      "Mudah putus"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q22",
    text: "Yang bukan merupakan ciri-ciri gaya adalah?",
    options: [
      "Mempunyai bentuk",
      "Mempunyai garis kerja",
      "Mempunyai titik tangkap",
      "Mempunyai besaran",
      "Mempunyai arah"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q23",
    text: "Gaya tarik dapat mengakibatkan ... pada elemen struktur.",
    options: ["Putus", "Patah", "Hancur", "Bengkok", "Pecah"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q24",
    text: "Gaya berikut yang bisa mengakibatkan pecah atau hancur pada permukaan beton adalah?",
    options: [
      "Gaya tekan",
      "Gaya tarik",
      "Puntiran",
      "Gaya geser",
      "Momen gaya"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q25",
    text: "Sesuatu yang menyebabkan perubahan dari diam menjadi bergerak, perubahan tempat dan bentuk, adalah pengertian dari?",
    options: ["Gaya", "Perpindahan", "Jarak", "Percepatan", "Daya"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q26",
    text: "Penjumlahan dua buah gaya atau lebih sehingga dihasilkan sebuah gaya pengganti disebut?",
    options: [
      "Resultante gaya",
      "Momentum",
      "Momen gaya",
      "Kopel gaya",
      "Jumlah gaya"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q27",
    text: "Menentukan resultan gaya dapat dilakukan dengan 2 cara yaitu?",
    options: [
      "Cara analitis dan cara grafis",
      "Cara analitis dan teoritis",
      "Cara analitis dan cara praktis",
      "Cara menjumlahkan dan mengurangkan",
      "Cara menambahkan dan membagi"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q28",
    text: "Jika R = √(P1² + P2²), P1=3 Ton, P2=4 Ton. Berapakah Resultan gayanya (R)?",
    options: ["5 Ton", "6 Ton", "7 Ton", "8 Ton", "9 Ton"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q29",
    text: "Sebuah gaya dapat dipindahkan melalui?",
    options: [
      "Garis kerjanya",
      "Titik tangkapnya",
      "Resultan gaya",
      "Komponen gaya",
      "Momen gaya"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q30",
    text: "Perhatikan gambar (soal no 30 pada PDF), jika P1=80kg, P2=60kg, P3=20kg. Besar Resultante (R) adalah?",
    options: [
      "0 kg",
      "80 kg (kekiri)",
      "80 kg (kekanan)",
      "160 Kg (ke kiri)",
      "160 Kg (ke kanan)"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q31",
    text: "Perkalian gaya (P) dengan jarak (L) terhadap titik tertentu sehingga menghasilkan gaya baru disebut?",
    options: [
      "Momen gaya",
      "Gaya terpusat",
      "Gaya terbagi merata",
      "Momen terpusat",
      "Semua benar"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q32",
    text: "Besar atau kecilnya suatu momen gaya sangat dipengaruhi oleh?",
    options: [
      "Jarak atau lengan gaya",
      "Besar gaya",
      "Arah gaya",
      "Besar dan arah",
      "Putaran gaya"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q33",
    text: "Jika diketahui besar gaya F=200 Kg dengan jarak 2 m, maka berapakah besar momen gaya yang terjadi?",
    options: ["400 Kg.m", "400 Kg", "400 m", "400", "400 m.Kg"],
    correctIndex: 0,
  ),

  // --- Gambar Teknik ---
  QuizQuestion(
    id: "q34",
    text: "Yang tidak termasuk Peralatan untuk menggambar teknik adalah?",
    options: [
      "Meteran",
      "Pensil Mekanik",
      "Sepasang Mistar segitiga",
      "Meja gambar",
      "Jangka"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q35",
    text: "Yang tidak tercantum dalam kotak nama (KOP/Kepala Gambar) adalah?",
    options: [
      "Ukuran Gambar", 
      "Nama yang menggambar",
      "Skala",
      "Tanggal",
      "Judul Gambar"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q36",
    text: "Pensil dengan kode HB termasuk dalam standard kekerasan?",
    options: ["Sedang", "Keras sedang", "Keras", "Lunak Sedang", "Lunak"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q37",
    text: "Dalam Gambar teknik, ukuran kertas berdasarkan standar ISO. Perbandingan A3 terhadap A4 adalah?",
    options: [
      "A3 sama dengan 2 x A4",
      "A3 sama dengan 1/2 A2",
      "A3 sama dengan 1/2 A1",
      "A3 sama dengan 1/2 A0",
      "A3 sama dengan 1/2 A1"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q38",
    text: "Jika ukuran kertas gambar A3 = 420 x 297 mm, maka ukuran kertas A4 adalah?",
    options: [
      "297 x 210 mm",
      "297 x 210 cm",
      "420 x 297 mm",
      "594 x 420 mm",
      "29.7 x 21 cm"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q39",
    text: "Garis strip-titik-strip (putus titik) dipakai untuk menggambar potongan. Ketebalan garisnya adalah?",
    options: [
      "1/3 dari tebal garis gambar", // Asumsi jawaban A
      "1/2 dari tebal garis gambar",
      "1/4 dari tebal garis gambar",
      "2x tebal garis gambar",
      "Sama dengan tebal garis gambar"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q40",
    text: "Garis yang memiliki ketebalan 1/4 dari garis gambar disebut juga dengan?",
    options: [
      "Garis tipis",
      "Garis setrip",
      "Garis setrip titik setrip",
      "Garis tebal",
      "Garis putus"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q41",
    text: "Salah satu kegunaan Garis tipis dengan ketebalan 0,20-0,25 mm adalah untuk?",
    options: [
      "Garis AS",
      "Judul Gambar",
      "Garis pinggir",
      "Objek terpotong",
      "Garis Gambar"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q42",
    text: "Fungsi dari garis zig zag dalam gambar teknik adalah untuk?",
    options: [
      "Garis untuk memperpendek ukuran sebenarnya (pemotongan sebagian)",
      "Garis untuk menggambar benda nyata",
      "Garis untuk menggambarkan benda tak tampak",
      "Menggambar garis pinggir",
      "Menggambar garis kotak nama"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q43",
    text: "(Perhatikan gambar sepasang segitiga siku-siku) Besar sudut alpha dan beta adalah?",
    options: [
      "a=15° dan B=60°",
      "a=15° dan B=45°",
      "a=15° dan B=75°",
      "a=30° dan B=60°",
      "a=30° dan B=75°"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q44",
    text: "Sudut yang ada pada sepasang segi tiga standar adalah?",
    options: [
      "90°, 45°, 45° dan 90°, 60°, 30°",
      "90°, 45°, 45° dan 60°, 30°, 30°",
      "60°, 30°, 45° dan 60°, 30°, 45°",
      "60°, 30°, 45° dan 60°, 45°, 30°",
      "90°, 45°, 30° dan 90°, 30°, 30°"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q45",
    text: "Dalam sebuah penggaris segitiga terdapat 3 buah sudut, total jumlah ketiga sudut tersebut adalah?",
    options: ["180°", "120°", "150°", "220°", "160°"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q46",
    text: "Untuk menggambar ukuran sudut di kertas gambar secara manual, dipakai alat gambar?",
    options: ["Busur", "Pensil", "Pena", "Rapido", "Segitiga siku"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q47",
    text: "(Soal Gambar Simbol) Simbol gambar biasanya menunjukan?",
    options: [
      "Pasangan Batu bata",
      "Batu Kali",
      "Pintu dua daun",
      "Keramik",
      "Pintu geser"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q48",
    text: "(Soal Gambar Simbol 2) Simbol gambar biasanya menunjukan?",
    options: [
      "Pintu dua daun",
      "Dua Pintu geser",
      "Jendela",
      "Pintu satu daun",
      "Pintu geser"
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q49",
    text: "Sebidang tanah persegi 10m x 20m. Jika digambar skala 1:100, panjang garis tanah tersebut menjadi?",
    options: ["20 cm", "20 mm", "10 mm", "10 cm", "120 mm"],
    correctIndex: 0,
  ),
  QuizQuestion(
    id: "q50",
    text: "Lebar pintu 80 cm, jika skala gambar 1:50, maka lebar pintu yang digambarkan adalah?",
    options: ["1,6 cm", "8 mm", "40 cm", "16 mm", "16 cm"],
    correctIndex: 0,
  ),
];