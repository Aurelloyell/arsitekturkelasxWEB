import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../curriculum_data.dart';

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
  
  // STATE: Tracks where models are saved on the phone
  // Key = SubChapter Folder Name, Value = List of local file paths
  Map<String, List<String>> _downloadedModels = {};
  
  // STATE: Tracks if we have offline text available
  // Key = SubChapter Folder Name, Value = Boolean
  Map<String, bool> _hasOfflineText = {};
  
  // STATE: Tracks which chapters are currently downloading/syncing
  Set<String> _loadingSubChapters = {};

  @override
  void initState() {
    super.initState();
    // Automatically scan local storage when page opens
    _loadOfflineFiles();
  }

  // 1. SCAN LOCAL STORAGE ON STARTUP
  Future<void> _loadOfflineFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    
    for (var subChapter in widget.cpModule.subChapters) {
      // Create a unique folder name for this specific chapter
      final String localDirName = "${widget.cpModule.folderName}_${subChapter.folderName}".replaceAll(' ', '_');
      final Directory localDir = Directory("${directory.path}/$localDirName");

      if (await localDir.exists()) {
        final List<FileSystemEntity> files = localDir.listSync();
        
        List<String> validModels = [];
        bool textExists = false;

        for (var file in files) {
          String path = file.path.toLowerCase();
          if (path.endsWith('.glb')) {
            validModels.add(file.path);
          } else if (path.endsWith('.txt')) {
            textExists = true;
          }
        }

        if (mounted) {
          setState(() {
            if (validModels.isNotEmpty) {
              _downloadedModels[subChapter.folderName] = validModels;
            }
            if (textExists) {
              _hasOfflineText[subChapter.folderName] = true;
            }
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
    final bool hasText = _hasOfflineText[subChapter.folderName] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
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
                // SMART SYNC BUTTON
                IconButton(
                  icon: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(
                        (models.isNotEmpty && hasText) ? Icons.sync : Icons.cloud_download_outlined, 
                        color: (models.isNotEmpty && hasText) ? Colors.blueGrey : Colors.blueAccent
                      ),
                  tooltip: "Sync Text & Models",
                  onPressed: isLoading 
                    ? null 
                    : () => _syncContentForChapter(widget.cpModule.folderName, subChapter.folderName),
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TEXT SECTION (Reads from Local)
                const Text("Penjelasan Materi:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildOfflineTextReader(subChapter),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // AR / 3D SECTION
                Text(
                  "Visualisasi AR (${models.length} Model)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),

                if (models.isEmpty && !isLoading)
                  _buildEmptyState()
                else 
                  ...models.map((path) => _buildARViewer(path)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            Icon(Icons.download_for_offline_outlined, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 8),
            const Text(
              "Data belum diunduh.\nTekan tombol Sync di pojok kanan atas.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // 2. READ TEXT FROM LOCAL FILE
  Widget _buildOfflineTextReader(SubChapter subChapter) {
    return FutureBuilder<String?>(
      future: _readLocalText(widget.cpModule.folderName, subChapter.folderName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(minHeight: 2);
        } else if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!,
            style: const TextStyle(fontSize: 14, height: 1.6),
            textAlign: TextAlign.justify,
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50], 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3))
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text("Materi offline belum tersedia. Silahkan Sync.", style: TextStyle(fontSize: 12))),
              ],
            ),
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
          Row(
            children: [
              const Icon(Icons.check_circle, size: 12, color: Colors.green),
              const SizedBox(width: 4),
              Text("Offline Ready: $fileName", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ModelViewer(
                src: "file://$localPath", // LOAD FROM LOCAL STORAGE
                alt: "3D Model",
                ar: true,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.white,
                loading: Loading.eager,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC ENGINE ---

  // Helper to read local text file (Prefers paragraph.txt, but will read first available txt)
  // FIXED: No variable shadowing here
  Future<String?> _readLocalText(String cpFolder, String subFolder) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String localDirName = "${cpFolder}_$subFolder".replaceAll(' ', '_');
      final Directory localDir = Directory("${directory.path}/$localDirName");

      if (!await localDir.exists()) return null;

      final files = localDir.listSync();
      File? targetFile;

      // Priority 1: Search specifically for "paragraph.txt"
      try {
        final entity = files.firstWhere((f) => f.path.endsWith("paragraph.txt"));
        if (entity is File) targetFile = entity;
      } catch (_) {
        // Priority 2: If paragraph.txt not found, find ANY .txt file
        try {
          final entity = files.firstWhere((f) => f.path.endsWith(".txt"));
          if (entity is File) targetFile = entity;
        } catch (_) {
          // No text file found at all
          return null;
        }
      }

      if (targetFile != null) {
        return await targetFile.readAsString();
      }
    } catch (e) {
      print("Read error: $e");
    }
    return null;
  }

  // 3. THE SMART SYNC ENGINE (HANDLES TXT AND GLB)
  Future<void> _syncContentForChapter(String cpFolder, String subFolder) async {
    setState(() => _loadingSubChapters.add(subFolder));
    
    // GitHub API URL to list files
    String apiUrl = "https://api.github.com/repos/$_githubOwner/$_githubRepo/contents/assets/cp/$cpFolder/$subFolder";
    
    try {
      print("Syncing from: $apiUrl");
      final response = await http.get(Uri.parse(Uri.encodeFull(apiUrl)));
      
      if (response.statusCode != 200) {
        if (mounted) _showMessage("Folder tidak ditemukan di server.");
        return;
      }

      final List<dynamic> remoteFiles = json.decode(response.body);
      
      // Filter for BOTH .glb AND .txt
      final List<Map<String, dynamic>> targetFiles = remoteFiles.where((file) {
        final name = file['name'].toString().toLowerCase();
        return name.endsWith('.glb') || name.endsWith('.txt');
      }).map((e) => e as Map<String, dynamic>).toList();

      if (targetFiles.isEmpty) {
        if (mounted) _showMessage("Tidak ada file materi (txt/glb) ditemukan.");
      }

      // Prepare Local Directory
      final directory = await getApplicationDocumentsDirectory();
      final String localDirName = "${cpFolder}_$subFolder".replaceAll(' ', '_');
      final Directory localDir = Directory("${directory.path}/$localDirName");
      
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }

      List<String> currentModelPaths = [];
      Set<String> remoteFileNames = {};
      bool textDownloaded = false;

      // DOWNLOAD LOOP
      for (var remoteFile in targetFiles) {
        String fileName = remoteFile['name'];
        String downloadUrl = remoteFile['download_url'];
        int remoteSize = remoteFile['size'];
        
        remoteFileNames.add(fileName);
        File localFile = File("${localDir.path}/$fileName");

        // Logic: Download if missing OR if size changed (Update)
        bool shouldDownload = true;
        if (await localFile.exists()) {
          int localSize = await localFile.length();
          if (localSize == remoteSize) {
            shouldDownload = false;
            print("Up to date: $fileName");
          }
        }

        if (shouldDownload) {
          print("Downloading $fileName...");
          final fileData = await http.get(Uri.parse(downloadUrl));
          if (fileData.statusCode == 200) {
            await localFile.writeAsBytes(fileData.bodyBytes);
          }
        }

        // Track what we have
        if (fileName.toLowerCase().endsWith('.glb')) {
          currentModelPaths.add(localFile.path);
        } else if (fileName.toLowerCase().endsWith('.txt')) {
          textDownloaded = true;
        }
      }

      // CLEANUP LOOP (Delete old files not on server)
      if (await localDir.exists()) {
        final List<FileSystemEntity> existingLocalFiles = localDir.listSync();
        for (var entity in existingLocalFiles) {
          if (entity is File) {
            String name = entity.path.split('/').last;
            // Only clean up relevant file types
            if ((name.endsWith('.glb') || name.endsWith('.txt')) && !remoteFileNames.contains(name)) {
              print("Deleting obsolete file: $name");
              await entity.delete();
            }
          }
        }
      }

      // UPDATE UI
      if (mounted) {
        setState(() {
          _downloadedModels[subFolder] = currentModelPaths;
          if (textDownloaded) _hasOfflineText[subFolder] = true;
        });
        _showMessage("Sync Berhasil! Materi Tersimpan Offline.");
      }

    } catch (e) {
      print("Sync Error: $e");
      if (mounted) _showMessage("Gagal sinkronisasi: $e");
    } finally {
      if (mounted) {
        setState(() => _loadingSubChapters.remove(subFolder));
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2)
      ),
    );
  }
}