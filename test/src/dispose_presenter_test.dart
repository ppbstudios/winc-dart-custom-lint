import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_custom_lint_example/src/dispose_presenter.dart';
import 'package:test/test.dart';

// Mock classes to simulate Flutter's State and our Presenter
const stateClassString = '''
abstract class State<T> {
  void dispose();
}
''';

const presenterClassString = '''
abstract class Presenter {
  void dispose();
}
''';

const mockClassString = '''
class MockPresenter extends Presenter {}

class _TestState extends State<void> {
  final MockPresenter presenter = MockPresenter();
  
  @override
  void dispose() {
    presenter.dispose();
    super.dispose();
  }
}

class _TestStateNoDispose extends State<void> {
  final MockPresenter presenter = MockPresenter();
}

class _TestStateIncompleteDispose extends State<void> {
  final MockPresenter presenter = MockPresenter();
  
  @override
  void dispose() {
    super.dispose();
  }
}

class _NonStateClass {
  final MockPresenter presenter = MockPresenter();
}
''';

void main() {
  group('MustDisposeRule', () {
    test('reports presenter outside state class', () async {
      const source = '''
        abstract class State<T> {
          void dispose();
        }
        
        abstract class Presenter {
          void dispose();
        }
        
        class MyPresenter extends Presenter {
          @override
          void dispose() {}
        }
        
        // expect_lint: presenter_instance_outside_state
        class NonStateClass {
          final presenter = MyPresenter();
        }
      ''';

      final rule = MustDisposeRule();
      final result = parseString(
        content: source,
        path: '/test.dart',
        throwIfDiagnostics: false,
      );

      final errors = await rule.testRun(result as ResolvedUnitResult);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'presenter_instance_outside_state');
    });

    test('reports missing dispose method', () async {
      const source = '''
        abstract class State<T> {
          void dispose();
        }
        
        abstract class Presenter {
          void dispose();
        }
        
        class MyPresenter extends Presenter {
          @override
          void dispose() {}
        }
        
        class TestState extends State<void> {
          // expect_lint: presenter_state_missing_dispose
          final presenter = MyPresenter();
        }
      ''';

      final rule = MustDisposeRule();
      final result = parseString(
        content: source,
        path: '/test.dart',
        throwIfDiagnostics: false,
      );

      final errors = await rule.testRun(result as ResolvedUnitResult);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'presenter_state_missing_dispose');
    });

    test('reports presenter not disposed', () async {
      const source = '''
        abstract class State<T> {
          void dispose();
        }
        
        abstract class Presenter {
          void dispose();
        }
        
        class MyPresenter extends Presenter {
          @override
          void dispose() {}
        }
        
        class TestState extends State<void> {
          // expect_lint: presenter_not_disposed
          final presenter = MyPresenter();
          
          @override
          void dispose() {
            super.dispose();
          }
        }
      ''';

      final rule = MustDisposeRule();
      final result = parseString(
        content: source,
        path: '/test.dart',
        throwIfDiagnostics: false,
      );

      final errors = await rule.testRun(result as ResolvedUnitResult);

      expect(errors, hasLength(1));
      expect(errors.first.errorCode.name, 'presenter_not_disposed');
    });

    test('no lint when presenter is properly disposed', () async {
      const source = '''
        abstract class State<T> {
          void dispose();
        }
        
        abstract class Presenter {
          void dispose();
        }
        
        class MyPresenter extends Presenter {
          @override
          void dispose() {}
        }
        
        class TestState extends State<void> {
          final presenter = MyPresenter();
          
          @override
          void dispose() {
            presenter.dispose();
            super.dispose();
          }
        }
      ''';

      final rule = MustDisposeRule();
      final result = parseString(
        content: source,
        path: '/test.dart',
        throwIfDiagnostics: false,
      );

      final errors = await rule.testRun(result as ResolvedUnitResult);

      expect(errors, isEmpty);
    });
  });
}
