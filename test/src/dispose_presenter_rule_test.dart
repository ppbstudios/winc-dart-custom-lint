import 'package:test/test.dart';
import 'package:winc_dart_custom_lint/src/dispose_presenter.dart';

import 'test_utils.dart';

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

void main() {
  group('MustDisposeRule Tests', () {
    test('reports error for presenter instance outside State class', () async {
      final source = '''
        $presenterClassString
        
        class MyPresenter extends Presenter {}
        
        class NonStateClass {
          final presenter = MyPresenter();
        }
      ''';

      final file = createAnalysisTestFile(source);
      final rule = MustDisposeRule();
      final errors = await rule.testAnalyzeAndRun(file);

      expect(errors, hasLength(1));
      expect(
        errors.first.message,
        equals('Presenter instance should be inside a State class'),
      );
    });

    test('reports error for State class without dispose method', () async {
      final source = '''
        $stateClassString
        $presenterClassString
        
        class MyPresenter extends Presenter {}
        
        class MyState extends State<void> {
          final presenter = MyPresenter();
        }
      ''';

      final file = createAnalysisTestFile(source);
      final rule = MustDisposeRule();
      final errors = await rule.testAnalyzeAndRun(file);

      expect(errors, hasLength(1));
      expect(
        errors.first.message,
        equals('State class with Presenter instance must override dispose'),
      );
    });

    test('reports error for incomplete dispose in State class', () async {
      final source = '''
        $stateClassString
        $presenterClassString
        
        class MyPresenter extends Presenter {}
        
        class MyState extends State<void> {
          final presenter = MyPresenter();
          
          @override
          void dispose() {
            super.dispose();
          }
        }
      ''';

      final file = createAnalysisTestFile(source);
      final rule = MustDisposeRule();
      final errors = await rule.testAnalyzeAndRun(file);

      expect(errors, hasLength(1));
      expect(
        errors.first.message,
        equals('Presenter instance should be disposed'),
      );
    });

    test('reports no error for correct implementation', () async {
      final source = '''
        $stateClassString
        $presenterClassString
        
        class MyPresenter extends Presenter {}
        
        class MyState extends State<void> {
          final presenter = MyPresenter();
          
          @override
          void dispose() {
            presenter.dispose();
            super.dispose();
          }
        }
      ''';

      final file = createAnalysisTestFile(source);
      final rule = MustDisposeRule();
      final errors = await rule.testAnalyzeAndRun(file);

      expect(errors, isEmpty);
    });

    test('handles multiple presenters correctly', () async {
      final source = '''
        $stateClassString
        $presenterClassString
        
        class MyPresenter extends Presenter {}
        
        class MyState extends State<void> {
          final presenter1 = MyPresenter();
          final presenter2 = MyPresenter();
          
          @override
          void dispose() {
            presenter1.dispose();
            // Missing presenter2.dispose()
            super.dispose();
          }
        }
      ''';

      final file = createAnalysisTestFile(source);
      final rule = MustDisposeRule();
      final errors = await rule.testAnalyzeAndRun(file);

      expect(errors, hasLength(1));
      expect(
        errors.first.message,
        equals('Presenter instance should be disposed'),
      );
    });
  });
}
