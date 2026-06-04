# Flutter Project Rules (agent.md)

## Purpose
This file defines mandatory development rules for the Flutter project. 
Every time an integration prompt or feature request is given, these rules MUST be followed strictly.

---

## 1. State Management Rule
- ❌ Do NOT use `setState` across the entire project.
- ✅ All business logic must be moved to the relevant Provider / State Management layer.
- UI should only render state, NOT manage it.

---

## 2. Theme Management (Light & Dark Mode)
- Application MUST support both Light and Dark themes.
- ❌ Do NOT define colors directly inside widgets.
- ✅ All colors must be stored in a single constants file.
- Theme should be accessed globally via Theme configuration.

---

## 3. Module Structure
Each module in the project MUST follow a consistent structure:

- data/
- domain/
- presentation/
- providers/

Ensure separation of concerns is strictly maintained.

---

## 4. Font Management
- All fonts must be managed under a central utility (utils/fonts).
- ❌ Do NOT define fonts locally in widgets.
- ✅ When user updates font settings, it must reflect across the entire application dynamically.

---

## 5. Code Optimization
- Code must be clean, minimal, and maintainable.
- Remove unnecessary widgets, files, and dependencies.
- Optimize for performance and reduced app size.

---

## 6. Build Optimization
- Ensure application build size is minimized.
- Remove unused assets and dependencies.
- Use tree shaking effectively.

---

## 7. Dart Analyzer Rules
- Always run Dart Analyzer before finalizing code.
- ❌ No unused imports.
- ❌ No dead code.
- ❌ No warnings or lint issues.
- ✅ Follow standard linting rules strictly.

---

## 8. General Rules
- Follow clean architecture principles.
- Maintain scalability and reusability.
- Write modular and testable code.
- Maintain consistency across the entire project.

---

## Final Note
Every integration, feature, or prompt must be aligned with these rules.
No exceptions are allowed.
