<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# Forked Repository
이 Repository는 `Presenter` 클래스를 사용할 때 필요한 규칙들을 검사하는 linter를 제공하는 Repository를 fork한 것입니다.
기존 규칙들을 그대로 유지하면서, 추후 winc에 필요한 custom lint 규칙들을 추가할 수 있도록 했습니다.

# Flutter Presenter Dispose Lint Rules

A custom lint rule package for Flutter that enforces proper disposal of Presenter instances in StatefulWidget's State classes. This package helps prevent memory leaks by ensuring Presenters are correctly disposed when the State is disposed.

## Features

This package provides a custom lint rule that checks for:

1. **Presenter Location** (`presenter_instance_outside_state`)
   - Ensures Presenter instances are only declared within State classes
   - Prevents accidental usage of Presenters in non-State classes

2. **Dispose Method Existence** (`presenter_state_missing_dispose`)
   - Verifies that State classes containing Presenter instances override the dispose method
   - Helps maintain proper cleanup practices

3. **Proper Disposal** (`presenter_not_disposed`)
   - Checks if all Presenter instances are properly disposed in the State's dispose method
   - Prevents memory leaks from undisposed Presenters

### Quick Fixes

The package also provides automatic fixes:

- Automatically adds a dispose method with proper Presenter disposal
- Adds missing dispose calls for Presenter instances in existing dispose methods

## Getting Started

1. Add the package to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: ^0.7.0
  winc_dart_custom_lint:
    git:
      url: https://github.com/your_username/winc_dart_custom_lint
```

2. Create or update your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - presenter_instance_outside_state
    - presenter_state_missing_dispose
    - presenter_not_disposed
```

## Usage

The lint rules will automatically check your code. Here's an example of proper usage:

```dart
class MyPresenter extends Presenter {
  void doSomething() {
    // Presenter logic
  }
  
  @override
  void dispose() {
    // Cleanup resources
    super.dispose();
  }
}

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // ✅ Presenter instance in State class
  final MyPresenter _presenter = MyPresenter();

  @override
  void dispose() {
    // ✅ Properly dispose the presenter
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Common Issues and Fixes

1. **Presenter Outside State**
   ```dart
   // ❌ Wrong: Presenter in non-State class
   class SomeClass {
     final presenter = MyPresenter();
   }
   ```

2. **Missing Dispose Method**
   ```dart
   // ❌ Wrong: No dispose method
   class _MyWidgetState extends State<MyWidget> {
     final presenter = MyPresenter();
   }
   ```

3. **Incomplete Disposal**
   ```dart
   // ❌ Wrong: Presenter not disposed
   class _MyWidgetState extends State<MyWidget> {
     final presenter = MyPresenter();
     
     @override
     void dispose() {
       super.dispose(); // Missing presenter.dispose()
     }
   }
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
