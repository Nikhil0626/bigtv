# Zip Puzzle — API-Driven Dynamic Levels (Flutter)

**Purpose:** Replace the hardcoded `ZipCatalog` level definitions with levels fetched from an API, while preserving the existing Zip Puzzle UI, rules, providers, timer, hint engine, completion dialog, and local progress behavior.

**Important implementation constraint:** This document is based on the supplied architecture description, not the source code for `LevelDefinition`, `GridPoint`, `Wall`, `ZipCatalog`, or the Riverpod providers. Their exact constructors and state APIs are therefore not guessed here. The implementation agent must inspect those files before writing the adapter or changing providers. The mapper between the API DTO and the existing `LevelDefinition` is the only place that should need to know the precise constructor signatures.

---

## 1. Target result

After the migration:

1. `ZipLevelSelectionScreen` gets the list of level definitions from the API instead of `ZipCatalog`'s hardcoded 100 levels.
2. Selecting a level fetches (or reuses a validated in-memory copy of) that level's definition from the API and passes the mapped existing `LevelDefinition` into the current gameplay flow.
3. `ZipGameProvider` continues to own the current path, adjacency checks, wall collision checks, checkpoint order validation, undo, hints, timer, pause/resume, and win condition. Do not rewrite those mechanics.
4. `ZipBoardWidget`, `ZipCompletionDialog`, `ZipHowToPlayCard`, `ZipLevelTile`, and all existing visual styling remain in place unless a tiny loading/error state is necessary.
5. `ZipPuzzleRepository` can continue to save progress, hints, best times, and leaderboard data to SharedPreferences while the level catalogue is API-backed. If those records must also become server-authoritative, migrate them separately to explicit backend endpoints. “API-only levels” should not accidentally delete existing local progress support.
6. Do **not** fall back to `ZipCatalog` or bundled JSON if the API fails. Show a retryable error state. This is necessary if the API must be the sole source of level definitions.

## 2. Current modules and intended changes

| Existing module | Intended change |
|---|---|
| `data/models/grid_point.dart` | Keep as the gameplay coordinate model. Add a DTO-to-`GridPoint` mapping only if needed. |
| `data/models/wall.dart` | Keep as the gameplay wall model. Map API wall-edge DTOs to this type. |
| `data/models/level_definition.dart` | Preserve gameplay-facing model and constructors where possible. Add/adjust the remote-to-`LevelDefinition` adapter rather than making every screen parse JSON. |
| `data/repositories/zip_catalog.dart` | Stop using hardcoded levels as the production source. Deprecate/remove static level definitions after all references have migrated. It may only remain as test fixtures if explicitly separated from production code. |
| `data/repositories/zip_puzzle_repository.dart` | Preserve existing progress, hint quota, completion-time, and leaderboard persistence behavior. Do not use it as a level catalogue unless its responsibilities are deliberately refactored. |
| `presentation/providers/zip_catalog_provider.dart` | Make it load/refresh levels via the API repository; retain current progress overlay, unlock state, difficulty tabs, ordering, and completion percentage behavior. |
| `presentation/providers/zip_game_provider.dart` | Keep the gameplay rules intact. Ensure it receives the mapped `LevelDefinition`, not a hardcoded catalog index. |
| `presentation/screens/zip_level_selection_screen.dart` | Add loading, empty, retryable error states using the existing visual style. Keep level cards and difficulty tabs. |
| `presentation/screens/zip_gameplay_screen.dart` | Use the selected level ID/definition to initialize the existing provider. Avoid changing the board UI or gesture flow. |
| `presentation/widgets/*` | Keep visuals and interactions unchanged. Only adjust parameters if required to pass level metadata. |

## 3. Recommended API contract

Use stable IDs instead of relying on list indexes. The following endpoints are a recommended contract; coordinate the exact paths with the backend team. Do not hardcode the base URL in a repository.

### 3.1 Fetch the catalogue

```http
GET /api/v1/games/zip_puzzle/levels?page=1&pageSize=100
Accept: application/json
Authorization: Bearer <token>   # only if required by the API
```

Use this endpoint for the existing 100-level selection screen. The backend should return all available level metadata needed for display and selection. It may return the full `content` for every level or return light metadata and provide the full content through the detail endpoint. Prefer metadata-only catalogue responses if levels become large.

Example metadata response:

```json
{
  "schemaVersion": 1,
  "gameId": "zip_puzzle",
  "gameType": "zip",
  "items": [
    {
      "gameId": "zip_puzzle",
      "gameType": "zip",
      "levelId": "zip_001",
      "levelNumber": 1,
      "title": "First Steps",
      "schemaVersion": 1,
      "difficulty": "easy",
      "grid": { "rows": 4, "columns": 4 },
      "checkpointCount": 3,
      "isPublished": true
    }
  ],
  "page": 1,
  "pageSize": 100,
  "total": 100
}
```

If the app currently expects interleaved difficulties, the API should return the desired order (or return an explicit `sortOrder`). Do not rebuild the production catalogue in Dart merely to reproduce the order.

### 3.2 Fetch a single level

```http
GET /api/v1/games/zip_puzzle/levels/zip_001
Accept: application/json
```

Example full-level response follows in section 4. Use `levelId` for navigation and lookups. Do not assume `levelNumber - 1` is an array index.

### 3.3 Fetch the daily level set (optional if the app has a separate daily mode)

```http
GET /api/v1/games/zip_puzzle/daily-levels?date=2026-10-22
Accept: application/json
```

The backend should define the timezone used to assign a daily puzzle. Prefer the server to return `puzzleDate` and/or `startsAt`/`endsAt`; clients in different time zones should not accidentally receive different “daily” levels unless that is the intended product rule. If the current Zip Puzzle only has the 100-level catalogue, this endpoint is optional and should not be added to the UI until a daily mode is required.

### 3.4 API error response shape

Use a consistent error contract, for example:

```json
{
  "error": {
    "code": "LEVEL_NOT_FOUND",
    "message": "The requested level does not exist."
  }
}
```

Expected handling:

- `400`: invalid query/parameters; log safely and show a recoverable message where appropriate.
- `401`/`403`: run the app's existing auth/session handling; do not display tokens or raw response bodies.
- `404`: selected level no longer exists; refresh the catalogue and show a safe message.
- `429`: respect `Retry-After` if the backend provides it.
- `5xx`, timeout, offline: show retry. Do not silently switch to hardcoded levels.
- Invalid JSON/schema: reject the response and show a data error; do not start a game with partial/invalid rules.

---

## 4. Full level JSON schema

Each playable level must include the required metadata:

- `gameId`: stable identifier for the game collection, e.g. `zip_puzzle`.
- `gameType`: engine type, e.g. `zip`.
- `levelId`: globally stable unique ID for a level, e.g. `zip_001`.
- `levelNumber`: human-facing progression number.
- `title`: display title.
- `schemaVersion`: version of the content schema. Bump this only when the JSON meaning/structure changes incompatibly.
- `content`: data consumed by the current `LevelDefinition` and `ZipGameProvider`.

The names inside `content` below are a recommended API schema. The mapper must convert them into the **existing** `LevelDefinition`, `GridPoint`, and `Wall` classes. If the current classes use different field names or shapes, adapt the mapper—not gameplay algorithms.

```json
{
  "gameId": "zip_puzzle",
  "gameType": "zip",
  "levelId": "zip_001",
  "levelNumber": 1,
  "title": "First Steps",
  "schemaVersion": 1,
  "difficulty": "easy",
  "puzzleDate": "2026-10-22",
  "content": {
    "grid": {
      "rows": 4,
      "columns": 4
    },
    "checkpoints": [
      { "number": 1, "row": 0, "col": 0 },
      { "number": 2, "row": 1, "col": 2 },
      { "number": 3, "row": 3, "col": 3 }
    ],
    "walls": [
      {
        "from": { "row": 0, "col": 1 },
        "to": { "row": 0, "col": 2 }
      },
      {
        "from": { "row": 2, "col": 0 },
        "to": { "row": 3, "col": 0 }
      }
    ],
    "solutionPath": [
      { "row": 0, "col": 0 },
      { "row": 0, "col": 1 },
      { "row": 1, "col": 1 },
      { "row": 1, "col": 0 },
      { "row": 2, "col": 0 },
      { "row": 2, "col": 1 },
      { "row": 2, "col": 2 },
      { "row": 1, "col": 2 },
      { "row": 0, "col": 2 },
      { "row": 0, "col": 3 },
      { "row": 1, "col": 3 },
      { "row": 2, "col": 3 },
      { "row": 3, "col": 3 },
      { "row": 3, "col": 2 },
      { "row": 3, "col": 1 },
      { "row": 3, "col": 0 }
    ],
    "palette": {
      "path": "#5D7CF6",
      "cell": "#EAF0FF",
      "checkpoint": "#FFFFFF",
      "warning": "#E5484D"
    }
  }
}
```

**Do not publish the sample as a verified playable puzzle without validation.** The values illustrate the payload shape; the server-side authoring/validation pipeline must confirm that a solution is a valid Hamiltonian path from checkpoint 1, visits every required cell exactly once, visits checkpoints in ascending order, and does not cross walls. Keep checkpoint and wall coordinate conventions consistent with the existing game: this example uses zero-based `row`/`col` coordinates.

### Wall representation

A wall represents a blocked edge **between two orthogonally adjacent cells**, not a blocked cell. Validate that:

- `from` and `to` are inside the grid;
- the cells are orthogonally adjacent (`abs(Δrow) + abs(Δcol) == 1`);
- a wall is not duplicated in reverse order;
- the game engine's wall comparison treats `A -> B` and `B -> A` as the same edge.

### Content validation before gameplay

Reject a level if any of these fail:

1. `rows` and `columns` are positive and within the supported limits (for example 4–8 only if that matches the current game).
2. Checkpoint numbers are unique, start at `1`, and form a continuous sequence through `N`.
3. All checkpoint, solution, and wall coordinates are inside the grid.
4. The solution path contains exactly `rows * columns` unique cells if every cell is required.
5. Consecutive solution coordinates are orthogonally adjacent and do not cross a wall.
6. The solution starts at checkpoint `1`, visits every numbered checkpoint in ascending order, and contains no repeated coordinate.
7. `schemaVersion` is supported by this app version.
8. Required content fields exist. Optional palette fields can use the existing app palette only if that is currently the documented gameplay default; never invent missing checkpoints, walls, or solution steps.

The runtime may perform lightweight validation. Prefer validating all authored levels on the backend/build pipeline as well, because server-generated invalid puzzles affect every client.

---

## 5. Folder structure to add

Keep the existing feature structure and add only the API/data adapter layers required:

```text
lib/features/zip_puzzle/
├── data/
│   ├── models/
│   │   ├── grid_point.dart                 # existing gameplay model
│   │   ├── wall.dart                       # existing gameplay model
│   │   ├── level_definition.dart           # existing gameplay model
│   │   ├── zip_level_api_model.dart        # new: parses API envelope/DTO
│   │   └── zip_level_content_dto.dart      # new: typed API content DTOs
│   ├── mappers/
│   │   └── zip_level_definition_mapper.dart # new: API DTO -> existing LevelDefinition
│   └── repositories/
│       ├── zip_catalog.dart                # migrate away from as production source
│       ├── zip_puzzle_repository.dart      # existing local progress/hints/etc.
│       └── zip_level_api_repository.dart   # new: HTTP calls for level definitions
├── presentation/
│   ├── providers/
│   │   ├── zip_catalog_provider.dart       # fetches API catalogue
│   │   └── zip_game_provider.dart          # gameplay rules unchanged
│   ├── screens/
│   │   ├── zip_level_selection_screen.dart # same UI + loading/error states
│   │   └── zip_gameplay_screen.dart        # same UI + API level passed to provider
│   └── widgets/                            # keep current widgets
```

Names can be adjusted to the repository's existing conventions. Avoid creating duplicate state-management layers if the app already has a repository/service abstraction.

---

## 6. Dependencies and environment configuration

If `http` is not already in `pubspec.yaml`, add it to the existing `dependencies` section (choose a version compatible with the project's Flutter/Dart SDK; do not duplicate the dependency):

```yaml
dependencies:
  http: ^1.3.0
```

Use the project's existing HTTP client if it already has one (e.g. Dio or a shared `BaseService`); do not add `http` just for this feature if doing so would bypass common interceptors, auth headers, logging, or error handling.

Configure the API base URL at build/run time instead of hardcoding it:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

Read it with:

```dart
const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
```

`https://api.example.com` is a placeholder. Replace it with the real environment URL. If the app already has environment configuration, use that existing configuration instead of adding a second one.

---

## 7. API DTO model

This DTO represents the stable metadata envelope and leaves level-specific content as a map at the boundary. Convert the map into typed DTOs in the next step. Keep JSON parsing out of the UI and gameplay provider.

Create `data/models/zip_level_api_model.dart`:

```dart
class ZipLevelApiModel {
  final String gameId;
  final String gameType;
  final String levelId;
  final int levelNumber;
  final String title;
  final int schemaVersion;
  final String difficulty;
  final Map<String, dynamic> content;

  const ZipLevelApiModel({
    required this.gameId,
    required this.gameType,
    required this.levelId,
    required this.levelNumber,
    required this.title,
    required this.schemaVersion,
    required this.difficulty,
    required this.content,
  });

  factory ZipLevelApiModel.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing or invalid "$key" on level.');
      }
      return value;
    }

    int readInt(String key) {
      final value = json[key];
      if (value is! int || value < 1) {
        throw FormatException('Missing or invalid "$key" on level.');
      }
      return value;
    }

    final rawContent = json['content'];
    if (rawContent is! Map) {
      throw const FormatException('Level content must be a JSON object.');
    }

    return ZipLevelApiModel(
      gameId: readString('gameId'),
      gameType: readString('gameType'),
      levelId: readString('levelId'),
      levelNumber: readInt('levelNumber'),
      title: readString('title'),
      schemaVersion: readInt('schemaVersion'),
      difficulty: readString('difficulty'),
      content: Map<String, dynamic>.from(rawContent),
    );
  }
}

class ZipLevelCatalogueResponse {
  final int schemaVersion;
  final List<ZipLevelApiModel> items;
  final int? total;

  const ZipLevelCatalogueResponse({
    required this.schemaVersion,
    required this.items,
    this.total,
  });

  factory ZipLevelCatalogueResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final schemaVersion = json['schemaVersion'];
    final rawItems = json['items'];

    if (schemaVersion is! int || schemaVersion < 1) {
      throw const FormatException('Invalid catalogue schemaVersion.');
    }
    if (rawItems is! List) {
      throw const FormatException('Catalogue response must contain items.');
    }

    final items = rawItems.map((item) {
      if (item is! Map) {
        throw const FormatException('Catalogue item must be an object.');
      }
      return ZipLevelApiModel.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList(growable: false);

    final rawTotal = json['total'];
    return ZipLevelCatalogueResponse(
      schemaVersion: schemaVersion,
      items: items,
      total: rawTotal is int ? rawTotal : null,
    );
  }
}
```

This DTO expects the catalogue response's `items` array to include `content`. If the backend returns metadata-only items, change the catalogue DTO to parse a separate lightweight summary model and fetch the full content by `levelId` before gameplay. Do not try to parse absent `content` as a full level.

---

## 8. HTTP repository with timeouts and error handling

Create `data/repositories/zip_level_api_repository.dart`. This example uses the `http` package; use your existing shared API client instead if available. The class intentionally exposes data-transfer models. Mapping to `LevelDefinition` belongs in the mapper layer.

```dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/zip_level_api_model.dart';

class ZipLevelApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ZipLevelApiException(
    this.message, {
    this.statusCode,
    this.code,
  });

  @override
  String toString() => message;
}

class ZipLevelApiRepository {
  ZipLevelApiRepository({
    required String baseUrl,
    http.Client? client,
    Map<String, String> Function()? headersProvider,
  })  : _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
        _client = client ?? http.Client(),
        _headersProvider = headersProvider ?? _emptyHeaders;

  final String _baseUrl;
  final http.Client _client;
  final Map<String, String> Function() _headersProvider;

  static Map<String, String> _emptyHeaders() => const {
        'Accept': 'application/json',
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    if (_baseUrl.isEmpty) {
      throw const ZipLevelApiException(
        'The puzzle API URL is not configured.',
      );
    }
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  Future<ZipLevelCatalogueResponse> getCatalogue({
    int page = 1,
    int pageSize = 100,
  }) async {
    final uri = _uri(
      '/api/v1/games/zip_puzzle/levels',
      {
        'page': '$page',
        'pageSize': '$pageSize',
      },
    );

    final response = await _get(uri);
    final json = _decodeObject(response.body);
    return ZipLevelCatalogueResponse.fromJson(json);
  }

  Future<ZipLevelApiModel> getLevelById(String levelId) async {
    if (levelId.trim().isEmpty) {
      throw const ZipLevelApiException('A level ID is required.');
    }

    final encodedId = Uri.encodeComponent(levelId);
    final uri = _uri('/api/v1/games/zip_puzzle/levels/$encodedId');
    final response = await _get(uri);
    final json = _decodeObject(response.body);

    // Accept either a direct level object or { "item": { ... } }.
    final rawLevel = json['item'] ?? json;
    if (rawLevel is! Map) {
      throw const ZipLevelApiException(
        'The API returned an invalid level object.',
      );
    }
    return ZipLevelApiModel.fromJson(
      Map<String, dynamic>.from(rawLevel),
    );
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        ..._headersProvider(),
      };
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      String message = 'Could not load puzzle levels.';
      String? code;
      try {
        final body = _decodeObject(response.body);
        final error = body['error'];
        if (error is Map) {
          if (error['message'] is String) message = error['message'] as String;
          if (error['code'] is String) code = error['code'] as String;
        }
      } catch (_) {
        // Do not expose raw HTML/proxy/server bodies to the player.
      }

      throw ZipLevelApiException(
        message,
        statusCode: response.statusCode,
        code: code,
      );
    } on TimeoutException {
      throw const ZipLevelApiException(
        'The puzzle server took too long to respond. Please retry.',
      );
    } on http.ClientException {
      throw const ZipLevelApiException(
        'Could not connect to the puzzle server. Check your connection and retry.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const ZipLevelApiException(
        'The puzzle server returned an invalid response.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  void close() => _client.close();
}
```

Notes:

- Add the project's existing auth token to `_headersProvider`, or inject the existing authenticated API client. Never store a real bearer token in this file.
- The sample repository uses a 15-second timeout. Align it with the existing app API policy.
- If the app injects a shared `http.Client`, do not close that shared client from a feature repository; ownership and disposal should stay with the DI container.
- `Uri.parse(...).replace(queryParameters: ...)` replaces query parameters on the URL; the sample paths do not include static query parameters.
- If the API's actual response uses `data`, `results`, or another envelope name, adapt parsing to the agreed backend contract rather than adding multiple speculative response formats.

---

## 9. Map API content to the existing gameplay model

**This is the critical compatibility boundary.** `ZipGameProvider` and `ZipBoardWidget` should continue to use the existing `LevelDefinition`, `GridPoint`, and `Wall` classes. They should not receive loosely typed JSON maps.

Create `data/mappers/zip_level_definition_mapper.dart`. Before implementing it, inspect:

- `data/models/level_definition.dart` — constructor and exact fields, including grid dimensions, checkpoint representation, difficulty enum, palette, `solutionPath`, `checkpointCount`, and `totalRequiredCells`;
- `data/models/grid_point.dart` — constructor/property names and equality/hash behavior;
- `data/models/wall.dart` — constructor/property names and wall-edge equality behavior;
- `zip_catalog.dart` — how its current 100 verified levels instantiate these models;
- `zip_game_provider.dart` — which fields it reads for path, walls, hints, and completion.

Then implement one adapter function conceptually shaped like this:

```dart
LevelDefinition mapApiLevelToDefinition(ZipLevelApiModel remote) {
  // 1. Reject unsupported `remote.gameId`, `remote.gameType`, or schemaVersion.
  // 2. Parse remote.content.grid rows/columns.
  // 3. Convert each checkpoint object to the EXISTING checkpoint type.
  // 4. Convert each wall's `from` / `to` coordinates to the EXISTING Wall type.
  // 5. Convert solutionPath coordinates to the EXISTING GridPoint type.
  // 6. Convert/validate difficulty and palette using existing project rules.
  // 7. Construct the existing LevelDefinition with its REAL constructor.
  // 8. Validate the resulting definition before returning it.
  // Do not change game rules or duplicate gameplay state in this mapper.
  throw UnimplementedError('Use actual project constructors here');
}
```

The `throw UnimplementedError` is deliberately a marker, not production code. Replace it after inspecting the actual model constructors. Do not paste guessed `LevelDefinition(...)`, `GridPoint(...)`, or `Wall(...)` arguments without checking source.

### Derive fields consistently

- `checkpointCount`: derive from parsed checkpoint list unless the existing model intentionally stores it.
- `totalRequiredCells`: normally `rows * columns` for this game; confirm how the current model represents blocked/unusable cells before deriving it.
- `solutionPath`: map from API content in path order. The current hint engine depends on it.
- Palette: parse valid API palette values if palette is remotely configurable. If palette is optional, use the existing default/rotation behavior intentionally; do not change `_colorOffset++` behavior during reset.
- Stable identity: add or preserve `levelId` on the gameplay-facing definition if possible. Do not use only `levelNumber` as an identity when saving progress because levels can be reordered or replaced.

### Schema versioning

Reject unsupported schema versions with a clear `UnsupportedLevelSchemaException`. Do not try to “best guess” new fields when a backend schema changes. Keep a small, explicit migration/compatibility layer if old published levels must remain supported.

---

## 10. Provider integration (Riverpod)

The supplied documentation confirms Riverpod providers exist, but does not show whether they use `StateNotifier`, `Notifier`, `AsyncNotifier`, or legacy providers. Preserve the current provider family and public interfaces wherever possible. Do not replace the state-management pattern as part of this migration.

### `ZipCatalogProvider` should do the following

1. On initial load, request catalogue metadata from `ZipLevelApiRepository`.
2. Convert the API catalogue to the provider's current catalogue item model. Keep progress decoration from `ZipPuzzleRepository` separate from server level definitions.
3. Preserve the current interleaved difficulty ordering as returned by the API, or sort by an explicit server `sortOrder` if that is the agreed contract.
4. Compute lock/unlock state from the existing progression policy and stored completions. The backend can optionally return authoritative availability/unlock metadata; define precedence instead of mixing two conflicting sources.
5. Expose loading, success, empty, and error states. On retry, call the repository again.
6. Do not return hardcoded `ZipCatalog.levels` after a failure.
7. Refresh/reload when the screen is revisited if product requirements expect catalogue updates; avoid unnecessary repeated calls on every widget rebuild.

### Gameplay selection flow

Recommended flow:

```text
ZipLevelSelectionScreen
  -> reads ZipCatalogProvider state
  -> user selects unlocked item by levelId
  -> fetch full definition via ZipLevelApiRepository.getLevelById(levelId)
  -> ZipLevelDefinitionMapper creates existing LevelDefinition
  -> existing ZipGameplayScreen receives it through its current entry path
  -> existing ZipGameProvider initializes from that definition
  -> existing ZipBoardWidget renders and manages gestures as before
```

If the catalogue already includes full `content`, it is acceptable to map that item and skip the detail request. Decide based on actual response size and API contract. If you do fetch the detail, show a loading indication during the transition and prevent double taps from pushing multiple gameplay screens.

### Keep the gameplay provider stable

Do not change these behaviors as part of this feature:

- tracing must start on checkpoint `1`;
- orthogonal adjacency only;
- barriers reject a move and show existing feedback;
- no self-intersection;
- dragging to the immediately previous cell backtracks;
- movement can enter a checkpoint out of order, with the existing warning state;
- backtracking/undo clears an invalid checkpoint-order warning when appropriate;
- hints compare the current path against `solutionPath`;
- win condition remains all cells filled + all checkpoints in ascending order + correct-order state;
- stopwatch starts on first valid move and pauses/resumes with app lifecycle;
- time freezes and completion persistence runs once on victory;
- reset retains the current theme rotation behavior.

---

## 11. Level selection and gameplay screen states

The UI should look like the current app. Add states within the existing page layout instead of redesigning it.

### Catalogue screen

- **Loading:** use the app's existing loading indicator/skeleton in the catalogue content area.
- **Success:** render the current 100-level grid, tabs, locked cards, best times, checkmarks, and completion banner.
- **Empty:** display a clear “No levels are available right now” message and a retry action.
- **Error/offline:** display a compact message and Retry action. Do not clear progress or substitute hardcoded levels.
- **Partial page result:** if the backend paginates, fetch all pages needed for the existing 100-level view or add proper paging without silently dropping levels.

### Gameplay entry

- While fetching the selected level, disable repeated taps for that level.
- If the level returns `404`, refresh the catalogue and inform the user that the level is no longer available.
- If the schema/content is invalid, do not instantiate `ZipGameProvider`; show a safe error and provide a back-to-level-selection action.
- Do not create the scoped gameplay provider before the level definition is successfully mapped and validated.

---

## 12. Unlocking and progress ownership

The current app locks levels progressively: Level 1 is open and completing level `k` unlocks `k + 1`. Preserve that rule during the migration.

There are two valid ownership strategies. Choose one with the backend team and do not mix them accidentally:

### Strategy A — API owns level content; app owns progress (least disruptive)

- API: published level definitions, content, titles, difficulty, order, schema versions.
- SharedPreferences through `ZipPuzzleRepository`: completion, personal best, hint quota, and locally cached leaderboard data exactly as today.
- `ZipCatalogProvider`: combines API level list with local progress to decorate cards and calculate locks.
- Limitation: progress may not sync across devices and may be lost on reinstall, depending on current storage behavior.

### Strategy B — Backend owns level content and user progress

Use explicit endpoints for progress, completion submissions, hints, and leaderboard. Backend is authoritative for unlocks and cross-device ranking. Do not add these endpoints to the client until the backend contract exists. Keep local UI responsive, but reconcile server responses and avoid double-counting retries.

The scope requested here can be implemented with Strategy A first. It does not require deleting `ZipPuzzleRepository` or rewriting progress storage.

---

## 13. Daily hints and level schema compatibility

The hint system uses `solutionPath`; therefore every API level that supports hints must return it in exactly the ordered coordinate format expected by the mapper.

- Validate every solution coordinate before gameplay starts.
- Confirm the first solution coordinate equals checkpoint 1.
- Confirm successive coordinates are adjacent and not separated by a wall.
- Confirm all required cells are covered once and checkpoints occur in order.
- Keep the current three-hints-per-calendar-day policy and SharedPreferences key/expiry logic untouched unless the product explicitly changes it.
- Do not download or mutate the solution path after the player starts a level. Use one validated immutable level definition for the duration of that session.
- If daily hint allowance remains local, an API outage must not reset or increase the quota.

---

## 14. API client construction and injection

Use the project's existing dependency injection mechanism. The example below illustrates the desired dependency direction, not the exact provider syntax to paste into this app:

```dart
const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

// Register once in the existing DI/provider setup:
// final zipLevelApiRepositoryProvider = Provider<ZipLevelApiRepository>((ref) {
//   return ZipLevelApiRepository(
//     baseUrl: apiBaseUrl,
//     headersProvider: () => <String, String>{
//       'Accept': 'application/json',
//       // Add the project's current authorization header here if required.
//     },
//   );
// });
```

Do not add a duplicate `ProviderScope`, duplicate HTTP client, or a parallel token store. Reuse existing auth/interceptor/DI conventions.

---

## 15. Remove hardcoded levels safely

Search the full project for usages of `ZipCatalog`, static level lists, and `levelNumber` as an index. Migrate every production caller before deleting the old data:

1. Level selection: source catalogue from API provider.
2. Next Level: resolve the next published level based on the API's declared order/progression, not a local list index.
3. Replay: request/reuse the same `levelId` and reinitialize the existing gameplay provider correctly.
4. Deep links/restoration, if present: resolve by `levelId`, not by array offset.
5. Leaderboard: associate scores with stable `gameId`/`levelId` as well as display `levelNumber` if the current leaderboard supports per-level stats.
6. Hints: use the exact validated solution content for the selected `levelId`.
7. Tests: move sample hardcoded levels to test-only fixtures if they are useful for unit tests. They must not become a production fallback.

Do not delete `ZipCatalog` first. Search call sites, migrate them, run tests/analyzer, then remove or deprecate the production catalog.

---

## 16. Testing plan

### Model and mapper unit tests

- Valid level parses and maps to existing `LevelDefinition`.
- Missing metadata / bad field types are rejected.
- Unsupported `schemaVersion` is rejected.
- Empty checkpoint list is rejected.
- Duplicate or non-sequential checkpoint numbers are rejected.
- Out-of-grid coordinates are rejected.
- Diagonal/non-adjacent solution moves are rejected.
- Wall edges are validated for adjacency and duplicates.
- Repeated solution cells are rejected.
- Solution starts at checkpoint 1, follows checkpoint order, and fills the expected cells.
- Duplicate `levelId` in catalogue is rejected or reported as an API contract failure.

### Repository tests

Mock the HTTP client and test:

- `200` with valid catalogue;
- `200` with valid single-level response;
- `200` with malformed JSON;
- `401`/`403`, `404`, `429`, and `5xx`;
- network exception and timeout;
- empty catalogue;
- pagination;
- invalid API base URL.

### Regression tests for gameplay

Use existing tests and/or manually validate:

- Start point 1 validation;
- orthogonal movement;
- walls;
- self-intersection;
- backtracking and Undo;
- out-of-order checkpoint red warning and recovery;
- Hint rollback and advance;
- hint daily quota persistence;
- timer start, app pause/resume, and exact completion time;
- completion is saved once;
- personal best and next-level action;
- reset color-palette cycling;
- light and dark mode;
- all four difficulty groups and locked/unlocked states.

### Release checks

- No production code path reads level definitions from `ZipCatalog` or a local JSON fallback.
- API URL comes from environment/configuration.
- No tokens or complete raw server response bodies appear in logs or user-facing errors.
- Android and iOS both use the same API contract.
- The app handles offline/API-down scenarios without crashing and without starting malformed levels.

---

## 17. Recommended implementation order

1. Inspect all existing model constructors and the current `ZipCatalog` definitions.
2. Agree on the API contract and publish one validated test level matching it.
3. Add typed API DTOs and the HTTP repository.
4. Add content validation and the mapper to existing `LevelDefinition`.
5. Update `ZipCatalogProvider` to load and combine API levels with existing local progress.
6. Add loading/error/empty/retry UI to `ZipLevelSelectionScreen` without changing the layout.
7. Update game entry, replay, and next-level navigation to use stable `levelId` values.
8. Remove production references to the static catalogue only after all paths have migrated.
9. Run unit tests, `flutter analyze`, Android test, and iOS test.
10. Add monitoring for failed level loads and invalid schemas; never log solution content or auth tokens unnecessarily.

---

## 18. Antigravity implementation prompt

Paste the following prompt into Antigravity with the Flutter repository open. It tells the coding agent to inspect the real files first and make code changes against actual constructors instead of inventing them.

> **Task: Migrate Zip Puzzle levels to API-driven data without redesigning or breaking gameplay.**
>
> Work in the existing Flutter project. Feature root: `lib/features/zip_puzzle/`.
>
> Before changing code, inspect and understand these actual files and all related call sites:
> - `data/models/grid_point.dart`
> - `data/models/wall.dart`
> - `data/models/level_definition.dart`
> - `data/repositories/zip_catalog.dart`
> - `data/repositories/zip_puzzle_repository.dart`
> - `presentation/providers/zip_catalog_provider.dart`
> - `presentation/providers/zip_game_provider.dart`
> - `presentation/screens/zip_level_selection_screen.dart`
> - `presentation/screens/zip_gameplay_screen.dart`
> - `presentation/widgets/zip_board_widget.dart`
> - `presentation/widgets/zip_completion_dialog.dart`
> - tests and every other `ZipCatalog` reference.
>
> Requirements:
> 1. Make the API the sole production source of Zip Puzzle level definitions. Do not use `ZipCatalog` or a local JSON asset as an offline fallback. On API failure, show a retryable error state.
> 2. Use the envelope fields `gameId`, `gameType`, `levelId`, `levelNumber`, `title`, `schemaVersion`, and `content`. Use stable `levelId` for lookup/navigation; do not treat `levelNumber - 1` as an array index.
> 3. Add a typed API DTO, API repository, and mapper/adapter that converts response data into the existing `LevelDefinition`, `GridPoint`, and `Wall` types. You must use their actual constructors and enums found in the code. Do not guess constructors, field names, difficulty enum names, Riverpod provider styles, or screen constructor parameters.
> 4. Use the app's current HTTP client, authentication/interceptors, configuration, and dependency injection if they exist. Otherwise add the smallest suitable HTTP client integration. Read the base URL from the app's existing environment configuration; if none exists, use `String.fromEnvironment('API_BASE_URL')` and document how it is configured. Never hardcode production URLs or tokens.
> 5. Support the catalogue endpoint `GET /api/v1/games/zip_puzzle/levels?page=1&pageSize=100` and single level endpoint `GET /api/v1/games/zip_puzzle/levels/{levelId}`. Adjust paths only if the backend contract supplied in the project differs; document the final paths.
> 6. The full level content must support grid rows/columns, numbered checkpoints, walls as edges between adjacent cells, ordered `solutionPath`, difficulty, and optional palette. Use zero-based row/col coordinates unless existing code proves otherwise. Validate data and reject unsupported schema versions before initializing the gameplay provider.
> 7. Update `ZipCatalogProvider` to fetch catalogue items from the API and combine them with the current local progress records. Preserve difficulty tabs, interleaved level ordering as provided by the server, lock/unlock progression, completion percentage, best times, and completed checks. If pagination exists, handle all pages needed by the current UI.
> 8. Update the gameplay entry, Replay, and Next Level flows to resolve stable `levelId` values and pass a validated mapped `LevelDefinition` through the existing navigation/provider entry path.
> 9. Keep the current gameplay rules and UI exactly intact: Point 1 start, orthogonal adjacency, wall barriers, no self-intersection, previous-cell backtracking, freely enterable out-of-order checkpoints with warning ring, order-warning recovery, Undo, three-per-day hints, `solutionPath` hint behavior, stopwatch/lifecycle pause/resume, exact completion time, save completion once, palette rotation on reset, dark/light themes, and existing completion dialog/actions. Do not reimplement gameplay algorithms.
> 10. Keep `ZipPuzzleRepository` local progress/hint/leaderboard persistence intact unless the current code shows it is already API-backed. This task makes level definitions API-only; do not silently delete or reset stored progress.
> 11. Add loading, empty, error, and retry states in the existing screen layout without redesigning the UI. Do not create the gameplay provider until the selected level has loaded and validated successfully. Prevent rapid double selection from pushing duplicate screens.
> 12. Add tests for DTO parsing, mapper/validation, API success/errors/timeouts/empty catalogue, and critical gameplay regressions. Run `dart format`, `flutter analyze`, and relevant tests. Fix errors introduced by the change.
> 13. Search for every production reference to `ZipCatalog` and remove static catalogue dependency only after every route (selection, next, replay, restoration/deep link if any, hints, leaderboard) is migrated. Static fixtures may remain in tests only.
>
> Deliverables:
> - Implemented code changes, not only a plan.
> - A summary of files changed.
> - The exact request/response shape and base URL configuration used.
> - Any assumptions about backend auth, response envelope, pagination, and schema version.
> - A clear list of tests run and any tests blocked by missing backend access.
>
> If a necessary backend detail is absent, inspect existing API conventions elsewhere in the project and reuse them. Do not fabricate an endpoint or silently invent a model contract; leave the endpoint configurable and document the unresolved detail.

---

## 19. Backend decisions to confirm before production

- Is the catalogue API returning full level content or metadata only?
- Is the level list paginated? Does it return `total` and/or `nextCursor`?
- Is `gameId` always `zip_puzzle`, with `gameType` equal to `zip`, or does the backend use another canonical value?
- Are difficulty and palette values strings, enum values, or structured JSON?
- Is unlock state client-computed from current progress or server-authoritative?
- Are daily puzzle dates based on UTC, India time, or a user-specific timezone?
- Are level contents immutable after publication? If content can change, return a content revision/ETag so progress and active sessions remain consistent.
- Does the endpoint require authentication? Which existing token provider/interceptor should add the header?

Until these decisions are confirmed, the endpoint paths and sample response in this document should be treated as the **proposed contract**, not an assertion that those routes already exist on your server.
