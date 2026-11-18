import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../config.dart';
import '../curriculum_data.dart';

class ChapterDetailPage extends StatefulWidget {
  final String cpFolder;
  final SubChapter subChapter;

  const ChapterDetailPage({
    super.key,
    required this.cpFolder,
    required this.subChapter,
  });

  @override
  State<ChapterDetailPage> createState() => _ChapterDetailPageState();
}

class _ChapterDetailPageState extends State<ChapterDetailPage> {
  String? _textContent;
  List<String> _modelUrls = [];
  List<String> _debugFileNames = [];
  int _currentModelIndex = 0;
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChapterContent();
  }

  Future<void> _fetchChapterContent() async {
    try {
      final apiUrl = AppConfig.getApiUrl(widget.cpFolder, widget.subChapter.folderName);
      debugPrint("Fetching: $apiUrl");
      
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> files = json.decode(response.body);
        
        String? foundTextUrl;
        List<String> foundModels = [];
        List<String> fileNames = [];

        for (var file in files) {
          final String name = file['name'].toString();
          final String path = file['path'];
          final String lowerName = name.toLowerCase();

          fileNames.add(name);

          if (lowerName.endsWith('.txt')) {
            foundTextUrl = file['download_url']; 
          } else if (lowerName.endsWith('.glb') || lowerName.endsWith('.gltf')) {
            foundModels.add(AppConfig.getCdnUrl(path));
          }
        }

        // Fetch Text Content
        String? textBody;
        if (foundTextUrl != null) {
          final textResponse = await http.get(Uri.parse(foundTextUrl));
          if (textResponse.statusCode == 200) {
            textBody = textResponse.body;
          }
        }

        if (mounted) {
          setState(() {
            _textContent = textBody ?? "No text description available.";
            _modelUrls = foundModels;
            _debugFileNames = fileNames;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Folder not found (${response.statusCode}). Check folder name: ${widget.subChapter.folderName}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subChapter.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 20),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Kembali',
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.home_rounded, color: Color(0xFF0F172A), size: 20),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                tooltip: 'Halaman Utama',
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return _buildDesktopLayout();
                    } else {
                      return _buildMobileLayout();
                    }
                  },
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text("Connection Error", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(_error ?? "Unknown error", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchChapterContent();
              },
              child: const Text("Retry"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildTextContent(),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            color: Colors.grey[100],
            child: _build3DViewer(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 400,
            child: Container(
              color: Colors.grey[100],
              child: _build3DViewer(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildTextContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Materi Pembelajaran",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 20),
        Text(
          _textContent ?? "",
          style: const TextStyle(fontSize: 16, height: 1.8),
          textAlign: TextAlign.justify,
        ),
        const Divider(height: 40),

        if (kDebugMode)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Info debug (file ditemukan):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),

                if (_debugFileNames.isEmpty)
                  const Text("Tidak ada file di folder ini.", style: TextStyle(fontSize: 12, color: Colors.red))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _debugFileNames.map((f) => Text("- $f", style: const TextStyle(fontSize: 12))).toList(),
                  ),

                const SizedBox(height: 8),
                if (_modelUrls.isEmpty)
                  const Text("Model GLB/GLTF tidak ditemukan.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red))
                else
                  Text("${_modelUrls.length} model termuat.", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _build3DViewer() {
    if (_modelUrls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.threed_rotation, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text("No 3D Model Available", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final currentUrl = _modelUrls[_currentModelIndex];
    final bool hasMultiple = _modelUrls.length > 1;

    return Stack(
      children: [
        ModelViewer(
          key: ValueKey(currentUrl),
          src: currentUrl,
          alt: "3D Model",
          ar: false,
          autoRotate: true,
          cameraControls: true,
          backgroundColor: Colors.transparent,
          // loading: Loading.eager, // Removed to prevent potential enum conflict
        ),
        
        if (hasMultiple)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Button
                FloatingActionButton.small(
                  heroTag: "prev_btn",
                  onPressed: _currentModelIndex > 0 
                      ? () => setState(() => _currentModelIndex--) 
                      : null,
                  backgroundColor: _currentModelIndex > 0 ? Colors.white : Colors.grey,
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
                
                const SizedBox(width: 20),
                
                // Counter Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "Model ${_currentModelIndex + 1} / ${_modelUrls.length}", 
                    style: const TextStyle(color: Colors.white)
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Next Button
                FloatingActionButton.small(
                  heroTag: "next_btn",
                  onPressed: _currentModelIndex < _modelUrls.length - 1 
                      ? () => setState(() => _currentModelIndex++) 
                      : null,
                  backgroundColor: _currentModelIndex < _modelUrls.length - 1 ? Colors.white : Colors.grey,
                  child: const Icon(Icons.arrow_forward, color: Colors.black87),
                ),
              ],
            ),
          ),
      ],
    );
  }
}