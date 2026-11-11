import 'package:chotanews/services/translation_service.dart';
import 'package:flutter/material.dart';

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
  final bool? isTitle;

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
    this.isTitle,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextViewState {
  final String displayText;
  final bool isLoading;

  const _TranslatedTextViewState({
    required this.displayText,
    required this.isLoading,
  });
}

class _ResolvedTextLayout {
  final int? maxLines;
  final TextOverflow overflow;

  const _ResolvedTextLayout({
    required this.maxLines,
    required this.overflow,
  });
}

class _TranslatedTextState extends State<TranslatedText> {
  late final ValueNotifier<_TranslatedTextViewState> _viewState;

  @override
  void initState() {
    super.initState();
    _viewState = ValueNotifier<_TranslatedTextViewState>(
      _TranslatedTextViewState(displayText: widget.text, isLoading: false),
    );
    TranslationService().addListener(_onServiceChanged);
    _initText();
  }

  void _initText() {
    if (widget.translate) {
      final cached = TranslationService().getCached(widget.text);
      if (cached != null) {
        _viewState.value = _TranslatedTextViewState(
          displayText: cached,
          isLoading: false,
        );
      } else {
        _viewState.value = _TranslatedTextViewState(
          displayText: widget.text,
          isLoading: false,
        );
        _doTranslate();
      }
    } else {
      _viewState.value = _TranslatedTextViewState(
        displayText: widget.text,
        isLoading: false,
      );
    }
  }

  @override
  void dispose() {
    TranslationService().removeListener(_onServiceChanged);
    _viewState.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (widget.translate && mounted) {
      final cached = TranslationService().getCached(widget.text);
      if (cached != null && _viewState.value.displayText != cached) {
        _viewState.value = _TranslatedTextViewState(
          displayText: cached,
          isLoading: false,
        );
      } else if (_viewState.value.displayText == widget.text && TranslationService().isReady) {
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
        _viewState.value = _TranslatedTextViewState(
          displayText: cached,
          isLoading: false,
        );
      }
      return;
    }
    if (mounted) {
      _viewState.value = _TranslatedTextViewState(
        displayText: _viewState.value.displayText,
        isLoading: true,
      );
    }
    final translated = await TranslationService().translate(widget.text);
    if (mounted) {
      _viewState.value = _TranslatedTextViewState(
        displayText: translated,
        isLoading: false,
      );
    }
  }

  TextStyle? _getEffectiveStyle(TextStyle? baseStyle) {
    if (baseStyle == null) return null;
    if (widget.translate) {
      final double targetFontSize = widget.englishFontSize ?? baseStyle.fontSize ?? 14.0;
      return baseStyle.copyWith(
        fontFamily: 'SF Pro',
        fontFamilyFallback: const ['.SF Pro Text', '.SF Pro Display', 'SF Pro Text', 'SF Pro Display', 'Roboto'],
        fontSize: targetFontSize,
        fontWeight: FontWeight.w500,
      );
    }
    return baseStyle;
  }

  TextStyle _resolveTextStyle(BuildContext context, TextStyle? baseStyle) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effective = (baseStyle == null || baseStyle.inherit)
        ? defaultTextStyle.style.merge(baseStyle)
        : baseStyle;
    if (MediaQuery.boldTextOf(context)) {
      effective = effective.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return effective;
  }

  _ResolvedTextLayout? _computeBoundedTextLayout(
    BuildContext context, {
    required String text,
    required TextStyle? style,
    required BoxConstraints constraints,
  }) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final TextStyle resolvedStyle = _resolveTextStyle(context, style);
    final TextAlign textAlign =
        widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final TextDirection textDirection = Directionality.of(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final Locale? locale = Localizations.maybeLocaleOf(context);
    final TextWidthBasis textWidthBasis = defaultTextStyle.textWidthBasis;
    final TextHeightBehavior? textHeightBehavior =
        defaultTextStyle.textHeightBehavior ??
            DefaultTextHeightBehavior.maybeOf(context);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: resolvedStyle),
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
      locale: locale,
      strutStyle: widget.strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );

    try {
      textPainter.layout(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      );

      final lines = textPainter.computeLineMetrics();
      if (lines.isEmpty) {
        return const _ResolvedTextLayout(
          maxLines: null,
          overflow: TextOverflow.clip,
        );
      }

      int fittingLines = 0;
      for (final line in lines) {
        final double lineBottom = line.baseline + line.descent;
        if (lineBottom <= constraints.maxHeight + 0.5) {
          fittingLines++;
        } else {
          break;
        }
      }
      if (fittingLines == 0) {
        return null;
      }

      // Flutter treats (maxLines: null, overflow: TextOverflow.ellipsis) as
      // single-line truncation on the first overflowing width line. When all
      // wrapped lines fit inside the bounded height, omit ellipsis so every
      // line displays instead of collapsing to one line.
      if (fittingLines >= lines.length) {
        return const _ResolvedTextLayout(
          maxLines: null,
          overflow: TextOverflow.clip,
        );
      }

      // Ensure ellipsis glyph shaping/fallback font on the last visible line
      // does not push total height past the available height bound.
      while (fittingLines > 1) {
        final verificationPainter = TextPainter(
          text: TextSpan(text: text, style: resolvedStyle),
          textAlign: textAlign,
          textDirection: textDirection,
          textScaler: textScaler,
          locale: locale,
          maxLines: fittingLines,
          ellipsis: '\u2026',
          strutStyle: widget.strutStyle,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
        );
        try {
          verificationPainter.layout(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
          );
          if (verificationPainter.height <= constraints.maxHeight + 0.5) {
            break;
          }
        } finally {
          verificationPainter.dispose();
        }
        fittingLines--;
      }

      return _ResolvedTextLayout(
        maxLines: fittingLines,
        overflow: TextOverflow.ellipsis,
      );
    } finally {
      textPainter.dispose();
    }
  }

  Widget _buildAnimatedText(
    BuildContext context, {
    required _TranslatedTextViewState viewState,
    required TextStyle? effectiveStyle,
    int? maxLinesOverride,
    TextOverflow? overflowOverride,
  }) {
    final int? resolvedMaxLines = widget.maxLines ?? maxLinesOverride;
    final TextOverflow? resolvedOverflow = overflowOverride ?? widget.overflow;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: viewState.isLoading
          ? Text(
              widget.text,
              key: const ValueKey('original_loading'),
              style: widget.style?.copyWith(color: widget.style?.color?.withValues(alpha: 0.5)),
              textAlign: widget.textAlign,
              maxLines: resolvedMaxLines,
              overflow: resolvedOverflow,
              strutStyle: widget.strutStyle,
            )
          : Text(
              viewState.displayText,
              key: ValueKey(viewState.displayText),
              style: effectiveStyle,
              textAlign: widget.textAlign,
              maxLines: resolvedMaxLines,
              overflow: resolvedOverflow,
              strutStyle: widget.strutStyle,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _getEffectiveStyle(widget.style);

    return ValueListenableBuilder<_TranslatedTextViewState>(
      valueListenable: _viewState,
      builder: (context, viewState, _) {
        if (widget.maxLines == null && widget.overflow == TextOverflow.ellipsis) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.hasBoundedHeight &&
                  constraints.maxHeight.isFinite &&
                  constraints.maxWidth.isFinite) {
                if (constraints.maxHeight <= 0) {
                  return const SizedBox.shrink();
                }
                final String textToMeasure =
                    viewState.isLoading ? widget.text : viewState.displayText;
                final TextStyle? styleToMeasure = viewState.isLoading
                    ? widget.style?.copyWith(color: widget.style?.color?.withValues(alpha: 0.5))
                    : effectiveStyle;
                final _ResolvedTextLayout? resolvedLayout = _computeBoundedTextLayout(
                  context,
                  text: textToMeasure,
                  style: styleToMeasure,
                  constraints: constraints,
                );
                if (resolvedLayout == null) {
                  return const SizedBox.shrink();
                }
                return ClipRect(
                  child: _buildAnimatedText(
                    context,
                    viewState: viewState,
                    effectiveStyle: effectiveStyle,
                    maxLinesOverride: resolvedLayout.maxLines,
                    overflowOverride: resolvedLayout.overflow,
                  ),
                );
              }
              return _buildAnimatedText(
                context,
                viewState: viewState,
                effectiveStyle: effectiveStyle,
                // Without bounded height or explicit maxLines, TextOverflow.ellipsis
                // collapses wrapped text to one line; clip allows full multi-line wrapping.
                overflowOverride: TextOverflow.clip,
              );
            },
          );
        }

        return _buildAnimatedText(
          context,
          viewState: viewState,
          effectiveStyle: effectiveStyle,
        );
      },
    );
  }
}
