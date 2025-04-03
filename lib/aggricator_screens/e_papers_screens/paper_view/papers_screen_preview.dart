import 'package:flutter/material.dart';

class PapersScreenPreview extends StatefulWidget {
  final String imageUrl;
  const PapersScreenPreview({super.key, required this.imageUrl});

  @override
  State<PapersScreenPreview> createState() => _PapersScreenPreviewState();
}

class _PapersScreenPreviewState extends State<PapersScreenPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Better visibility
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(6),
          minScale: 1.0,
          maxScale: 10.0, // Maximum zoom level
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.fill, // Adjust for better fit
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
