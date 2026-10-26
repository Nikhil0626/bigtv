import 'package:intl/intl.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String content;
  final int? postId;
  final String? link;
  final String? imageUrl;
  final String? brandName;
  final String? brandLogo;
  final String? lan;
  final String? status;
  final int? totalTargeted;
  final int? successCount;
  final int? failureCount;
  final String? statusMessage;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.content,
    this.postId,
    this.link,
    this.imageUrl,
    this.brandName,
    this.brandLogo,
    this.lan,
    this.status,
    this.totalTargeted,
    this.successCount,
    this.failureCount,
    this.statusMessage,
    this.sentAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    int? parsedPostId;
    if (json['postId'] != null) {
      if (json['postId'] is int) {
        parsedPostId = json['postId'] as int;
      } else {
        parsedPostId = int.tryParse(json['postId'].toString());
      }
    }

    final linkStr = json['link']?.toString();
    if (parsedPostId == null && linkStr != null && linkStr.contains('postId=')) {
      final uri = Uri.tryParse(linkStr);
      if (uri != null && uri.queryParameters['postId'] != null) {
        parsedPostId = int.tryParse(uri.queryParameters['postId']!);
      }
    }

    DateTime? parseDate(dynamic dateVal) {
      if (dateVal == null) return null;
      try {
        return DateTime.parse(dateVal.toString());
      } catch (_) {
        return null;
      }
    }

    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString().trim(),
      content: (json['content'] ?? '').toString().trim(),
      postId: parsedPostId,
      link: linkStr,
      imageUrl: json['imageUrl']?.toString(),
      brandName: json['brandName']?.toString() ?? 'BigTV',
      brandLogo: json['brandLogo']?.toString(),
      lan: json['lan']?.toString(),
      status: json['status']?.toString(),
      totalTargeted: json['totalTargeted'] is int
          ? json['totalTargeted']
          : int.tryParse(json['totalTargeted']?.toString() ?? ''),
      successCount: json['successCount'] is int
          ? json['successCount']
          : int.tryParse(json['successCount']?.toString() ?? ''),
      failureCount: json['failureCount'] is int
          ? json['failureCount']
          : int.tryParse(json['failureCount']?.toString() ?? ''),
      statusMessage: json['statusMessage']?.toString(),
      sentAt: parseDate(json['sentAt']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  String get displayImageUrl {
    if (imageUrl == null || imageUrl!.trim().isEmpty) return '';
    final url = imageUrl!.trim();
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return 'https://migwp.chotanews.com$url';
    return 'https://migwp.chotanews.com/$url';
  }

  String getTimeAgo({bool isTelugu = true}) {
    final target = sentAt ?? createdAt;
    if (target == null) return isTelugu ? "ఇప్పుడే" : "Just now";
    final now = DateTime.now();
    final difference = now.difference(target.toLocal());

    if (difference.inSeconds < 0 || difference.inSeconds < 60) {
      return isTelugu ? "ఇప్పుడే" : "Just now";
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return isTelugu ? "$mins నిమిషాల క్రితం" : "${mins}m ago";
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return isTelugu ? "$hours గంటల క్రితం" : "${hours}h ago";
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return isTelugu ? "$days రోజుల క్రితం" : "${days}d ago";
    } else {
      return DateFormat('dd MMM, hh:mm a').format(target.toLocal());
    }
  }

  Map<String, dynamic> toInitialArticleMap() {
    return {
      'id': postId ?? id,
      'title': title,
      'content': content,
      'image_url': imageUrl ?? '',
      'type': 'Standard',
      'created': sentAt?.toIso8601String() ?? createdAt?.toIso8601String() ?? '',
      'linkURLAndroid': link ?? '',
      'linkURLIos': link ?? '',
      'brandName': brandName ?? 'BigTV',
    };
  }
}

class NotificationListResponse {
  final List<AppNotificationModel> items;
  final int total;
  final int skip;
  final int take;

  NotificationListResponse({
    required this.items,
    required this.total,
    required this.skip,
    required this.take,
  });
}
