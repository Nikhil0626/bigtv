import 'package:chotanews/services/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A widget that translates text when [translate] is true,
/// falls back to original text otherwise or on error.
class TranslatedText extends StatefulWidget {
  final String text;
  final bool translate;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final StrutStyle? strutStyle;
  final double? englishFontSize;

  const TranslatedText(
    this.text, {
    super.key,
    required this.translate,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.strutStyle,
    this.englishFontSize,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String _displayText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    TranslationService().addListener(_onServiceChanged);
    _initText();
  }

  void _initText() {
    if (widget.translate) {
      final cached = TranslationService().getCached(widget.text);
      if (cached != null) {
        _displayText = cached;
        _isLoading = false;
      } else {
        _displayText = widget.text;
        _doTranslate();
      }
    } else {
      _displayText = widget.text;
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    TranslationService().removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (widget.translate && mounted) {
      final cached = TranslationService().getCached(widget.text);
      if (cached != null && _displayText != cached) {
        setState(() {
          _displayText = cached;
          _isLoading = false;
        });
      } else if (_displayText == widget.text && TranslationService().isReady) {
        _doTranslate();
      }
    }
  }

  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.translate != widget.translate || oldWidget.text != widget.text) {
      _initText();
    }
  }

  Future<void> _doTranslate() async {
    if (widget.text.trim().isEmpty) return;
    final cached = TranslationService().getCached(widget.text);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _displayText = cached;
          _isLoading = false;
        });
      }
      return;
    }
    if (mounted) setState(() => _isLoading = true);
    final translated = await TranslationService().translate(widget.text);
    if (mounted) {
      setState(() {
        _displayText = translated;
        _isLoading = false;
      });
    }
  }

  TextStyle? _getEffectiveStyle(TextStyle? baseStyle) {
    if (baseStyle == null) return null;
    if (widget.translate) {
      final double targetFontSize = widget.englishFontSize ?? baseStyle.fontSize ?? 14.0;
      return GoogleFonts.poppins(
        textStyle: baseStyle.copyWith(
          fontSize: targetFontSize,
        ),
      );
    }
    return baseStyle;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _getEffectiveStyle(widget.style);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isLoading
          ? Text(
              widget.text,
              key: const ValueKey('original_loading'),
              style: widget.style?.copyWith(color: widget.style?.color?.withValues(alpha: 0.5)),
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
              overflow: widget.overflow,
              strutStyle: widget.strutStyle,
            )
          : Text(
              _displayText,
              key: ValueKey(_displayText),
              style: effectiveStyle,
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
              overflow: widget.overflow,
              strutStyle: widget.strutStyle,
            ),
    );
  }
}
