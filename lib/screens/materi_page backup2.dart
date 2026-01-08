import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../curriculum_data.dart';

// Simple logging helper to replace print statements
void _log(String message) {
  debugPrint('[MateriPage] $message');
}

class MateriPage extends StatefulWidget {
  final CPModule cpModule;

  const MateriPage({super.key, required this.cpModule});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  // CONFIGURATION
  // 1. Your GitHub Username
  final String _githubOwner = "Aurelloyell"; 
  // 2. Your Repository Name
  final String _githubRepo = "FreeLoader"; 
  // 3. Raw URL for text files (Note the 'main/assets/cp' part)
  final String _rawBaseUrl = "https://raw.githubusercontent.com/Aurelloyell/FreeLoader/main/assets/cp";

  // STATE: Tracks where models are saved on the phone
  // Key = SubChapter Folder Name, Value = List of local file paths
  final Map<String, List<String>> _downloadedModels = {};
  
  // STATE: Tracks which chapters are currently downloading
  final Set<String> _loadingSubChapters = {};

  @override
  void initState() {
    super.initState();
    // OPTIONAL: Automatically load existing offline files when page opens
    _loadOfflineFiles(); 
  }

  // Check phone storage for files we already downloaded previously
  Future<void> _loadOfflineFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    
    for (var subChapter in widget.cpModule.subChapters) {
      final String localDirName = "${widget.cpModule.folderName}_${subChapter.folderName}".replaceAll(' ', '_');
      final Directory localDir = Directory("${directory.path}/$localDirName");

      if (await localDir.exists()) {
        final List<FileSystemEntity> files = localDir.listSync();
        List<String> validModels = [];
        for (var file in files) {
          if (file.path.endsWith('.glb')) {
            validModels.add(file.path);
          }
        }
        if (mounted && validModels.isNotEmpty) {
          setState(() {
            _downloadedModels[subChapter.folderName] = validModels;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cpModule.title, style: const TextStyle(fontSize: 16)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.cpModule.subChapters.length,
        itemBuilder: (context, index) {
          final subChapter = widget.cpModule.subChapters[index];
          return _buildSubChapterCard(subChapter);
        },
      ),
    );
  }

  Widget _buildSubChapterCard(SubChapter subChapter) {
    final bool isLoading = _loadingSubChapters.contains(subChapter.folderName);
    final List<String> models = _downloadedModels[subChapter.folderName] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subChapter.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                // Sync Button
                IconButton(
                  icon: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(models.isEmpty ? Icons.cloud_download_outlined : Icons.sync, color: Colors.blueGrey),
                  tooltip: "Sync / Download",
                  onPressed: isLoading 
                    ? null 
                    : () => _syncModelsForChapter(widget.cpModule.folderName, subChapter.folderName),
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. TEXT EXPLANATION
                _buildTextSection(subChapter),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // 3. 3D / AR CONTENT
                Text(
                  "Visualisasi AR (${models.length} Model)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),

                if (models.isEmpty && !isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_download_outlined, size: 40, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          const Text("Tekan tombol Sync di atas untuk mengunduh.", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else 
                  ...models.map((path) => _buildARViewer(path)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(SubChapter subChapter) {
    return FutureBuilder<String>(
      future: _fetchParagraph(widget.cpModule.folderName, subChapter.folderName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: LinearProgressIndicator(minHeight: 2),
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
            child: Text("Gagal memuat teks.", style: TextStyle(color: Colors.red[800])),
          );
        } else {
          return Text(
            snapshot.data ?? "Tidak ada deskripsi.",
            style: const TextStyle(fontSize: 14, height: 1.6),
            textAlign: TextAlign.justify,
          );
        }
      },
    );
  }

  Widget _buildARViewer(String localPath) {
    final fileName = localPath.split('/').last;
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("File: $fileName", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ModelViewer(
                src: "file://$localPath", // Important: Load from local storage
                alt: "3D Model",
                ar: true,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.white,
                loading: Loading.eager,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.check_circle, size: 14, color: Colors.green[400]),
              const SizedBox(width: 4),
              Text("Offline Ready", style: TextStyle(fontSize: 12, color: Colors.green[600])),
            ],
          )
        ],
      ),
    );
  }

  // --- LOGIC SECTION ---

  Future<String> _fetchParagraph(String cpFolder, String subFolder) async {
    // Construct URL for text
    String url = "$_rawBaseUrl/$cpFolder/$subFolder/paragraph.txt";
    var uri = Uri.parse(Uri.encodeFull(url));

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      }
      return "Deskripsi belum tersedia di server.";
    } catch (e) {
      return "Gagal memuat teks (Cek koneksi).";
    }
  }

  Future<void> _syncModelsForChapter(String cpFolder, String subFolder) async {
    setState(() => _loadingSubChapters.add(subFolder));
    
    // We use GitHub API to look inside the folder
    String apiUrl = "https://api.github.com/repos/$_githubOwner/$_githubRepo/contents/assets/cp/$cpFolder/$subFolder";
    
    try {
      // 1. GET FILE LIST FROM GITHUB
      _log("Fetching list from: $apiUrl");
      final response = await http.get(Uri.parse(Uri.encodeFull(apiUrl)));
      
      if (response.statusCode != 200) {
        if (mounted) _showMessage("Folder tidak ditemukan di server GitHub.");
        return;
      }

      final List<dynamic> remoteFiles = json.decode(response.body);
      
      // Filter for ANY .glb file
      final List<Map<String, dynamic>> remoteModels = remoteFiles.where((file) {
        final name = file['name'].toString().toLowerCase();
        return name.endsWith('.glb');
      }).map((e) => e as Map<String, dynamic>).toList();

      if (remoteModels.isEmpty) {
        if (mounted) _showMessage("Tidak ada model 3D di folder ini.");
      }

      // 2. PREPARE LOCAL FOLDER
      final directory = await getApplicationDocumentsDirectory();
      // Unique folder name for this chapter
      final String localDirName = "${cpFolder}_$subFolder".replaceAll(' ', '_');
      final Directory localDir = Directory("${directory.path}/$localDirName");
      
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }

      List<String> finalPaths = [];
      Set<String> remoteFileNames = {};

      // 3. DOWNLOAD NEW / UPDATE CHANGED FILES
      for (var remoteModel in remoteModels) {
        String fileName = remoteModel['name'];
        String downloadUrl = remoteModel['download_url'];
        int remoteSize = remoteModel['size'];
        
        remoteFileNames.add(fileName);
        File localFile = File("${localDir.path}/$fileName");

        // Logic: Download if missing OR if size is different (implies update)
        bool shouldDownload = true;
        if (await localFile.exists()) {
          int localSize = await localFile.length();
          if (localSize == remoteSize) {
            shouldDownload = false; // Already have exact file
          }
        }

        if (shouldDownload) {
          _log("Downloading $fileName...");
          final modelData = await http.get(Uri.parse(downloadUrl));
          if (modelData.statusCode == 200) {
            await localFile.writeAsBytes(modelData.bodyBytes);
          }
        }
        finalPaths.add(localFile.path);
      }

      // 4. CLEANUP: DELETE FILES THAT WERE REMOVED FROM GITHUB
      // This keeps storage clean. If you delete 'house.glb' from GitHub, it deletes from phone too.
      if (await localDir.exists()) {
        final List<FileSystemEntity> existingLocalFiles = localDir.listSync();
        for (var entity in existingLocalFiles) {
          if (entity is File) {
            String name = entity.path.split('/').last;
            if (name.endsWith('.glb') && !remoteFileNames.contains(name)) {
              _log("Deleting obsolete model: $name");
              await entity.delete();
            }
          }
        }
      }

      // 5. UPDATE UI
      if (mounted) {
        setState(() {
          _downloadedModels[subFolder] = finalPaths;
        });
        _showMessage("Sync selesai! ${finalPaths.length} model siap.");
      }

    } catch (e) {
      _log("Sync Error: $e");
      if (mounted) _showMessage("Gagal sinkronisasi: $e");
    } finally {
      if (mounted) {
        setState(() => _loadingSubChapters.remove(subFolder));
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}