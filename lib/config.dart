class AppConfig {
  static const String githubOwner = 'Aurelloyell';
  static const String githubRepo = 'FreeLoader';
  static const String branch = 'main'; 
  static const String basePath = 'assets/cp';

  static String getApiUrl(String cpFolder, String subFolder) {
    // Trim spaces just in case
    final path = '$basePath/${cpFolder.trim()}/${subFolder.trim()}';
    return 'https://api.github.com/repos/$githubOwner/$githubRepo/contents/$path';
  }

  // UPDATED: Better encoding for folders with spaces (e.g., "Arsitektur Tropis")
  static String getCdnUrl(String fullPath) {
    // Split path by '/', encode each part (space -> %20), then join back
    final segments = fullPath.split('/');
    final encodedSegments = segments.map((s) => Uri.encodeComponent(s)).toList();
    final encodedPath = encodedSegments.join('/');
    return 'https://cdn.jsdelivr.net/gh/$githubOwner/$githubRepo@$branch/$encodedPath';
  }
}