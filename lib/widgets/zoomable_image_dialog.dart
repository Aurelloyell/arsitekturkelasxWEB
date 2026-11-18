import 'package:flutter/material.dart';

/// Shows [imagePath] in a full-screen preview with pinch, scroll, and
/// double-tap zoom. Used by the JamHood host and player question screens.
Future<void> showZoomableImageDialog(
  BuildContext context, {
  required String imagePath,
  String? title,
}) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (_) => ZoomableImageDialog(imagePath: imagePath, title: title),
  );
}

class ZoomableImageDialog extends StatefulWidget {
  final String imagePath;
  final String? title;

  const ZoomableImageDialog({
    super.key,
    required this.imagePath,
    this.title,
  });

  @override
  State<ZoomableImageDialog> createState() => _ZoomableImageDialogState();
}

class _ZoomableImageDialogState extends State<ZoomableImageDialog> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDoubleTapZoom() {
    final bool zoomedIn = _controller.value.getMaxScaleOnAxis() > 1.05;
    if (zoomedIn) {
      _controller.value = Matrix4.identity();
      return;
    }
    const double scale = 2.5;
    _controller.value = Matrix4.diagonal3Values(scale, scale, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double width = screen.width > 1100 ? 900 : screen.width * 0.94;
    final double height = screen.height * 0.86;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: const Color(0xFF0B1220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title ?? 'Perbesar gambar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Tutup gambar',
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onDoubleTap: _toggleDoubleTapZoom,
                child: InteractiveViewer(
                  transformationController: _controller,
                  minScale: 0.8,
                  maxScale: 6,
                  child: Center(
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                color: Colors.white70, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'Gambar tidak dapat dimuat.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Cubit atau scroll untuk zoom • ketuk dua kali untuk memperbesar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
