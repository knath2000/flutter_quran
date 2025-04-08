import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:quran_flutter/features/settings/application/settings_providers.dart'; // Import font size provider
import 'package:quran_flutter/core/models/surah_info.dart';
import 'package:quran_flutter/features/navigation/app_router.dart'; // For AppRoutes
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

// Convert to StatefulWidget for hover effect
// Convert back to ConsumerStatefulWidget
class SurahGridTile extends ConsumerStatefulWidget {
  final SurahInfo surah;

  const SurahGridTile({super.key, required this.surah});

  @override
  @override
  ConsumerState<SurahGridTile> createState() => _SurahGridTileState();
}

// Update state class to extend ConsumerState
class _SurahGridTileState extends ConsumerState<SurahGridTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scale = _isHovering ? 1.05 : 1.0;
    // Watch the font size provider
    final fontSizeScale = ref.watch(fontSizeScaleFactorProvider);

    // Use MouseRegion to detect hover events (primarily for desktop/web)
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150), // Animation duration
        curve: Curves.easeInOut,
        child: InkWell(
          onTap: () {
            context.go(AppRoutes.readerPath(widget.surah.number));
          },
          borderRadius: BorderRadius.circular(15), // Match shape border radius
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: colorScheme.surface.withOpacity(0.9),
              boxShadow: [
                // Enhance shadow slightly on hover
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovering ? 0.3 : 0.2),
                  blurRadius: _isHovering ? 6 : 4,
                  offset: Offset(0, _isHovering ? 3 : 2),
                ),
              ],
              border: Border.all(
                color: colorScheme.primary.withOpacity(
                  _isHovering ? 0.6 : 0.4,
                ), // Brighter border on hover
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.primary, // Gold accent
                    foregroundColor: colorScheme.onPrimary, // Dark text on gold
                    child: Text(
                      widget.surah.number.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.surah.englishName,
                    textAlign: TextAlign.center,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize:
                          (textTheme.titleSmall?.fontSize ?? 14) *
                          fontSizeScale, // Apply scale
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.surah.name, // Arabic name
                    textAlign: TextAlign.center,
                    // Apply Amiri font using google_fonts (assuming it's available)
                    // If Amiri isn't in google_fonts, need to add locally and declare in pubspec.yaml
                    style: GoogleFonts.amiri(
                      textStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontSize:
                            (textTheme.bodyMedium?.fontSize ?? 14) *
                            fontSizeScale, // Apply scale
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.surah.numberOfAyahs} Ayahs',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize:
                          (textTheme.bodySmall?.fontSize ?? 12) *
                          fontSizeScale, // Apply scale
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
