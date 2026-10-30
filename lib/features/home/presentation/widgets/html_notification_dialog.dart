import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../globel_keys/globel_keys.dart';
import '../providers/home_provider.dart';

/// Shows an HTML-rendered pop-up dialog for rich notifications / breaking news.
bool _isNotificationDialogShowing = false;

Future<void> showHtmlNotificationDialog({
  BuildContext? context,
  required String content,
  String? title,
  String? imageUrl,
  String? ctaText,
  String? ctaUrl,
  Map<String, dynamic>? rawPayload,
}) async {
  final targetContext = context ?? mainNavigatorKey.currentContext ?? mainNavigatorKey.currentState?.overlay?.context;
  if (targetContext == null) {
    log("Cannot show HTML notification dialog: No valid context found.");
    return;
  }

  if (_isNotificationDialogShowing) {
    log("HTML notification dialog is already visible. Skipping duplicate.");
    return;
  }

  _isNotificationDialogShowing = true;

  try {
    await showDialog(
      context: targetContext,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (BuildContext ctx) {
        return HtmlNotificationDialog(
          content: content,
          title: title,
          imageUrl: imageUrl,
          ctaText: ctaText,
          ctaUrl: ctaUrl,
          rawPayload: rawPayload,
        );
      },
    );
  } catch (e) {
    log("Error displaying HTML notification dialog: $e");
  } finally {
    _isNotificationDialogShowing = false;
  }
}

class HtmlNotificationDialog extends StatefulWidget {
  final String content;
  final String? title;
  final String? imageUrl;
  final String? ctaText;
  final String? ctaUrl;
  final Map<String, dynamic>? rawPayload;

  const HtmlNotificationDialog({
    super.key,
    required this.content,
    this.title,
    this.imageUrl,
    this.ctaText,
    this.ctaUrl,
    this.rawPayload,
  });

  @override
  State<HtmlNotificationDialog> createState() => _HtmlNotificationDialogState();
}

class _HtmlNotificationDialogState extends State<HtmlNotificationDialog> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  Future<void> _handleLinkClick(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      
      // If it's an in-app deep link or internal article/page
      final lowerUrl = url.toLowerCase();
      final bool isInternalLink = lowerUrl.contains('bigtv24x7.com') ||
          lowerUrl.contains('bigtvlive.com') ||
          lowerUrl.contains('chotanews') ||
          lowerUrl.startsWith('/') ||
          lowerUrl.contains('postid=') ||
          lowerUrl.contains('post_id=') ||
          lowerUrl.contains('/posts/') ||
          lowerUrl.contains('/post/');

      if (mounted && isInternalLink) {
        Navigator.of(context, rootNavigator: true).pop();
        context.read<HomeProvider>().routeDeepLink(uri, isFromNotification: true);
        return;
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      log("Error launching URL from HTML notification: $e");
    }
  }

  String? _extractFirstLink(String html) {
    final hrefMatch = RegExp(r'''href=['"]([^'"]+)['"]''', caseSensitive: false).firstMatch(html);
    return hrefMatch?.group(1);
  }

  String? _extractFirstLinkText(String html) {
    final linkTextMatch = RegExp(r'''<a[^>]*>(.*?)<\/a>''', caseSensitive: false, dotAll: true).firstMatch(html);
    if (linkTextMatch != null) {
      return _stripHtml(linkTextMatch.group(1) ?? '').trim();
    }
    return null;
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  bool _isBreakingNews(String html, String? title) {
    final lower = "${title ?? ''} $html".toLowerCase();
    return lower.contains('breaking') || lower.contains('live') || lower.contains('alert');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryLink = widget.ctaUrl ?? _extractFirstLink(widget.content);
    final linkText = widget.ctaText ?? _extractFirstLinkText(widget.content) ?? "Open Link";
    final isAlert = _isBreakingNews(widget.content, widget.title);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 420.w, maxHeight: 600.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isAlert ? const Color(0xFFD32F2F).withValues(alpha: 0.4) : (isDark ? Colors.white12 : Colors.black12),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Bar with Badge and Close Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isAlert
                    ? const Color(0xFFD32F2F).withValues(alpha: 0.08)
                    : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                ),
              ),
              child: Row(
                children: [
                  // Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isAlert
                            ? [const Color(0xFFD32F2F), const Color(0xFFB71C1C)]
                            : [const Color(0xFF1976D2), const Color(0xFF0D47A1)],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: (isAlert ? const Color(0xFFD32F2F) : const Color(0xFF1976D2)).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAlert ? Icons.bolt_rounded : Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isAlert ? "BREAKING NEWS" : "NOTIFICATION",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Close 'X' Button
                  InkWell(
                    onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Optional Image
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl!,
                  height: 150.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150.h,
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),

            // Content Area
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (if given)
                    if (widget.title != null && widget.title!.isNotEmpty) ...[
                      Text(
                        widget.title!,
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111111),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],

                    // Render HTML Text Spans
                    SelectableText.rich(
                      TextSpan(
                        children: _parseHtmlToSpans(
                          widget.content,
                          baseStyle: GoogleFonts.outfit(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF222222),
                            height: 1.45,
                          ),
                          onLinkTap: _handleLinkClick,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        "Dismiss",
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  if (primaryLink != null && primaryLink.isNotEmpty) ...[
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _handleLinkClick(primaryLink),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          backgroundColor: const Color(0xFFD32F2F),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                linkText.isNotEmpty ? linkText : "Open Link",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(Icons.open_in_new_rounded, size: 14.sp, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parses HTML tags into structured TextSpans with nested styles and link handlers.
  List<InlineSpan> _parseHtmlToSpans(
    String html, {
    required TextStyle baseStyle,
    required void Function(String url) onLinkTap,
  }) {
    final List<InlineSpan> spans = [];
    
    // Normalize HTML
    String cleanHtml = html
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<\/p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<\/div>', caseSensitive: false), '\n');

    // Tokenize HTML tags and text chunks
    final tagRegex = RegExp(r'<(\/?)(\w+)([^>]*)>|([^<]+)');
    final matches = tagRegex.allMatches(cleanHtml);

    // Style stack for nested styling
    final List<_HtmlTagStyle> styleStack = [_HtmlTagStyle(style: baseStyle)];

    for (final match in matches) {
      final isClosing = match.group(1) == '/';
      final tagName = match.group(2)?.toLowerCase();
      final attributes = match.group(3) ?? '';
      final textContent = match.group(4);

      if (textContent != null && textContent.isNotEmpty) {
        final decodedText = _decodeHtmlEntities(textContent);
        final currentStyle = styleStack.last;

        TapGestureRecognizer? recognizer;
        if (currentStyle.linkUrl != null && currentStyle.linkUrl!.isNotEmpty) {
          final url = currentStyle.linkUrl!;
          recognizer = TapGestureRecognizer()..onTap = () => onLinkTap(url);
          _recognizers.add(recognizer);
        }

        spans.add(
          TextSpan(
            text: decodedText,
            style: currentStyle.style,
            recognizer: recognizer,
          ),
        );
      } else if (tagName != null) {
        if (isClosing) {
          // Pop the topmost matching tag or restore previous style
          if (styleStack.length > 1) {
            final lastIndex = styleStack.lastIndexWhere((s) => s.tagName == tagName);
            if (lastIndex > 0) {
              styleStack.removeAt(lastIndex);
            } else {
              styleStack.removeLast();
            }
          }
        } else {
          // Opening tag: compute new style merged with parent
          final parent = styleStack.last;
          final newTagStyle = _buildTagStyle(
            tagName: tagName,
            attributes: attributes,
            parent: parent,
          );
          styleStack.add(newTagStyle);
        }
      }
    }

    return spans;
  }

  _HtmlTagStyle _buildTagStyle({
    required String tagName,
    required String attributes,
    required _HtmlTagStyle parent,
  }) {
    TextStyle current = parent.style;
    String? linkUrl = parent.linkUrl;

    // Parse attributes like style and href
    final styleAttr = _getAttribute(attributes, 'style');
    final hrefAttr = _getAttribute(attributes, 'href');

    if (tagName == 'a' && hrefAttr != null && hrefAttr.isNotEmpty) {
      linkUrl = hrefAttr;
      current = current.copyWith(
        color: const Color(0xFF1976D2),
        decoration: TextDecoration.underline,
      );
    }

    if (tagName == 'b' || tagName == 'strong' || tagName == 'h1' || tagName == 'h2' || tagName == 'h3') {
      current = current.copyWith(fontWeight: FontWeight.bold);
    }

    if (tagName == 'i' || tagName == 'em') {
      current = current.copyWith(fontStyle: FontStyle.italic);
    }

    if (tagName == 'u') {
      current = current.copyWith(decoration: TextDecoration.underline);
    }

    if (tagName == 's' || tagName == 'del' || tagName == 'strike') {
      current = current.copyWith(decoration: TextDecoration.lineThrough);
    }

    // Apply inline CSS styles (e.g. style='color: #D32F2F;')
    if (styleAttr != null && styleAttr.isNotEmpty) {
      current = _applyInlineStyles(current, styleAttr);
    }

    return _HtmlTagStyle(
      tagName: tagName,
      style: current,
      linkUrl: linkUrl,
    );
  }

  TextStyle _applyInlineStyles(TextStyle style, String styleString) {
    TextStyle modified = style;
    final declarations = styleString.split(';');

    for (final decl in declarations) {
      final parts = decl.split(':');
      if (parts.length != 2) continue;
      final property = parts[0].trim().toLowerCase();
      final value = parts[1].trim().toLowerCase();

      if (property == 'color') {
        final color = _parseColor(value);
        if (color != null) {
          modified = modified.copyWith(color: color);
        }
      } else if (property == 'font-weight') {
        if (value.contains('bold') || value == '700' || value == '800' || value == '900') {
          modified = modified.copyWith(fontWeight: FontWeight.bold);
        } else if (value == 'normal' || value == '400') {
          modified = modified.copyWith(fontWeight: FontWeight.normal);
        }
      } else if (property == 'font-style') {
        if (value.contains('italic')) {
          modified = modified.copyWith(fontStyle: FontStyle.italic);
        }
      } else if (property == 'text-decoration') {
        if (value.contains('underline')) {
          modified = modified.copyWith(decoration: TextDecoration.underline);
        } else if (value.contains('line-through')) {
          modified = modified.copyWith(decoration: TextDecoration.lineThrough);
        }
      }
    }

    return modified;
  }

  Color? _parseColor(String colorStr) {
    try {
      final clean = colorStr.trim().toLowerCase();
      if (clean.startsWith('#')) {
        String hex = clean.substring(1);
        if (hex.length == 3) {
          hex = hex.split('').map((c) => '$c$c').join('');
        }
        if (hex.length == 6) {
          return Color(int.parse('0xFF$hex'));
        } else if (hex.length == 8) {
          return Color(int.parse('0x$hex'));
        }
      } else if (clean.startsWith('rgb')) {
        final match = RegExp(r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)').firstMatch(clean);
        if (match != null) {
          final r = int.parse(match.group(1)!);
          final g = int.parse(match.group(2)!);
          final b = int.parse(match.group(3)!);
          return Color.fromRGBO(r, g, b, 1.0);
        }
      }

      // Named color mappings
      switch (clean) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        case 'yellow':
          return Colors.amber;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'grey':
        case 'gray':
          return Colors.grey;
      }
    } catch (_) {}
    return null;
  }

  String? _getAttribute(String tagAttributes, String attrName) {
    final pattern = RegExp('$attrName\\s*=\\s*[\'"]([^\'"]*)[\'"]', caseSensitive: false);
    final match = pattern.firstMatch(tagAttributes);
    return match?.group(1);
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }
}

class _HtmlTagStyle {
  final String? tagName;
  final TextStyle style;
  final String? linkUrl;

  _HtmlTagStyle({
    this.tagName,
    required this.style,
    this.linkUrl,
  });
}
