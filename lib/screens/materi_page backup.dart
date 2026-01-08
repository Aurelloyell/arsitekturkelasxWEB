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
  final String _githubOwner = "Aurelloyell";
  final String _githubRepo = "FreeLoader";
  // The raw base URL is still needed for text, but we use API for models
  final String _rawBaseUrl = "https://raw.githubusercontent.com/Aurelloyell/FreeLoader/main/assets/cp";

  // State to track model paths per sub-chapter
  // Key: SubChapter Folder Name, Value: List of local file paths
  Map<String, List<String>> _downloadedModels = {};
  
  // Track loading state per sub-chapter
  Set<String> _loadingSubChapters = {};

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
          // 1. Header
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                // Sync Button
                IconButton(
                  icon: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync, color: Colors.blueGrey),
                  tooltip: "Sync & Download 3D Models",
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
                // 2. Text Explanation
                _buildTextSection(subChapter),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // 3. Dynamic AR Section
                Text(
                  "Visualisasi AR / 3D (${models.length} Model)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),

                if (models.isEmpty && !isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(Icons.download_for_offline_outlined, size: 40, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text("Belum ada model yang diunduh."),
                          TextButton(
                            onPressed: () => _syncModelsForChapter(widget.cpModule.folderName, subChapter.folderName),
                            child: const Text("Unduh Semua Model"),
                          ),
                        ],
                      ),
                    ),
                  )
                else 
                  ...models.map((path) => _buildARViewer(path)).toList(),
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
          return const LinearProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Gagal memuat teks: ${snapshot.error}", style: const TextStyle(color: Colors.red));
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
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("File: $fileName", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ModelViewer(
                src: "file://$localPath", // Use the local file path
                alt: "3D Model",
                ar: true,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC SECTION ---

  Future<String> _fetchParagraph(String cpFolder, String subFolder) async {
    // 1. Construct URL for the text file
    String url = "$_rawBaseUrl/$cpFolder/$subFolder/paragraph.txt";
    var uri = Uri.parse(Uri.encodeFull(url));

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      }
      return "Deskripsi belum tersedia di server.";
    } catch (e) {
      return "Error koneksi internet.";
    }
  }

  Future<void> _syncModelsForChapter(String cpFolder, String subFolder) async {
    setState(() => _loadingSubChapters.add(subFolder));
    
    // API URL to list files in the directory
    // Example: https://api.github.com/repos/Aurelloyell/FreeLoader/contents/assets/cp/cp1.../Sub...
    String apiUrl = "https://api.github.com/repos/$_githubOwner/$_githubRepo/contents/assets/cp/$cpFolder/$subFolder";
    
    try {
      // 1. Fetch Remote File List
      print("Fetching list from: $apiUrl");
      final response = await http.get(Uri.parse(Uri.encodeFull(apiUrl)));
      
      if (response.statusCode != 200) {
        throw Exception("Failed to list files (${response.statusCode})");
      }

      final List<dynamic> remoteFiles = json.decode(response.body);
      
      // 2. Filter for .glb files
      final List<Map<String, dynamic>> remoteModels = remoteFiles.where((file) {
        final name = file['name'].toString().toLowerCase();
        return name.endsWith('.glb');
      }).map((e) => e as Map<String, dynamic>).toList();

      if (remoteModels.isEmpty) {
        if (mounted) _showMessage("Tidak ada model 3D ditemukan di folder ini.");
      }

      // 3. Prepare Local Directory
      final directory = await getApplicationDocumentsDirectory();
      final String localDirName = "${cpFolder}_$subFolder".replaceAll(' ', '_');
      final Directory localDir = Directory("${directory.path}/$localDirName");
      
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }

      List<String> finalPaths = [];
      Set<String> remoteFileNames = {};

      // 4. Download / Sync Loop
      for (var remoteModel in remoteModels) {
        String fileName = remoteModel['name'];
        String downloadUrl = remoteModel['download_url'];
        int remoteSize = remoteModel['size'];
        
        remoteFileNames.add(fileName);
        File localFile = File("${localDir.path}/$fileName");

        // Logic: Download if missing OR if size is significantly different
        bool shouldDownload = true;
        if (await localFile.exists()) {
          int localSize = await localFile.length();
          if (localSize == remoteSize) {
            shouldDownload = false;
            print("Skipping $fileName (already up to date)");
          }
        }

        if (shouldDownload) {
          print("Downloading $fileName...");
          final modelData = await http.get(Uri.parse(downloadUrl));
          if (modelData.statusCode == 200) {
            await localFile.writeAsBytes(modelData.bodyBytes);
          }
        }
        finalPaths.add(localFile.path);
      }

      // 5. Cleanup: Delete local files that are no longer on server
      final List<FileSystemEntity> existingLocalFiles = localDir.listSync();
      for (var entity in existingLocalFiles) {
        if (entity is File) {
          String name = entity.path.split('/').last;
          if (name.endsWith('.glb') && !remoteFileNames.contains(name)) {
            print("Deleting old model: $name");
            await entity.delete();
          }
        }
      }

      // 6. Update UI
      if (mounted) {
        setState(() {
          _downloadedModels[subFolder] = finalPaths;
        });
        _showMessage("Sync selesai! ${finalPaths.length} model siap.");
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}