class SubChapter {
  final String title;
  final String folderName; 

  SubChapter({required this.title, required this.folderName});
}

class CPModule {
  final String title;
  final String description;
  final String folderName; 
  final List<SubChapter> subChapters;

  CPModule({
    required this.title,
    required this.description,
    required this.folderName,
    required this.subChapters,
  });
}

final List<CPModule> curriculumData = [
  CPModule(
    title: "CP 1: Arsitektur Berdasarkan Sejarah",
    description: "The Roots: Memahami akar sejarah arsitektur klasik dan gotik.",
    folderName: "cp1-Arsitektur-Berdasarkan-Sejarah", 
    subChapters: [
      SubChapter(title: "1.1 Arsitektur Klasik (Yunani & Romawi)", folderName: "Arsitektur-Klasik"),
      SubChapter(title: "1.2 Arsitektur Gotik (Gothic)", folderName: "Arsitektur-Gotik"),
    ],
  ),
  CPModule(
    title: "CP 2: Arsitektur Era Revolusi Industri",
    description: "The Rebels: Perubahan radikal menuju gaya internasional.",
    folderName: "cp2-Arsitektur-Era-Revolusi-Industri", 
    subChapters: [
      SubChapter(title: "2.1 Arsitektur Modern", folderName: "Arsitektur-Modern"),
      SubChapter(title: "2.2 Brutalisme", folderName: "Brutalisme"),
    ],
  ),
  CPModule(
    title: "CP 3: Gaya Populer Kekinian",
    description: "Commercial Trends: Minimalis dan Industrial.",
    folderName: "cp3-Gaya-Populer-Kekinian", 
    subChapters: [
      SubChapter(title: "3.1 Arsitektur Minimalis", folderName: "Arsitektur-Minimalis"),
      SubChapter(title: "3.2 Arsitektur Industrial", folderName: "Arsitektur-Industrial"),
    ],
  ),
  CPModule(
    title: "CP 4: Arsitektur Berbasis Lingkungan",
    description: "Contextual: Merespon iklim dan keberlanjutan.",
    folderName: "cp4-Arsitektur-Berbasis-Lingkungan", 
    subChapters: [
      SubChapter(title: "4.1 Arsitektur Tropis", folderName: "Arsitektur-Tropis"),
      SubChapter(title: "4.2 Arsitektur Hijau", folderName: "Arsitektur-Hijau"),
    ],
  ),
  CPModule(
    title: "CP 5: Arsitektur Nusantara",
    description: "Local Wisdom: Kekayaan arsitektur lokal.",
    folderName: "cp5-Arsitektur-Nusantara", 
    subChapters: [
      SubChapter(title: "5.1 Arsitektur Vernakular", folderName: "Arsitektur-Vernakular"),
    ],
  ),
];