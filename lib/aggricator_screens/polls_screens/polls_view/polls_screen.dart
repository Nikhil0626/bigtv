import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
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
  bool _isSubmittingVote = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingVote();
      final pollProvider = context.read<PollProvider>();
      pollProvider.commentController.text = "";
      pollProvider.addData(widget.artical);

      final rawId = widget.artical is Map
          ? (widget.artical['id'] ?? widget.artical['post_id'])
          : null;
      final intPostId = int.tryParse(rawId?.toString() ?? '0') ?? 0;
      if (intPostId > 0) {
        pollProvider.fetchLivePollResults(intPostId);
      }
    });
  }

  Future<void> _checkPendingVote() async {
    try {
      final sp = await SharedPreferences.getInstance();
      if (sp.getString("loginType") == "login") {
        final pendingPollId = sp.getInt('pending_poll_id');
        final pendingOptId = sp.getInt('pending_poll_opt_id');
        final pendingTitle = sp.getString('pending_poll_title') ?? '';
        final currentId = int.tryParse(
                (widget.artical is Map ? (widget.artical['id'] ?? widget.artical['post_id']) : 0)
                    .toString()) ??
            0;

        if (pendingPollId != null && pendingPollId == currentId && pendingOptId != null) {
          await sp.remove('pending_poll_id');
          await sp.remove('pending_poll_opt_id');
          await sp.remove('pending_poll_title');
          if (mounted) {
            final articleMap = (widget.artical is Map)
                ? Map<String, dynamic>.from(widget.artical)
                : <String, dynamic>{};
            await _executeVote(pendingOptId, articleMap, pendingTitle);
          }
        }
      }
    } catch (e) {
      log("Error checking pending vote: $e");
    }
  }

  Future<void> _handleOptionTap({
    required int optId,
    required Map<String, dynamic> article,
    required String title,
    required bool hasVoted,
  }) async {
    if (hasVoted || _isSubmittingVote) {
      if (hasVoted) {
        CustomToast.showInfoToast(msg: "మీరు ఇప్పటికే ఓటు వేశారు!");
      }
      return;
    }

    final sp = await SharedPreferences.getInstance();
    final bool isGuest = sp.getString("loginType") != "login";

    if (isGuest) {
      if (!mounted) return;
      _showLoginDialog(
        optId: optId,
        article: article,
        title: title,
      );
      return;
    }

    await _executeVote(optId, article, title);
  }

  Future<void> _executeVote(int optId, Map<String, dynamic> article, String title) async {
    if (_isSubmittingVote) return;
    setState(() {
      _isSubmittingVote = true;
    });

    final pollProvider = context.read<PollProvider>();
    final rawId = article['id'] ?? article['post_id'] ?? 888801;
    final int pId = int.tryParse(rawId.toString()) ?? 0;

    pollProvider.setTempSelectedOptionId(optId);

    try {
      await pollProvider.submitPolls(
        rawId,
        0,
        optId,
        title,
        onSuccess: () {
          if (pId > 0) {
            pollProvider.fetchLivePollResults(pId);
          }
        },
      );
    } catch (e) {
      log("Error executing poll vote: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingVote = false;
        });
      }
    }
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
                  color: const Color(0xFFE50914).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.how_to_vote_rounded,
                  color: const Color(0xFFE50914),
                  size: 26.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                "లాగిన్ అవ్వండి",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "ఓటు వేయడానికి మరియు ఫలితాలను చూడటానికి దయచేసి మీ మొబైల్ నంబర్‌తో లాగిన్ అవ్వండి.",
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
                        "రద్దు",
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
                        backgroundColor: const Color(0xFFE50914),
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
                                    .toString()) ??
                            0;
                        final sp = await SharedPreferences.getInstance();
                        await sp.setInt('pending_poll_id', pId);
                        await sp.setInt('pending_poll_opt_id', optId);
                        await sp.setString('pending_poll_title', title);

                        if (!mounted) return;
                        context.read<AuthenticationProvider>().newAppLoginStatus =
                            NewAppLoginStatus.login;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginBackgroundView(),
                          ),
                        );

                        if (!mounted) return;
                        final updatedSp = await SharedPreferences.getInstance();
                        final bool isNowLoggedIn =
                            updatedSp.getString("loginType") == "login";
                        if (isNowLoggedIn) {
                          await updatedSp.remove('pending_poll_id');
                          await updatedSp.remove('pending_poll_opt_id');
                          await updatedSp.remove('pending_poll_title');
                          await _executeVote(optId, article, title);
                        }
                      },
                      child: Text(
                        "లాగిన్",
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
    final oldId = oldWidget.artical is Map ? (oldWidget.artical['id'] ?? oldWidget.artical['post_id']) : null;
    final newId = widget.artical is Map ? (widget.artical['id'] ?? widget.artical['post_id']) : null;
    if (newId != null && newId != oldId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final pollProvider = context.read<PollProvider>();
        pollProvider.commentController.text = "";
        pollProvider.addData(widget.artical);
        final intPostId = int.tryParse(newId.toString()) ?? 0;
        if (intPostId > 0) {
          pollProvider.fetchLivePollResults(intPostId);
        }
      });
    }
  }

  String _getImageUrl(dynamic imageUrl) {
    if (imageUrl == null || imageUrl.toString().trim().isEmpty) return "";
    final url = imageUrl.toString();
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return "https://migwp.chotanews.com$url";
    return "https://migwp.chotanews.com/$url";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, _) {
        final currentArticleMap = (widget.artical is Map)
            ? Map<String, dynamic>.from(widget.artical)
            : <String, dynamic>{};
        final currentPostId = currentArticleMap['id'] ?? currentArticleMap['post_id'];
        final bool isSameArticleAsLocal = pollProvider.localArticle.isNotEmpty &&
            currentPostId != null &&
            (pollProvider.localArticle['id'] == currentPostId ||
             pollProvider.localArticle['post_id'] == currentPostId);

        final article = isSameArticleAsLocal
            ? pollProvider.localArticle
            : currentArticleMap;

        final pollData = (article['pollData'] is Map)
            ? Map<String, dynamic>.from(article['pollData'])
            : (article['poll_data'] is Map)
                ? Map<String, dynamic>.from(article['poll_data'])
                : <String, dynamic>{};

        final String title = (article['title'] ??
                pollData['title'] ??
                "")
            .toString();

        final String dateStr =
            (article['created_at'] ?? article['date'] ?? "").toString();

        final String remainingTime =
            (article['remaining_time'] ?? "").toString();

        final String description = (article['content'] ??
                article['description'] ??
                "")
            .toString();

        final String imageUrl = _getImageUrl(article['image_url'] ?? article['imageUrl']);

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

        final int selectedOptionId = pollProvider.tempSelectedOptionId ??
            pollProvider.userVotedOptionId ??
            (pollData['userVotedOption'] is num
                ? (pollData['userVotedOption'] as num).toInt()
                : (pollData['user_voted_option'] is num
                    ? (pollData['user_voted_option'] as num).toInt()
                    : -1));

        final totalVotesVal = article['total_votes_display'] ??
            pollData['totalVotes'] ??
            pollData['total_votes'] ??
            article['total_votes'];
        final String totalVotesDisplay = totalVotesVal != null && totalVotesVal.toString().isNotEmpty
            ? (totalVotesVal.toString().contains('ఓటు')
                ? totalVotesVal.toString()
                : "$totalVotesVal మంది ఓటు వేశారు")
            : "";

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF0F0F12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              if (imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: const Color(0xFF16161B)),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF16161B),
                    child: const Center(
                      child: Icon(Icons.poll_rounded, color: Colors.white24, size: 60),
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
                        const Color(0xFF0F0F12).withValues(alpha: 0.95),
                        const Color(0xFF0F0F12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
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
                                    color: Colors.white.withValues(alpha: 0.25),
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
                              padding:
                                  EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE50914),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                "BIG TV",
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
                              "|",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                "పోల్స్",
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
                              Text(
                                dateStr,
                                style: TextStyle(
                                  color: const Color(0xFFD1D5DB),
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (dateStr.isNotEmpty && remainingTime.isNotEmpty) ...[
                              SizedBox(width: 8.w),
                              Text(
                                "|",
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
                              Text(
                                remainingTime,
                                style: TextStyle(
                                  color: const Color(0xFFD1D5DB),
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w500,
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
                                    : int.tryParse(optionMap['option']?.toString() ?? '') ?? 0);
                        final String optText =
                            (optionMap['text'] ?? optionMap['option_name'] ?? optionMap['name'] ?? optionMap['title'] ?? '').toString();
                        final double percentage =
                            ((optionMap['percentage'] ?? 0) as num).toDouble();
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
                          ),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 7.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 7.5.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE50914).withValues(alpha: 0.15)
                                  : const Color(0xFF1E1E24).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE50914)
                                    : const Color(0xFF33333E),
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
                                            color: const Color(0xFFE50914),
                                            width: 2.2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 8.w,
                                            height: 8.w,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFE50914),
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
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: 85.w *
                                            (percentage / 100.0).clamp(0.0, 1.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFE50914)
                                              : const Color(0xFF9CA3AF),
                                          borderRadius: BorderRadius.circular(3.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  SizedBox(
                                    width: 34.w,
                                    child: Text(
                                      "${percentage.toInt()}%",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFFE50914)
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

                      // Footer Votes Row
                      if (totalVotesDisplay.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              color: const Color(0xFFE50914),
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              totalVotesDisplay,
                              style: TextStyle(
                                color: const Color(0xFFE5E7EB),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                      ],

                      // Post-vote confirmation or in-flight indicator (No separate vote button needed)
                      if (_isSubmittingVote) ...[
                        Container(
                          height: 40.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E24).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: const Color(0xFFE50914).withValues(alpha: 0.4),
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
                                  color: Color(0xFFE50914),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "ఓటు నమోదు చేయబడుతోంది...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (hasVoted) ...[
                        Container(
                          height: 40.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: const Color(0xFF10B981),
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "ఓటు నమోదు చేయబడింది",
                                style: TextStyle(
                                  color: const Color(0xFF10B981),
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
