# CMS (React) & App (Flutter) Integration Guide: Polls & Movie Reviews

This document provides the complete end-to-end technical specification for **Polls** and **Movie Reviews** in Big TV / ChotaNews.
* **CMS Side**: Written for **React** developers building the admin/publishing dashboard.
* **App Side**: Written for **Flutter** developers integrating feed rendering, voting, and rating submission in the mobile application.

---

## 1. Architecture Overview

### Post Types & SubTypes
Both Polls and Movie Reviews are standard posts managed via the unified news posts engine, but carry special subtypes and fields:

| Feature | `type` | `subType` | Primary Fields |
| :--- | :--- | :--- | :--- |
| **Poll Post** | `"Standard"` or `"Poll"` | `"Poll"` or `"Polls"` | `title`, `poll_options`, `content`, `image_url` |
| **Movie Review Post** | `"Standard"` or `"Reviews"` | `"Reviews"` or `"MovieReview"` | `title`, `chotarating`, `externalRatings`, `content`, `image_url` |

---

## 2. API Endpoints Summary

### CMS Endpoints (React)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/news-posts/` | Create a new Poll or Movie Review post |
| `PUT` | `/news-posts/{post_id}` | Update an existing post |
| `GET` | `/news-posts/{post_id}` | Fetch post details for CMS editing |

### App Endpoints (Flutter)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/allposts` | Main feed; returns hydrated `pollData` or `chotaMeter` |
| `GET` | `/posts/{post_id}` | Single post view; returns hydrated poll/review details |
| `POST` | `/polls/submit` | Submit or update a user's poll vote & optional comment |
| `GET` | `/polls/{post_id}/results` | Live poll vote counts, percentages, and user vote status |
| `GET` | `/polls/{post_id}` | Paginated poll comments and option percentages |
| `POST` | `/moviereviews/submit` | Submit or update a user star rating (1–5) and review |
| `GET` | `/moviereviews/{post_id}` | Overall user rating, critic rating, external platform ratings & reviews |

---

# Part 1: React CMS Integration Guide

---

### A. Poll Post in React CMS

#### 1. React State Structure
```javascript
const [pollPost, setPollPost] = useState({
  title: "",
  content: "",
  type: "Standard",
  subType: "Poll",
  category_ids: [],
  language_code: "te", // or 'en', 'hi', 'ml'
  image_url: "",
  draft: false,
  poll_options: [
    { option: 1, option_name: "" },
    { option: 2, option_name: "" }
  ]
});
```

#### 2. Backend Validation Rules (Enforced by API)
* `poll_options` must contain **at least 2 options**.
* Each option must contain an `option` (or `id`) integer and `option_name` (or `text`) non-empty string.
* Returning HTTP `400` / `422` if validation fails.

#### 3. React Form Helper Functions
```javascript
// Add a new poll option
const addOption = () => {
  const nextId = pollPost.poll_options.length + 1;
  setPollPost(prev => ({
    ...prev,
    poll_options: [...prev.poll_options, { option: nextId, option_name: "" }]
  }));
};

// Remove an option (minimum 2 options kept)
const removeOption = (indexToRemove) => {
  if (pollPost.poll_options.length <= 2) {
    alert("A poll requires at least 2 options.");
    return;
  }
  const filtered = pollPost.poll_options
    .filter((_, idx) => idx !== indexToRemove)
    .map((opt, idx) => ({ ...opt, option: idx + 1 }));
  setPollPost(prev => ({ ...prev, poll_options: filtered }));
};

// Update option text
const updateOptionText = (index, text) => {
  const updated = [...pollPost.poll_options];
  updated[index].option_name = text;
  setPollPost(prev => ({ ...prev, poll_options: updated }));
};
```

#### 4. API Request Payload (`POST /news-posts/`)
```json
{
  "title": "Who will win the upcoming AP Assembly Debate?",
  "content": "Share your opinion on the recent political developments.",
  "type": "Standard",
  "subType": "Poll",
  "language_code": "te",
  "category_ids": [1],
  "image_url": "https://pub-r2.bigtvlive.com/news/banner.jpg",
  "poll_options": [
    { "option": 1, "option_name": "Ruling Party" },
    { "option": 2, "option_name": "Opposition Coalition" },
    { "option": 3, "option_name": "Neutral / Undecided" }
  ],
  "draft": false
}
```

---

### B. Movie Review Post in React CMS

#### 1. React State Structure
```javascript
const [moviePost, setMoviePost] = useState({
  title: "Devara Movie Review & Rating",
  content: "Full detailed review of NTR Jr's action thriller Devara Part 1.",
  type: "Standard",
  subType: "Reviews",
  language_code: "te",
  category_ids: [5], // Entertainment
  image_url: "https://pub-r2.bigtvlive.com/movies/devara.jpg",
  chotarating: "3.5/5", // Critic rating given by Big TV editorial team
  externalRatings: [
    { platform_name: "IMDb", platform_rating: "7.8/10" },
    { platform_name: "BookMyShow", platform_rating: "82%" },
    { platform_name: "Rotten Tomatoes", platform_rating: "75%" }
  ],
  draft: false
});
```

#### 2. Backend Validation Rules (Enforced by API)
* `chotarating` is **mandatory** for movie reviews (format: `"3.5/5"` or `"3.5"`).
* `externalRatings` is optional. When provided, it must be a list of objects with `platform_name` and `platform_rating`.

#### 3. React Form Helper Functions
```javascript
// Add external rating row
const addExternalRating = () => {
  setMoviePost(prev => ({
    ...prev,
    externalRatings: [...prev.externalRatings, { platform_name: "", platform_rating: "" }]
  }));
};

// Update platform name or score
const updatePlatformRating = (index, field, value) => {
  const updated = [...moviePost.externalRatings];
  updated[index][field] = value;
  setMoviePost(prev => ({ ...prev, externalRatings: updated }));
};

// Remove external rating
const removePlatformRating = (index) => {
  setMoviePost(prev => ({
    ...prev,
    externalRatings: prev.externalRatings.filter((_, idx) => idx !== index)
  }));
};
```

#### 4. API Request Payload (`POST /news-posts/`)
```json
{
  "title": "Devara Movie Review & Analysis",
  "content": "Director Koratala Siva delivers an intense coastal action drama with NTR in top form.",
  "type": "Standard",
  "subType": "Reviews",
  "language_code": "te",
  "category_ids": [5],
  "image_url": "https://pub-r2.bigtvlive.com/movies/devara_review.jpg",
  "chotarating": "3.5/5",
  "externalRatings": [
    { "platform_name": "IMDb", "platform_rating": "7.8/10" },
    { "platform_name": "BookMyShow", "platform_rating": "84%" }
  ],
  "draft": false
}
```

---

# Part 2: Flutter App Integration Guide

---

### A. Data Models (Dart)

```dart
// --- Poll Models ---

class PollOption {
  final int id;
  final String text;
  final int votes;
  final double percentage;

  PollOption({
    required this.id,
    required this.text,
    required this.votes,
    required this.percentage,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] ?? json['option'] ?? 0,
      text: json['text'] ?? json['option_name'] ?? '',
      votes: json['votes'] ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PollData {
  final int totalVotes;
  final bool userHasVoted;
  final int? userVotedOption;
  final List<PollOption> options;

  PollData({
    required this.totalVotes,
    required this.userHasVoted,
    this.userVotedOption,
    required this.options,
  });

  factory PollData.fromJson(Map<String, dynamic> json) {
    var rawOpts = json['options'] as List? ?? [];
    return PollData(
      totalVotes: json['totalVotes'] ?? 0,
      userHasVoted: json['userHasVoted'] ?? false,
      userVotedOption: json['userVotedOption'],
      options: rawOpts.map((o) => PollOption.fromJson(o)).toList(),
    );
  }
}

// --- Movie Review Models ---

class PlatformRating {
  final String platformName;
  final String platformRating;

  PlatformRating({required this.platformName, required this.platformRating});

  factory PlatformRating.fromJson(Map<String, dynamic> json) {
    return PlatformRating(
      platformName: json['platform_name'] ?? '',
      platformRating: json['platform_rating'] ?? '',
    );
  }
}

class MovieReviewDetails {
  final double overallRating;
  final double? criticRating;
  final List<PlatformRating> platformRatings;
  final int totalReviews;

  MovieReviewDetails({
    required this.overallRating,
    this.criticRating,
    required this.platformRatings,
    required this.totalReviews,
  });

  factory MovieReviewDetails.fromJson(Map<String, dynamic> json) {
    var rawRatings = json['movie_platform_ratings'] as List? ?? [];
    return MovieReviewDetails(
      overallRating: (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      criticRating: (json['critic_rating'] as num?)?.toDouble(),
      platformRatings: rawRatings.map((r) => PlatformRating.fromJson(r)).toList(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}
```

---

### B. Feed Handling in Flutter (`/allposts` or `/posts/{id}`)

When the app fetches the feed (`POST /allposts`), the backend automatically checks `subType`:

#### 1. If `post['subType'] == 'Poll'` or `'Polls'`
The feed item contains:
```json
{
  "id": 1050,
  "title": "Who will win the upcoming AP Assembly Debate?",
  "subType": "Poll",
  "pollData": {
    "totalVotes": 1420,
    "userHasVoted": true,
    "userVotedOption": 1,
    "options": [
      { "id": 1, "text": "Ruling Party", "votes": 852, "percentage": 60.0 },
      { "id": 2, "text": "Opposition Coalition", "votes": 426, "percentage": 30.0 },
      { "id": 3, "text": "Neutral / Undecided", "votes": 142, "percentage": 10.0 }
    ]
  },
  "topComments": [
    {
      "userName": "Ramesh",
      "userPhoto": "https://...",
      "comment": "Debate was very insightful",
      "createdAt": "2026-11-02T10:00:00Z"
    }
  ]
}
```

#### 2. If `post['subType'] == 'Reviews'`
The feed item contains:
```json
{
  "id": 1051,
  "title": "Devara Movie Review & Analysis",
  "subType": "Reviews",
  "chotaMeter": "3.5/5",
  "chotarating": "3.5/5",
  "externalRatings": [
    { "platform_name": "IMDb", "platform_rating": "7.8/10" },
    { "platform_name": "BookMyShow", "platform_rating": "84%" }
  ],
  "reviewCount": 48,
  "userHasReviewed": false,
  "userRating": null,
  "topComments": []
}
```

---

### C. Flutter Interactive Logic: Poll Voting

#### 1. Submitting a Vote (`POST /polls/submit`)
```dart
Future<bool> submitPollVote({
  required int postId,
  required int userId,
  required int selectedOption,
  String? comment,
}) async {
  final url = Uri.parse('$baseUrl/polls/submit');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'post_id': postId,
      'user_id': userId,
      'selected_option': selectedOption,
      'comment': comment,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}
```

#### 2. Refreshing Live Poll Results (`GET /polls/{post_id}/results`)
```dart
Future<PollData> fetchLivePollResults(int postId, {int? userId}) async {
  final queryParams = userId != null ? '?user_id=$userId' : '';
  final url = Uri.parse('$baseUrl/polls/$postId/results$queryParams');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return PollData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load poll results');
  }
}
```

#### 3. Flutter UI Flow for Polls:
* If `pollData.userHasVoted == false`: Show clickable radio/button options.
* When user taps an option: Call `submitPollVote(...)`.
* Immediately update state: Set `userHasVoted = true`, `userVotedOption = selectedOption`, and display animated horizontal percentage bars (`LinearProgressIndicator` or custom bar with percentage text).

---

### D. Flutter Interactive Logic: Movie Review & Ratings

#### 1. Submitting a User Rating (`POST /moviereviews/submit`)
```dart
Future<bool> submitMovieReview({
  required int postId,
  required int userId,
  required int rating, // 1 to 5
  String? comment,
  String? deviceId,
}) async {
  final url = Uri.parse('$baseUrl/moviereviews/submit');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'post_id': postId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'device_id': deviceId,
    }),
  );

  return response.statusCode == 200;
}
```

#### 2. Fetching Review Details & Critic Breakdown (`GET /moviereviews/{post_id}`)
```dart
Future<MovieReviewDetails> fetchMovieReviewDetails(int postId, {String sortBy = 'newest'}) async {
  final url = Uri.parse('$baseUrl/moviereviews/$postId?sort_by=$sortBy&limit=50');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return MovieReviewDetails.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load movie review breakdown');
  }
}
```

#### 3. Flutter UI Flow for Movie Reviews:
* **Critic Badge (Big TV ChotaMeter)**: Displayed prominently at top of the card using `post['chotaMeter']` or `criticRating` (e.g. `⭐ 3.5 / 5`).
* **External Scores Row**: Horizontal pill list displaying `externalRatings` (`IMDb: 7.8/10`, `BookMyShow: 84%`).
* **User Rating Section**: 5 interactive stars allowing the user to tap and submit their score + optional review comment dialog.
* **Audience Average**: Display `overallRating` (e.g. `⭐ 4.1 / 5 (Based on 148 user reviews)`).

---

## 3. Summary of Backend Files Modified
1. [`data/models.py`](file:///c:/Users/anush/OneDrive/Documents/GitHub/BigTvBackend/data/models.py): Added `chotarating` and `externalRatings` to `AbstractNewsPost` and updated `to_dict()`.
2. [`services/news_posts.py`](file:///c:/Users/anush/OneDrive/Documents/GitHub/BigTvBackend/services/news_posts.py): Added `poll_options` and `chotarating`/`externalRatings` validation rules, schemas, and persistence logic for CMS publishing.
3. [`services/movie_reviews.py`](file:///c:/Users/anush/OneDrive/Documents/GitHub/BigTvBackend/services/movie_reviews.py): Made critic rating extraction flexible (`3.5/5` or `3.5`).
4. [`services/allposts.py`](file:///c:/Users/anush/OneDrive/Documents/GitHub/BigTvBackend/services/allposts.py) & [`services/postsbyID.py`](file:///c:/Users/anush/OneDrive/Documents/GitHub/BigTvBackend/services/postsbyID.py): Added default fallback to critic score for movie reviews.
5. [`scheduler/scheduled_posts.py`](file:///c:/Users/anush/OneDrive/Documents/GitHub/BigTvBackend/scheduler/scheduled_posts.py): Supported `chotarating` and `externalRatings` on scheduled publications.

