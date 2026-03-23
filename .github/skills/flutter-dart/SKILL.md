---
name: flutter-dart
description: "Flutter & Dart development standards for the strength training app frontend. USE WHEN: writing or reviewing Dart/Flutter code, creating widgets, screens, providers, or services. Covers widget structure, state management with Provider, theming, and mobile best practices."
---

# Flutter & Dart Development Skill

## Context

- **Framework**: Flutter 3.x (Dart ≥ 3.0)
- **State Management**: Provider (ChangeNotifier pattern)
- **Local Storage**: sqflite + path_provider
- **Architecture**: screens → providers → services → models

## Widget Guidelines

- Prefer `StatelessWidget` unless local mutable state is needed.
- Extract reusable widgets into `lib/widgets/`.
- Use `const` constructors wherever possible for performance.
- Keep `build()` methods concise — extract sub-trees into helper methods or separate widgets.
- Always add `super.key` to constructors.

## State Management (Provider)

- One `ChangeNotifier` per domain: exercises, plans, voice, reports.
- Call `notifyListeners()` only after state has actually changed.
- Use `context.read<T>()` for one-shot actions, `context.watch<T>()` or `Consumer<T>` for reactive UI.
- Avoid business logic in widgets — delegate to providers or services.

## Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Private members: prefix with `_`
- Constants: `camelCase` (Dart convention, not SCREAMING_SNAKE)

## Theming

- All colors, text styles, and dimensions from `AppTheme` — never hard-code colors in widgets.
- Use `Theme.of(context)` to access dynamic values.
- Muscle group colors are in `AppTheme.muscleColors`.

## Data Layer

- Models live in `lib/models/` with `toMap()` / `fromMap()` / `copyWith()`.
- Database operations in `DatabaseHelper` singleton — widgets never touch SQLite directly.
- API calls through `ApiService` — providers call services, not widgets.

## Error Handling

- Wrap async service calls in try/catch inside providers.
- Show user-facing errors via `ScaffoldMessenger.of(context).showSnackBar()`.
- Never silently swallow exceptions — at minimum log them.

## Performance

- Use `ListView.builder` for long lists, not `Column` with `for`.
- Avoid rebuilding expensive widgets — use `const`, `Consumer` with targeted scope.
- Dispose controllers and subscriptions in `dispose()`.

## Testing

- Widget tests with `flutter_test` and `WidgetTester`.
- Unit tests for providers and services.
- Mock database and API with fake implementations.
