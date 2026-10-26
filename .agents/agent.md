# GEMINI.md — Mandatory Flutter Development Rules

## 1. Instructions for Gemini AI Agents

You are working on an existing Flutter application. This document defines mandatory rules for every code modification, feature implementation, bug fix, API integration, UI change, refactoring task, and optimization.

**These rules take priority over convenience, speed, or generating a quick implementation.**

Before writing or modifying code, you MUST:

1. Read this entire instruction file.
2. Inspect the existing project architecture and coding conventions.
3. Identify the relevant modules, providers, services, assets, fonts, dependencies, and tests.
4. Understand the impact of the requested changes on existing functionality.
5. Follow every applicable rule in this document.
6. Verify the implementation through automated tests, coverage measurement, and static analysis.

Do not assume that code is correct simply because it compiles or appears to work.

Do not claim that a requirement has been satisfied unless you have actually verified it.

If a requirement cannot be fulfilled because of missing tools, permissions, dependencies, or other constraints, explicitly report the limitation and the remaining work.

---

## 2. Absolute Prohibition on `setState()`

**NEVER use `setState()` anywhere in the application.**

This rule applies to all existing and newly created Dart files, including:

- Screens and pages.
- Stateless and stateful widgets.
- Dialogs and bottom sheets.
- Forms and input components.
- Callbacks and event handlers.
- Reusable widgets and components.
- Providers and controllers.
- Services and utility classes.
- Feature modules and shared modules.

### Existing Code Migration

Whenever you encounter existing `setState()` usage:

1. Search for all occurrences throughout the repository.
2. Identify the state being modified and all dependent UI components.
3. Move state ownership and business logic to the appropriate Provider or the project's established state management layer.
4. Replace local state mutation with provider-managed state.
5. Update UI components to observe state and forward user actions to the relevant provider.
6. Add appropriate unit and widget tests.
7. Verify that the existing functionality is preserved.
8. Search the repository again to confirm that prohibited usages have been removed.

Use the existing Provider architecture, including `ChangeNotifier`, `Consumer`, `Selector`, or other patterns already established by the project.

Do not introduce another state management framework without explicit technical justification and approval.

Do not replace `setState()` with another UI-local mutable-state workaround. State must be owned by the appropriate state management layer.

**Acceptance criteria:**

- Zero `setState()` calls in application code.
- No new `setState()` calls under any circumstances.
- Existing occurrences migrated within the required scope.
- State transitions covered by appropriate tests.

---

## 3. Mandatory Architecture

Follow clean architecture and the existing module conventions.

Each applicable feature module must separate data, domain, presentation, and state management responsibilities.

```text
module_name/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── components/
└── providers/
```

Create only the directories and abstractions required by the module. Do not introduce empty folders or unnecessary layers.

Rules:

- `data/`: API communication, data sources, models, serialization, and repository implementations.
- `domain/`: business entities, repository contracts, and use cases where appropriate.
- `presentation/`: screens, widgets, and UI components.
- `providers/`: state management and coordination of business operations.
- Services: isolated, reusable, and independently testable operations.
- Dependencies: maintain clear dependency boundaries and avoid circular dependencies.

Inspect the existing architecture before changing it. Reuse established conventions unless the requested task requires a justified architectural change.

---

## 4. Centralized Theme Management

The application MUST support light and dark themes.

- Store colors centrally in the project's designated constants or theme-token file.
- Use global theme configuration and `ThemeData`/`ColorScheme` where appropriate.
- Never hardcode UI color values directly inside widgets.
- Centralize typography, surface colors, borders, and theme-dependent styles.
- Ensure theme switching updates the entire application.
- Preserve correct contrast and readability in both modes.
- Test important screens and components in both themes.

Do not introduce duplicate color definitions or conflicting theme configurations.

---

## 5. Centralized Font Management

All fonts and typography must be controlled through the existing centralized font utility, such as `utils/fonts/`, and global typography configuration.

- Never define repeated font families and text styles locally in widgets.
- Remove confirmed unused font files, font weights, variants, and registrations.
- Remove obsolete font declarations from `pubspec.yaml`.
- Verify references before deleting font files.
- Preserve fonts used by native configurations, localization, generated code, or dynamic loading.
- Ensure font preference changes propagate throughout the application.
- Test font changes across screens, dialogs, forms, and reusable components.

Do not remove a font solely because its filename appears unused. Verify actual usage first.

---

## 6. Mandatory Asset Cleanup

Inspect and remove all confirmed unused or unnecessary assets.

The audit must include:

- Images, icons, logos, and illustrations.
- SVG files and animations.
- Splash screens and launcher assets.
- Audio, video, and other bundled media.
- Localization resources and static files.
- Duplicate assets and obsolete feature resources.

### Required procedure

1. Inventory project assets and asset declarations.
2. Search Dart code, configuration files, generated code, native platform files, and build scripts for references.
3. Check dynamic asset loading and runtime-generated asset paths.
4. Identify confirmed unused resources.
5. Remove unused files and obsolete declarations.
6. Run tests and relevant build checks.
7. Verify that no resources are missing at runtime.

**Never delete an asset without verifying that it is unused.**

---

## 7. Mandatory Dependency Cleanup

Audit all packages and dependencies declared in `pubspec.yaml`.

- Remove unused direct dependencies.
- Remove obsolete development dependencies when safe.
- Identify duplicate packages and unnecessary functionality.
- Prefer existing project utilities or Flutter SDK capabilities when suitable.
- Check imports, generated code, build scripts, platform integrations, and code-generation requirements before removal.
- Preserve dependencies needed for testing, linting, builds, and CI/CD.
- Resolve dependency conflicts without introducing unnecessary packages.
- Never manually edit generated lockfiles.

After cleanup, execute:

```bash
flutter pub get
flutter analyze
flutter test
```

Run relevant platform builds when necessary.

**Every retained direct dependency must have a clear, verified purpose.**

---

## 8. Mandatory Removal of Unnecessary Code

Remove confirmed dead code, redundant implementations, and obsolete resources encountered during the task.

Examples include:

- Unused classes, functions, methods, variables, and fields.
- Unused imports and exports.
- Dead code and unreachable branches.
- Duplicate business logic.
- Unused widgets and components.
- Obsolete service implementations and API integrations.
- Temporary debugging statements and unnecessary logging.
- Redundant wrappers and unjustified abstractions.
- Obsolete configuration values and feature flags.
- Files belonging to removed features.

Before deletion, check repository-wide references, routing, dependency injection, generated code, platform channels, dynamic registration, and other runtime usage.

Do not remove required functionality or perform risky unrelated refactoring.

Validate cleanup using tests, static analysis, and relevant builds.

---

## 9. Mandatory Automated Testing

**Every meaningful module, function, method, class, UI component, provider, repository, use case, and service MUST have appropriate automated tests.**

Tests must verify actual behavior, not simply execute code to increase coverage.

### Unit tests

Test:

- Business logic and utility functions.
- Provider state transitions and side effects.
- Data transformations and validation.
- Models and serialization.
- Repository behavior.
- Use cases and domain rules.
- Error handling and boundary conditions.

### Widget tests

Test:

- Every screen and reusable UI component.
- Buttons, forms, inputs, dialogs, and bottom sheets.
- Loading, success, empty, and error states.
- Provider-driven UI updates.
- User interactions and validation.
- Light and dark themes.
- Dynamic font behavior where applicable.

### Service and integration tests

Test:

- API request and response handling.
- Repositories and data sources.
- Database operations and persistence.
- Authentication and authorization behavior.
- Network failures, timeouts, and error responses.
- External integrations and platform-dependent behavior.

Use mocks, fakes, and deterministic test environments where appropriate.

Trivial getters, generated files, and simple data holders may be covered through meaningful behavioral tests rather than redundant tests for every line.

Never delete, weaken, or skip tests merely to make a build pass.

---

## 10. Strict Code Coverage: Greater Than 83%

**Overall measured code coverage MUST be strictly greater than 83%.**

Exactly 83% does not satisfy the requirement.

Run:

```bash
flutter test --coverage
```

Inspect the generated `coverage/lcov.info` report using the project's available coverage-reporting tools.

If LCOV is installed, run:

```bash
lcov --summary coverage/lcov.info
```

Requirements:

- Measure coverage across the application codebase, not just selected modules.
- Include meaningful business logic, providers, services, repositories, and presentation logic.
- Add tests whenever coverage falls to 83% or below.
- Maintain a reasonable safety margin above the threshold.
- Do not manipulate coverage percentages by deleting tests or adding unjustified exclusions.
- Document and justify any approved exclusions.
- Run coverage checks after substantial features, integrations, and refactoring.

**A successful test run does not prove that the coverage threshold has been met. Verify the actual reported percentage.**

---

## 11. Mandatory Dart Analysis

Before finalizing any task, run:

```bash
flutter analyze
```

Requirements:

- No unused imports.
- No dead code.
- No unresolved references.
- No new avoidable analyzer warnings.
- No new avoidable lint violations.
- No unnecessary deprecated APIs.
- No disabling lint rules simply to hide problems.

Follow the project's configured lint rules.

Fix issues introduced by your changes. Report pre-existing issues that remain unresolved instead of claiming that the entire project is clean.

---

## 12. Build Size and Performance

Optimize application size and runtime performance without sacrificing correctness.

- Remove unused assets, fonts, and dependencies.
- Avoid bundling unnecessarily large media.
- Use supported release-build optimizations and tree shaking.
- Avoid duplicate libraries and unnecessary native dependencies.
- Prevent unnecessary widget rebuilds.
- Use appropriate Provider selectors and targeted state subscriptions.
- Dispose of owned controllers, streams, and subscriptions.
- Avoid expensive synchronous work on the UI thread.
- Optimize image loading, list rendering, and network requests.
- Use pagination and caching where appropriate.
- Investigate significant release-size increases.
- Validate Android and iOS builds when affected by the changes.

---

## 13. Mandatory Gemini Execution Workflow

For every feature, integration, bug fix, or refactoring task, follow these phases in order.

### Phase A — Inspect

1. Read this instruction file.
2. Inspect the existing implementation.
3. Identify affected modules and dependencies.
4. Search for existing `setState()` usage.
5. Review related tests, assets, fonts, and theme configuration.
6. Identify possible regressions.

### Phase B — Implement

1. Follow the existing architecture.
2. Use centralized state management.
3. Never introduce `setState()`.
4. Centralize theme and typography definitions.
5. Reuse existing components where appropriate.
6. Remove confirmed unnecessary code and resources safely.
7. Maintain error handling and resource disposal.

### Phase C — Test

1. Add unit tests.
2. Add provider and state transition tests.
3. Add widget tests.
4. Add service and integration tests where appropriate.
5. Cover success, failure, and boundary conditions.
6. Execute the relevant test suite.
7. Generate coverage reports.
8. Verify overall coverage is greater than 83%.

### Phase D — Analyze

1. Run `flutter analyze`.
2. Fix issues introduced by the changes.
3. Search for `setState()` across the repository.
4. Review unused imports and dead code.
5. Verify asset, font, and dependency references.
6. Check relevant build configurations.
7. Review potential performance and size regressions.

### Phase E — Verify

Confirm that all applicable requirements are satisfied before declaring completion.

If a check cannot be executed, explicitly state which check was not performed and why.

---

## 14. Required Completion Report

After every task, provide a concise, evidence-based report.

Include:

1. **Implementation:** What changed.
2. **State Management:** Any migration completed and the result of the `setState()` search.
3. **Cleanup:** Assets, fonts, dependencies, and code removed.
4. **Tests:** Tests added or updated.
5. **Test Results:** Executed, passed, failed, and skipped counts.
6. **Coverage:** Actual measured percentage and report location.
7. **Static Analysis:** Actual analyzer result.
8. **Build Verification:** Platforms and build configurations checked.
9. **Outstanding Issues:** Unresolved problems, blockers, and limitations.

Never fabricate command results or claim successful verification without evidence.

---

## 15. Final Non-Negotiable Requirements

1. Zero `setState()` calls in application code.
2. All application state managed by the established state management architecture.
3. Centralized theme and font management.
4. Removal of confirmed unused assets, fonts, dependencies, and code.
5. Appropriate automated tests for every meaningful component and behavior.
6. Overall code coverage strictly greater than 83%.
7. Dart analyzer executed and reviewed before completion.
8. All required tests passing.
9. No unjustified coverage exclusions or disabled lint rules.
10. No regressions introduced by cleanup or refactoring.
11. No fabricated test, coverage, analyzer, or build results.
12. Explicit reporting of any requirement that remains unmet.

## Final Directive to Gemini

Treat this file as a mandatory engineering contract for the project.

**Inspect before editing. Implement using the existing architecture. Test every meaningful behavior. Remove unnecessary resources safely. Measure coverage. Run static analysis. Verify zero `setState()` calls. Report actual results.**

Do not consider a task complete until every applicable requirement has been verified.

No shortcuts or exceptions.