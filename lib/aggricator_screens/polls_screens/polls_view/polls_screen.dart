import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/core/widgets/content_share_buttons.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/services/poll_share_helper.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PollScreenDesign extends StatefulWidget {
  final dynamic artical;
  final int? index;
  final bool showTopBar;

  const PollScreenDesign({
    super.key,
    required this.artical,
    required this.index,
    this.showTopBar = false,
  });

  @override
  State<PollScreenDesign> createState() => _PollScreenDesignState();
}

class _PollScreenDesignState extends State<PollScreenDesign> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydratePoll();
    });
  }

  void _hydratePoll() {
    if (!mounted) return;
    _checkPendingVote();
    final pollProvider = context.read<PollProvider>();
    pollProvider.commentController.text = '';
    pollProvider.addData(widget.artical);

    final rawId = widget.artical is Map
        ? (widget.artical['id'] ?? widget.artical['post_id'])
        : null;
    final intPostId = int.tryParse(rawId?.toString() ?? '0') ?? 0;
    if (intPostId > 0) {
      pollProvider.fetchLivePollResults(intPostId);
    }
  }

  Future<void> _checkPendingVote() async {
    try {
      final sp = await SharedPreferences.getInstance();
      if (sp.getString('loginType') == 'login') {
        final pendingPollId = sp.getInt('pending_poll_id');
        final pendingOptId = sp.getInt('pending_poll_opt_id');
        final pendingTitle = sp.getString('pending_poll_title') ?? '';
        final currentId = int.tryParse(
              (widget.artical is Map
                      ? (widget.artical['id'] ?? widget.artical['post_id'])
                      : 0)
                  .toString(),
            ) ??
            0;

        if (pendingPollId != null &&
            pendingPollId == currentId &&
            pendingOptId != null) {
          await sp.remove('pending_poll_id');
          await sp.remove('pending_poll_opt_id');
          await sp.remove('pending_poll_title');
          if (mounted) {
            final articleMap = (widget.artical is Map)
                ? Map<String, dynamic>.from(widget.artical as Map)
                : <String, dynamic>{};
            await context.read<PollProvider>().executeVoteForArticle(
                  optId: pendingOptId,
                  article: articleMap,
                  title: pendingTitle,
                );
          }
        }
      }
    } catch (e) {
      log('Error checking pending vote: $e');
    }
  }

  Future<void> _handleOptionTap({
    required int optId,
    required Map<String, dynamic> article,
    required String title,
    required bool hasVoted,
    required bool isSubmittingVote,
  }) async {
    if (hasVoted || isSubmittingVote) {
      if (hasVoted) {
        CustomToast.showInfoToast(msg: 'మీరు ఇప్పటికే ఓటు వేశారు!');
      }
      return;
    }

    final sp = await SharedPreferences.getInstance();
    final bool isGuest = sp.getString('loginType') != 'login';

    if (isGuest) {
      if (!mounted) return;
      _showLoginDialog(
        optId: optId,
        article: article,
        title: title,
      );
      return;
    }

    if (!mounted) return;
    await context.read<PollProvider>().executeVoteForArticle(
          optId: optId,
          article: article,
          title: title,
        );
  }

  void _showLoginDialog({
    required int optId,
    required Map<String, dynamic> article,
    required String title,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2024),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: AppColorTokens.cinemaRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.how_to_vote_rounded,
                  color: AppColorTokens.cinemaRed,
                  size: 26.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'లాగిన్ అవ్వండి',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'ఓటు వేయడానికి మరియు ఫలితాలను చూడటానికి దయచేసి మీ మొబైల్ నంబర్‌తో లాగిన్ అవ్వండి.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13.5.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                      ),
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: Text(
                        'రద్దు',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorTokens.cinemaRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogCtx);
                        final pId = int.tryParse(
                              (article['id'] ?? article['post_id'] ?? '')
                                  .toString(),
                            ) ??
                            0;
                        final sp = await SharedPreferences.getInstance();
                        await sp.setInt('pending_poll_id', pId);
                        await sp.setInt('pending_poll_opt_id', optId);
                        await sp.setString('pending_poll_title', title);

                        if (!mounted) return;
                        context
                            .read<AuthenticationProvider>()
                            .newAppLoginStatus = NewAppLoginStatus.login;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginBackgroundView(),
                          ),
                        );

                        if (!mounted) return;
                        final updatedSp = await SharedPreferences.getInstance();
                        final bool isNowLoggedIn =
                            updatedSp.getString('loginType') == 'login';
                        if (isNowLoggedIn && mounted) {
                          final pollProvider = context.read<PollProvider>();
                          await updatedSp.remove('pending_poll_id');
                          await updatedSp.remove('pending_poll_opt_id');
                          await updatedSp.remove('pending_poll_title');
                          await pollProvider.executeVoteForArticle(
                            optId: optId,
                            article: article,
                            title: title,
                          );
                        }
                      },
                      child: Text(
                        'లాగిన్',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant PollScreenDesign oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = oldWidget.artical is Map
        ? (oldWidget.artical['id'] ?? oldWidget.artical['post_id'])
        : null;
    final newId = widget.artical is Map
        ? (widget.artical['id'] ?? widget.artical['post_id'])
        : null;
    if (newId != null && newId != oldId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final pollProvider = context.read<PollProvider>();
        pollProvider.commentController.text = '';
        pollProvider.addData(widget.artical);
        final intPostId = int.tryParse(newId.toString()) ?? 0;
        if (intPostId > 0) {
          pollProvider.fetchLivePollResults(intPostId);
        }
      });
    }
  }

  String _getImageUrl(dynamic imageUrl) {
    return PollShareHelper.resolveImageUrl(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, _) {
        final currentArticleMap = (widget.artical is Map)
            ? Map<String, dynamic>.from(widget.artical as Map)
            : <String, dynamic>{};
        final currentPostId =
            currentArticleMap['id'] ?? currentArticleMap['post_id'];
        final bool isSameArticleAsLocal =
            pollProvider.localArticle.isNotEmpty &&
                currentPostId != null &&
                (pollProvider.localArticle['id'] == currentPostId ||
                    pollProvider.localArticle['post_id'] == currentPostId);

        final article =
            isSameArticleAsLocal ? pollProvider.localArticle : currentArticleMap;

        final pollData = (article['pollData'] is Map)
            ? Map<String, dynamic>.from(article['pollData'] as Map)
            : (article['poll_data'] is Map)
                ? Map<String, dynamic>.from(article['poll_data'] as Map)
                : <String, dynamic>{};

        final String title =
            (article['title'] ?? pollData['title'] ?? '').toString();

        final String dateStr =
            (article['created_at'] ?? article['date'] ?? '').toString();

        final String remainingTime =
            (article['remaining_time'] ?? '').toString();

        final String description =
            (article['content'] ?? article['description'] ?? '').toString();

        final String imageUrl =
            _getImageUrl(article['image_url'] ?? article['imageUrl']);

        final List rawOpts = (pollData['options'] is List &&
                (pollData['options'] as List).isNotEmpty)
            ? (pollData['options'] as List)
            : (article['poll_options'] is List &&
                    (article['poll_options'] as List).isNotEmpty)
                ? (article['poll_options'] as List)
                : (article['options'] is List &&
                        (article['options'] as List).isNotEmpty)
                    ? (article['options'] as List)
                    : [];

        final List options = rawOpts;

        final bool hasVoted = pollData['userHasVoted'] == true ||
            pollData['user_has_voted'] == true ||
            pollProvider.userVotedOptionId != null;

        final bool isSubmittingVote =
            pollProvider.isSubmittingVoteForPost(currentPostId ?? 888801);

        final int selectedOptionId = pollProvider.tempSelectedOptionId ??
            pollProvider.userVotedOptionId ??
            (pollData['userVotedOption'] is num
                ? (pollData['userVotedOption'] as num).toInt()
                : (pollData['user_voted_option'] is num
                    ? (pollData['user_voted_option'] as num).toInt()
                    : -1));

        return Screenshot(
          controller: _screenshotController,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColorTokens.cinematicBackground,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                if (imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColorTokens.cinematicCard),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColorTokens.cinematicCard,
                      child: const Center(
                        child: Icon(
                          Icons.poll_rounded,
                          color: Colors.white24,
                          size: 60,
                        ),
                      ),
                    ),
                  ),

                // Gradient Overlay (Dark cinematic fade)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                          AppColorTokens.cinematicBackground
                              .withValues(alpha: 0.95),
                          AppColorTokens.cinematicBackground,
                        ],
                        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),

                // Content Area
                SafeArea(
                  bottom: true,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                        // Top Bar (if standalone screen)
                        if (widget.showTopBar) ...[
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.maybePop(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorTokens.cinemaRed,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'BIG TV',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'పోల్స్',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                        ],

                        // Share Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ContentShareButtons(
                              whatsAppButtonKey: const Key(
                                'poll_whatsapp_share_button',
                              ),
                              shareButtonKey: const Key(
                                'poll_share_button',
                              ),
                              onShareWhatsApp: () {
                                PollShareHelper.sharePoll(
                                  context: context,
                                  article: article,
                                  pollData: pollProvider.currentPollData,
                                  screenshotController: _screenshotController,
                                  isWhatsAppOnly: true,
                                );
                              },
                              onShareMore: () {
                                PollShareHelper.sharePoll(
                                  context: context,
                                  article: article,
                                  pollData: pollProvider.currentPollData,
                                  screenshotController: _screenshotController,
                                  isWhatsAppOnly: false,
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        // Poll Question Title
                        if (title.isNotEmpty) ...[
                          Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.5.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.32,
                            ),
                          ),
                          SizedBox(height: 6.h),
                        ],

                        // Date & Remaining Time Row
                        if (dateStr.isNotEmpty || remainingTime.isNotEmpty) ...[
                          Row(
                            children: [
                              if (dateStr.isNotEmpty) ...[
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: const Color(0xFFD1D5DB),
                                  size: 13.sp,
                                ),
                                SizedBox(width: 5.w),
                                Flexible(
                                  child: Text(
                                    dateStr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFFD1D5DB),
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              if (dateStr.isNotEmpty &&
                                  remainingTime.isNotEmpty) ...[
                                SizedBox(width: 8.w),
                                Text(
                                  '|',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                              ],
                              if (remainingTime.isNotEmpty) ...[
                                Icon(
                                  Icons.timer_outlined,
                                  color: const Color(0xFFD1D5DB),
                                  size: 14.sp,
                                ),
                                SizedBox(width: 5.w),
                                Flexible(
                                  child: Text(
                                    remainingTime,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFFD1D5DB),
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],

                        // Description
                        if (description.isNotEmpty) ...[
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFFE5E7EB),
                              fontSize: 12.5.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],

                        // Options List (4 interactive cards)
                        ...options.map((opt) {
                          final optionMap = (opt is Map)
                              ? Map<String, dynamic>.from(opt)
                              : {'id': 0, 'text': opt.toString()};
                          final int optId = optionMap['id'] is num
                              ? (optionMap['id'] as num).toInt()
                              : int.tryParse(optionMap['id']?.toString() ?? '') ??
                                  (optionMap['option'] is num
                                      ? (optionMap['option'] as num).toInt()
                                      : int.tryParse(
                                            optionMap['option']?.toString() ??
                                                '',
                                          ) ??
                                          0);
                          final String optText = (optionMap['text'] ??
                                  optionMap['option_name'] ??
                                  optionMap['name'] ??
                                  optionMap['title'] ??
                                  '')
                              .toString();
                          final double percentage =
                              ((optionMap['percentage'] ?? 0) as num)
                                  .toDouble();
                          final bool isSelected = (selectedOptionId == optId) ||
                              (optionMap['selected'] == true) ||
                              (pollData['userVotedOption'] == optId) ||
                              (pollData['user_voted_option'] == optId);

                          return GestureDetector(
                            onTap: () => _handleOptionTap(
                              optId: optId,
                              article: article,
                              title: title,
                              hasVoted: hasVoted,
                              isSubmittingVote: isSubmittingVote,
                            ),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 7.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 7.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColorTokens.cinemaRed
                                        .withValues(alpha: 0.15)
                                    : AppColorTokens.cinematicSurface
                                        .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColorTokens.cinemaRed
                                      : AppColorTokens.cinematicBorder,
                                  width: isSelected ? 1.4 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Radio Button Ring
                                  isSelected
                                      ? Container(
                                          width: 18.w,
                                          height: 18.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColorTokens.cinemaRed,
                                              width: 2.2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 8.w,
                                              height: 8.w,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColorTokens.cinemaRed,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 18.w,
                                          height: 18.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF9CA3AF),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                  SizedBox(width: 10.w),

                                  // Option Text
                                  Expanded(
                                    child: Text(
                                      optText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  // Progress Bar & Percentage (Revealed only after vote is cast)
                                  if (hasVoted) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      width: 85.w,
                                      height: 6.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF374151),
                                        borderRadius:
                                            BorderRadius.circular(3.r),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: 85.w *
                                              (percentage / 100.0)
                                                  .clamp(0.0, 1.0),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColorTokens.cinemaRed
                                                : const Color(0xFF9CA3AF),
                                            borderRadius:
                                                BorderRadius.circular(3.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    SizedBox(
                                      width: 34.w,
                                      child: Text(
                                        '${percentage.toInt()}%',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColorTokens.cinemaRed
                                              : Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 6.h),

                        // Post-vote confirmation or in-flight indicator
                        if (isSubmittingVote) ...[
                          Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColorTokens.cinematicSurface
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: AppColorTokens.cinemaRed
                                    .withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16.r,
                                  height: 16.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColorTokens.cinemaRed,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    'ఓటు నమోదు చేయబడుతోంది...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (hasVoted) ...[
                          Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColorTokens.success
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: AppColorTokens.success
                                    .withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColorTokens.success,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    'ఓటు నమోదు చేయబడింది',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColorTokens.success,
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
