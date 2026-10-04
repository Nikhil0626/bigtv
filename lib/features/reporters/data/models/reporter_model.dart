class ReporterModel {
  final String id;
  final String name;
  final String title;
  final String location;
  final String state;
  final String category;
  final String about;
  final String phone;
  final String email;
  final String whatsapp;
  final String imageUrl;
  final String bureau;
  final String employeeId;
  final String mediaChannelName;
  final Map<String, dynamic>? socialMediaProfiles;

  const ReporterModel({
    required this.id,
    required this.name,
    required this.title,
    required this.location,
    required this.state,
    required this.category,
    required this.about,
    required this.phone,
    required this.email,
    required this.whatsapp,
    required this.imageUrl,
    this.bureau = '',
    this.employeeId = '',
    this.mediaChannelName = '',
    this.socialMediaProfiles,
  });

  String get fullLocation => state.isNotEmpty ? "$location, $state" : location;

  factory ReporterModel.fromJson(Map<String, dynamic> json) {
    final mediaChannel = json['mediaChannel'] is Map<String, dynamic>
        ? json['mediaChannel'] as Map<String, dynamic>
        : null;
    final address = mediaChannel?['address'] is Map<String, dynamic>
        ? mediaChannel!['address'] as Map<String, dynamic>
        : (json['address'] is Map<String, dynamic>
            ? json['address'] as Map<String, dynamic>
            : null);

    final employment = json['employment'] is Map<String, dynamic>
        ? json['employment'] as Map<String, dynamic>
        : null;

    // Location & State parsing
    String loc = json['location']?.toString() ?? '';
    if (loc.isEmpty && address != null) {
      final city = address['city']?.toString() ?? '';
      final district = address['district']?.toString() ?? '';
      loc = city.isNotEmpty ? city : district;
    }

    String st = json['state']?.toString() ?? '';
    if (st.isEmpty && address != null) {
      st = address['state']?.toString() ?? '';
    }
    if (st.toUpperCase() == 'AP') {
      st = 'Andhra Pradesh';
    } else if (st.toUpperCase() == 'TS' || st.toUpperCase() == 'TELANGANA') {
      st = 'Telangana';
    }

    // Title / Designation
    final designation = employment?['designation']?.toString() ??
        employment?['role']?.toString() ??
        json['title']?.toString() ??
        'Reporter';

    // Category / Bureau
    final bureauStr = employment?['bureau']?.toString() ?? '';
    final cat = employment?['department']?.toString() ??
        (bureauStr.isNotEmpty ? bureauStr : (json['category']?.toString() ?? 'News'));

    // Contacts
    final workPhone = employment?['workPhone']?.toString() ??
        mediaChannel?['phone']?.toString() ??
        json['phone']?.toString() ??
        '';
    final workEmail = employment?['workEmail']?.toString() ??
        mediaChannel?['email']?.toString() ??
        json['email']?.toString() ??
        '';

    // Image URL resolution
    String profileImg = '';
    final candidateKeys = [
      json['profileImageUrl'],
      json['profile_image_url'],
      json['imageUrl'],
      json['image_url'],
      json['photoUrl'],
      json['photo_url'],
      json['avatarUrl'],
      json['avatar'],
      json['image'],
      json['profileUrl'],
      mediaChannel?['logoUrl'],
      mediaChannel?['logo_url'],
      mediaChannel?['logo'],
    ];

    for (final candidate in candidateKeys) {
      if (candidate != null) {
        String str = candidate.toString().trim();
        if (str.isNotEmpty && str != 'null') {
          if (str.startsWith('/')) {
            str = "https://api.pravasamedia.com$str";
          }
          if (str.startsWith('http://') || str.startsWith('https://')) {
            profileImg = str;
            break;
          }
        }
      }
    }

    final socialMap = json['socialMediaProfiles'] is Map<String, dynamic>
        ? json['socialMediaProfiles'] as Map<String, dynamic>
        : null;

    return ReporterModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: designation,
      location: loc,
      state: st,
      category: cat,
      about: json['bio']?.toString() ?? json['about']?.toString() ?? '',
      phone: workPhone,
      email: workEmail,
      whatsapp: workPhone,
      imageUrl: profileImg,
      bureau: bureauStr,
      employeeId: employment?['employeeId']?.toString() ?? '',
      mediaChannelName: mediaChannel?['name']?.toString() ?? '',
      socialMediaProfiles: socialMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'location': location,
      'state': state,
      'category': category,
      'about': about,
      'phone': phone,
      'email': email,
      'whatsapp': whatsapp,
      'imageUrl': imageUrl,
      'bureau': bureau,
      'employeeId': employeeId,
      'mediaChannelName': mediaChannelName,
      'socialMediaProfiles': socialMediaProfiles,
    };
  }
}
