
import 'package:flutter/material.dart';

class NetworkImageView extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? radius;

  const NetworkImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
  });

  bool get _isValidUrl {
    final uri = Uri.tryParse(imageUrl.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    final image = url.isNotEmpty && _isValidUrl
        ? Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _fallback(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return Container(
                width: width,
                height: height,
                color: const Color(0xFFEAF0F3),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            },
          )
        : _fallback();

    return radius == null
        ? image
        : ClipRRect(
            borderRadius: radius!,
            child: image,
          );
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: const Color(0xFFEAF0F3),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 38,
              color: Color(0xFF78909C),
            ),
            SizedBox(height: 5),
            Text(
              'Foto belum tersedia',
              style: TextStyle(
                color: Color(0xFF78909C),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
}
