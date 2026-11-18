// lib/quiz_data.dart

class QuizQuestion {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? imagePath;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation = "",
    this.imagePath,
  });
}

// ==========================================
// 📝 DATA BANK SOAL (62 SOAL)
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
    explanation: "Alat pengobatan dipakai setelah kecelakaan terjadi, sedangkan kelompok lainnya bersifat pencegah.",
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
    explanation: "Kecelakaan adalah kejadian tak terduga dan tidak sengaja yang menimbulkan kerugian materi maupun immateri.",
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
    explanation: "Safety belt menahan pekerja agar tidak jatuh saat bekerja di ketinggian.",
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
    explanation: "Digigit anjing gila bukan risiko proses kerja konstruksi, jadi tidak termasuk kecelakaan kerja.",
  ),

  // --- Macam-macam Bangunan ---
  QuizQuestion(
    id: "q5",
    text: "Salah satu konstruksi yang termasuk dalam jenis bangunan gedung adalah?",
    options: ["Hotel", "Jembatan", "Pelabuhan", "Lapangan parkir", "Jalan"],
    correctIndex: 0,
    explanation: "Hotel termasuk bangunan gedung, sedangkan jembatan, pelabuhan, dan jalan adalah bangunan infrastruktur.",
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
    explanation: "Kantor bupati adalah bangunan milik negara yang dipakai untuk penyelenggaraan pemerintahan.",
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
    explanation: "Median jalan memisahkan lajur lalu lintas dan biasanya ditanami rumput atau tumbuhan.",
    imagePath: "assets/gambar/cp2/Jalan/Gambar 15 Tipikal Median Jalan yang diturunkan.jpeg",
  ),
  QuizQuestion(
    id: "q8",
    text: "Konstruksi pada gambar berikut yang berfungsi melewatkan lalu lintas menyeberangi rintangan fisik (seperti sungai atau lembah) adalah?",
    options: [
      "Jembatan (Gelagar Baja)",
      "Konstruksi Terowongan Bawah Tanah",
      "Dinding Penahan Tanah",
      "Talud Tebing",
      "Dermaga Pelabuhan"
    ],
    correctIndex: 0,
    explanation: "Gelagar baja adalah struktur atas jembatan yang memikul beban dan melewatkan lalu lintas di atas rintangan.",
    imagePath: "assets/gambar/cp2/Jembatan/Gambar 26 Gelagar Baja.jpeg",
  ),

  // --- Kayu ---
  QuizQuestion(
    id: "q9",
    text: "Kayu merupakan salah satu bahan konstruksi yang bersumber dari?",
    options: ["Hutan", "Kebun", "Toko bangunan", "Bangsal kayu", "Semak belukar"],
    correctIndex: 0,
    explanation: "Kayu berasal dari hutan sebagai bahan baku utama penghasil kayu.",
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
    explanation: "Kayu mudah terbakar, sehingga memerlukan perlakuan tahan api pada bangunan.",
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
    explanation: "Kayu lapis adalah produk kayu olahan yang dibuat dari lembaran veneer yang direkatkan.",
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
    explanation: "Semen berfungsi sebagai bahan pengikat yang menyatukan pasir, kerikil, dan air menjadi beton.",
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
    explanation: "Besi tulangan menahan gaya tarik karena beton lemah terhadap gaya tarik.",
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
    explanation: "Notasi 1:3:5 berturut-turut adalah perbandingan semen, pasir, dan kerikil.",
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
    explanation: "Besi dan baja memang memerlukan perawatan khusus agar tidak berkarat, jadi itu bukan kelebihan.",
  ),
  QuizQuestion(
    id: "q16",
    text: "Yang bukan merupakan jenis-jenis baja profil adalah?",
    options: ["Profil A", "Profil C", "Profil H", "Profil I", "Profil L"],
    correctIndex: 0,
    explanation: "Profil A bukan jenis baja profil standar; yang umum antara lain profil C, H, I, dan L.",
  ),
  QuizQuestion(
    id: "q17",
    text: "Baja berbentuk lembaran tipis dan lebar disebut?",
    options: ["Baja pelat", "Baja siku", "Baja profil", "Baja batang", "Balok besi"],
    correctIndex: 0,
    explanation: "Baja pelat berbentuk lembaran tipis dan lebar, berbeda dengan baja profil atau baja batang.",
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
    explanation: "Balok, pelengkung, dan cangkang termasuk elemen struktur kaku yang menahan gaya tanpa perubahan bentuk besar.",
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
    explanation: "Elemen struktur dibedakan menjadi elemen kaku dan elemen tidak kaku berdasarkan perilaku terhadap gaya.",
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
    explanation: "Kayu, beton, dan baja adalah tiga bahan utama pembentuk struktur bangunan.",
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
    explanation: "Kabel kuat menahan gaya tarik, sehingga cocok untuk jembatan gantung.",
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
    explanation: "Gaya memiliki besaran, arah, titik tangkap, dan garis kerja, tetapi tidak memiliki bentuk.",
  ),
  QuizQuestion(
    id: "q23",
    text: "Gaya tarik dapat mengakibatkan ... pada elemen struktur.",
    options: ["Putus", "Patah", "Hancur", "Bengkok", "Pecah"],
    correctIndex: 0,
    explanation: "Gaya tarik yang melampaui kekuatan elemen dapat menyebabkan putus.",
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
    explanation: "Gaya tarik menyebabkan retak dan pecah pada permukaan beton karena beton lemah terhadap tarik.",
  ),
  QuizQuestion(
    id: "q25",
    text: "Sesuatu yang menyebabkan perubahan dari diam menjadi bergerak, perubahan tempat dan bentuk, adalah pengertian dari?",
    options: ["Gaya", "Perpindahan", "Jarak", "Percepatan", "Daya"],
    correctIndex: 0,
    explanation: "Gaya adalah penyebab perubahan keadaan diam menjadi bergerak atau perubahan bentuk.",
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
    explanation: "Resultante gaya adalah satu gaya pengganti yang kerja setara dengan gabungan beberapa gaya.",
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
    explanation: "Resultan gaya dapat ditentukan secara analitis dengan perhitungan atau secara grafis dengan gambar.",
  ),
  QuizQuestion(
    id: "q28",
    text: "Jika R = √(P1² + P2²), P1=3 Ton, P2=4 Ton. Berapakah Resultan gayanya (R)?",
    options: ["5 Ton", "6 Ton", "7 Ton", "8 Ton", "9 Ton"],
    correctIndex: 0,
    explanation: "R = akar(3 kuadrat ditambah 4 kuadrat) = 5 ton, sesuai segitiga siku-siku 3-4-5.",
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
    explanation: "Gaya dapat dipindahkan sepanjang garis kerjanya tanpa mengubah pengaruhnya pada benda kaku.",
  ),
  QuizQuestion(
    id: "q30",
    text: "Jika pada suatu titik tangkap gaya bekerja tiga gaya horizontal segaris: P1 = 80 kg ke arah kanan, P2 = 60 kg ke arah kiri, dan P3 = 20 kg ke arah kiri, berapakah besar Resultan gaya (R) dan keadaannya?",
    options: [
      "0 kg (Gaya Seimbang)",
      "80 kg (Ke Kiri)",
      "80 kg (Ke Kanan)",
      "160 Kg (Ke Kiri)",
      "160 Kg (Ke Kanan)"
    ],
    correctIndex: 0,
    explanation: "R = P1 - P2 - P3 = 80 - 60 - 20 = 0 kg (Kondisi seimbang).",
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
    explanation: "Momen gaya adalah hasil perkalian gaya dengan jarak terhadap titik tertentu.",
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
    explanation: "Besar momen sangat dipengaruhi jarak atau lengan gaya, selain besar gayanya.",
  ),
  QuizQuestion(
    id: "q33",
    text: "Jika diketahui besar gaya F=200 Kg dengan jarak 2 m, maka berapakah besar momen gaya yang terjadi?",
    options: ["400 Kg.m", "400 Kg", "400 m", "400", "400 m.Kg"],
    correctIndex: 0,
    explanation: "Momen = F dikali L = 200 kg dikali 2 m = 400 kg.m.",
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
    explanation: "Meteran adalah alat ukur, bukan peralatan menggambar teknik seperti mistar, jangka, dan meja gambar.",
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
    explanation: "Ukuran gambar bukan kolom wajib kotak nama; yang dicantumkan antara lain judul, skala, dan tanggal.",
  ),
  QuizQuestion(
    id: "q36",
    text: "Pensil dengan kode HB termasuk dalam standard kekerasan?",
    options: ["Sedang", "Keras sedang", "Keras", "Lunak Sedang", "Lunak"],
    correctIndex: 0,
    explanation: "Pensil HB memiliki tingkat kekerasan sedang, di antara H yang keras dan B yang lunak.",
  ),
  QuizQuestion(
    id: "q37",
    text: "Dalam Gambar teknik, ukuran kertas berdasarkan standar ISO. Perbandingan A3 terhadap A4 adalah?",
    options: [
      "A3 sama dengan 2 x A4",
      "A3 sama dengan 1/2 A2",
      "A3 sama dengan 1/2 A1",
      "A3 sama dengan 1/2 A0",
      "A3 sama dengan 4 x A4"
    ],
    correctIndex: 0,
    explanation: "A3 adalah dua kali A4, sehingga perbandingannya A3 sama dengan 2 x A4.",
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
    explanation: "A4 adalah setengah dari A3, yaitu 297 x 210 mm.",
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
    explanation: "Garis putus titik untuk potongan memiliki ketebalan sekitar 1/3 dari garis gambar.",
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
    explanation: "Garis dengan ketebalan 1/4 garis gambar disebut garis tipis.",
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
    explanation: "Garis tipis 0,20-0,25 mm dipakai untuk garis AS.",
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
    explanation: "Garis zig zag dipakai untuk memperpendek gambar bagian yang panjangnya berlebih.",
  ),
  QuizQuestion(
    id: "q43",
    text: "Pada sepasang mistar segitiga gambar teknik standar (segitiga 45°-45°-90° dan segitiga 30°-60°-90°), berapakah sudut lancip terkecil yang dimiliki masing-masing mistar?",
    options: [
      "30° dan 45°",
      "15° dan 45°",
      "15° dan 75°",
      "30° dan 60°",
      "45° dan 60°"
    ],
    correctIndex: 0,
    explanation: "Mistar 45-45-90 memiliki sudut lancip 45 derajat, sedangkan mistar 30-60-90 memiliki sudut lancip 30 derajat.",
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
    explanation: "Sepasang mistar standar terdiri dari segitiga 90-45-45 dan segitiga 90-60-30.",
  ),
  QuizQuestion(
    id: "q45",
    text: "Dalam sebuah penggaris segitiga terdapat 3 buah sudut, total jumlah ketiga sudut tersebut adalah?",
    options: ["180°", "120°", "150°", "220°", "160°"],
    correctIndex: 0,
    explanation: "Jumlah ketiga sudut segitiga selalu 180 derajat.",
  ),
  QuizQuestion(
    id: "q46",
    text: "Untuk menggambar ukuran sudut di kertas gambar secara manual, dipakai alat gambar?",
    options: ["Busur derajat", "Pensil", "Pena", "Rapido", "Segitiga siku"],
    correctIndex: 0,
    explanation: "Busur derajat dipakai untuk mengukur dan menggambar ukuran sudut secara manual.",
  ),
  QuizQuestion(
    id: "q47",
    text: "Dalam simbol gambar teknik bangunan, arsiran garis miring sejajar berselang-seling biasanya digunakan untuk melambangkan pasangan?",
    options: [
      "Batu bata merah",
      "Batu kali bulat",
      "Pintu dua daun",
      "Keramik lantai",
      "Pintu geser"
    ],
    correctIndex: 0,
    explanation: "Arsiran garis miring sejajar berselang-seling melambangkan pasangan batu bata merah.",
  ),
  QuizQuestion(
    id: "q48",
    text: "Dalam gambar denah arsitektur, simbol seperempat lingkaran dengan garis lurus bukaan digunakan untuk menunjukkan?",
    options: [
      "Pintu satu daun dan arah bukaannya",
      "Pintu dua daun",
      "Jendela kaca mati",
      "Pintu geser",
      "Dua pintu lipat"
    ],
    correctIndex: 0,
    explanation: "Simbol seperempat lingkaran dengan garis lurus bukaan menunjukkan pintu satu daun beserta arah bukaannya.",
  ),
  QuizQuestion(
    id: "q49",
    text: "Sebidang tanah persegi 10m x 20m. Jika digambar skala 1:100, panjang garis tanah tersebut menjadi?",
    options: ["20 cm", "20 mm", "10 mm", "10 cm", "120 mm"],
    correctIndex: 0,
    explanation: "Skala 1:100 membuat panjang 20 m menjadi 20 cm pada gambar.",
  ),
  QuizQuestion(
    id: "q50",
    text: "Lebar pintu 80 cm, jika skala gambar 1:50, maka lebar pintu yang digambarkan adalah?",
    options: ["1,6 cm", "8 mm", "40 cm", "16 mm", "16 cm"],
    correctIndex: 0,
    explanation: "Lebar 80 cm dengan skala 1:50 menjadi 1,6 cm pada gambar.",
  ),

  // ==========================================
  // 📸 SOAL BERGAMBAR (MATERI CP1 & CP2)
  // ==========================================
  QuizQuestion(
    id: "img_q1",
    text: "Perhatikan gambar berikut. Sketsa hierarki jaringan jalan tersebut menunjukkan pembagian fungsi dari jalan lokal, kolektor, hingga jalan primer tertinggi yaitu?",
    options: [
      "Jalan Arteri",
      "Jalan Tol Layang",
      "Jalan Lingkungan Sempit",
      "Jalan Setapak",
      "Jalan Khusus Kereta"
    ],
    correctIndex: 0,
    explanation: "Sketsa hierarki jalan menunjukkan jalan arteri sebagai jalan primer tertinggi dalam jaringan.",
    imagePath: "assets/gambar/cp2/Jalan/Gambar 1 Sketsa Hierarki Jalan.png",
  ),
  QuizQuestion(
    id: "img_q2",
    text: "Perhatikan gambar bagian-bagian jalan berikut. Pembagian area ruang jalan yang terdiri dari bagian manfaat, milik, dan pengawasan disingkat menjadi?",
    options: [
      "Damaja, Damija, dan Dawasja",
      "Damasja, Damika, dan Danasja",
      "Dapem, Damil, dan Dawas",
      "Damawa, Damaja, dan Dawija",
      "Damina, Damika, dan Dawasja"
    ],
    correctIndex: 0,
    explanation: "Damaja, Damija, dan Dawasja adalah singkatan ruang manfaat, milik, dan pengawasan jalan.",
    imagePath: "assets/gambar/cp2/Jalan/Gambar 3 Tipikal Damaja, Damija dan Dawasja.png",
  ),
  QuizQuestion(
    id: "img_q3",
    text: "Perhatikan gambar tikungan jalan berikut. Bentuk geometri lengkung horizontal tikungan tunggal berbentuk busur lingkaran sempurna pada gambar adalah jenis tikungan?",
    options: [
      "Full Circle (FC)",
      "Spiral - Circle - Spiral (SCS)",
      "Spiral - Spiral (SS)",
      "Tikungan Siku 90°",
      "Tikungan U-Turn"
    ],
    correctIndex: 0,
    explanation: "Tikungan Full Circle berbentuk busur lingkaran sempurna tanpa lengkung peralihan.",
    imagePath: "assets/gambar/cp2/Jalan/Gambar 7 tikungan Full Circle (FC).jpeg",
  ),
  QuizQuestion(
    id: "img_q4",
    text: "Perhatikan gambar tikungan jalan berikut. Tikungan yang menghubungkan garis lurus dengan lingkaran melalui lengkung peralihan di kedua sisinya pada gambar disebut?",
    options: [
      "Spiral - Circle - Spiral (SCS)",
      "Full Circle (FC)",
      "Spiral - Spiral (SS)",
      "Tikungan Lurus",
      "Tikungan Balik Arah"
    ],
    correctIndex: 0,
    explanation: "Tikungan SCS memiliki lengkung peralihan spiral di kedua ujung busur lingkaran.",
    imagePath: "assets/gambar/cp2/Jalan/Gambar 8 tikungan Spiral - Circle Spiral.jpeg",
  ),
  QuizQuestion(
    id: "img_q5",
    text: "Perhatikan gambar berikut. Garis kelurusan jalan dalam arah vertikal yang memuat tanjakan dan turunan (kelandaian) disebut alinyemen?",
    options: [
      "Alinyemen Vertikal",
      "Alinyemen Horisontal",
      "Alinyemen Diagonal",
      "Profil Melintang",
      "Potongan Denah"
    ],
    correctIndex: 0,
    explanation: "Alinyemen vertikal menggambarkan tanjakan dan turunan pada arah memanjang jalan.",
    imagePath: "assets/gambar/cp2/Jalan/Gambar 10 Alinyemen Vertikal.jpeg",
  ),
  QuizQuestion(
    id: "img_q6",
    text: "Perhatikan gambar struktur jembatan berikut. Komponen pengaman tepi yang berfungsi menjaga keselamatan pejalan kaki di atas jembatan pada gambar adalah?",
    options: [
      "Sandaran dan Tiang Sandaran (Railing)",
      "Gelagar Memanjang Utama",
      "Abutment (Kepala Jembatan)",
      "Oprit Jembatan",
      "Pondasi Sumuran"
    ],
    correctIndex: 0,
    explanation: "Sandaran dan tiang sandaran menjaga keselamatan pejalan kaki di tepi jembatan.",
    imagePath: "assets/gambar/cp2/Jembatan/Gambar 21 Sandaran dan Tiang Sandaran.jpeg",
  ),
  QuizQuestion(
    id: "img_q7",
    text: "Perhatikan gambar berikut. Pembatas peninggi tepi jalan/trotoar (kerb) pada jembatan yang berfungsi mengarahkan air dan membatasi roda kendaraan adalah?",
    options: [
      "Kerb Jembatan",
      "Tiang Pancang",
      "Gelagar Melintang",
      "Elastomer Bantalan",
      "Plat Injak"
    ],
    correctIndex: 0,
    explanation: "Kerb membatasi tepi trotoar sekaligus mengarahkan air permukaan jembatan.",
    imagePath: "assets/gambar/cp2/Jembatan/Gambar 22 Kerb.jpeg",
  ),
  QuizQuestion(
    id: "img_q8",
    text: "Perhatikan gambar jembatan berikut. Struktur bawah jembatan yang terletak pada pangkal/ujung jembatan dan bersentuhan langsung dengan tanah timbunan oprit adalah?",
    options: [
      "Abutment (Pangkal Jembatan)",
      "Pilar Tengah (Pier)",
      "Gelagar Induk",
      "Lantai Kendaraan",
      "Expansion Joint"
    ],
    correctIndex: 0,
    explanation: "Abutment terletak di pangkal jembatan dan bersentuhan langsung dengan tanah timbunan oprit.",
    imagePath: "assets/gambar/cp2/Jembatan/Gambar 27 Abutment (Pangkal Jembatan).jpeg",
  ),
  QuizQuestion(
    id: "img_q9",
    text: "Perhatikan gambar berikut. Bangunan bawah jembatan yang terletak di antara dua abutment dan membagi bentang jembatan di tengah sungai/lembah adalah?",
    options: [
      "Pilar Jembatan (Pier)",
      "Talud Pelindung",
      "Sandaran Trotoar",
      "Bahu Jalan Tepi",
      "Plat Injak Oprit"
    ],
    correctIndex: 0,
    explanation: "Pilar berada di antara abutment dan membagi bentang jembatan di atas sungai atau lembah.",
    imagePath: "assets/gambar/cp2/Jembatan/Gambar 28 Pilar Jembatan.jpeg",
  ),
  QuizQuestion(
    id: "img_q10",
    text: "Perhatikan gambar lapisan perkerasan jalan lentur berikut. Lapisan struktur jalan yang paling atas dan langsung menerima gesekan serta beban roda kendaraan adalah?",
    options: [
      "Lapis Permukaan (Surface Course)",
      "Lapis Pondasi Atas (Base Course)",
      "Lapis Pondasi Bawah (Subbase Course)",
      "Tanah Dasar Asli (Subgrade)",
      "Lapisan Geotekstil"
    ],
    correctIndex: 0,
    explanation: "Lapis permukaan adalah lapisan teratas yang menerima gesekan dan beban roda kendaraan.",
    imagePath: "assets/gambar/cp2/Perkerasan_Jalan/Gambar 19 bagian perkerasan jalan.jpeg",
  ),
  QuizQuestion(
    id: "img_q11",
    text: "Perhatikan gambar berikut. Saluran penampung di sisi jalan yang berfungsi membuang air hujan agar badan jalan tidak tergenang atau rusak adalah?",
    options: [
      "Saluran Drainase Jalan",
      "Median Jalan Hijau",
      "Zebra Cross",
      "Pulau Lalu Lintas",
      "Pagar Pengaman Guardrail"
    ],
    correctIndex: 0,
    explanation: "Saluran drainase membuang air hujan agar badan jalan tidak tergenang.",
    imagePath: "assets/gambar/cp2/Umum/Gambar 30 saluran drainase.jpeg",
  ),
  QuizQuestion(
    id: "img_q12",
    text: "Perhatikan gambar pemodelan bangunan berikut. Tampilan visual 3D yang menampilkan keutuhan elemen arsitektur, struktur, dan pembagian ruang secara transparan/aksonometrik dibuat menggunakan konsep?",
    options: [
      "BIM (Building Information Modelling)",
      "Manual Sketching Pensil",
      "Fotografi Satelit Udara",
      "Denah Garis 2D Konvensional",
      "Peta Kontur Topografi"
    ],
    correctIndex: 0,
    explanation: "BIM menghasilkan model 3D yang menggabungkan elemen arsitektur, struktur, dan informasi ruang.",
    imagePath: "assets/gambar/cp1/02_AXONO_GENERAL.jpg",
  ),
];