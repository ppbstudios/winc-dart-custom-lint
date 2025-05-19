import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:test/test.dart';
import 'package:winc_dart_custom_lint/src/dispose_presenter.dart';

void main() {
  group('MustDisposeRule Fixes', () {
    test('adds dispose method fix', () async {
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
      parseString(
        content: source,
        path: '/test.dart',
        throwIfDiagnostics: false,
      );

      final fixes = rule.getFixes();
      expect(fixes, hasLength(2));

      // Verify we have both types of fixes
      expect(
        fixes.any((fix) => fix.toString().contains('AddDisposeMethodFix')),
        isTrue,
      );
      expect(
        fixes.any((fix) => fix.toString().contains('AddDisposeCallFix')),
        isTrue,
      );
    });

    test('adds dispose call fix', () async {
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
      parseString(
        content: source,
        path: '/test.dart',
        throwIfDiagnostics: false,
      );

      final fixes = rule.getFixes();
      expect(fixes, hasLength(2));

      // Verify we have both types of fixes
      expect(
        fixes.any((fix) => fix.toString().contains('AddDisposeMethodFix')),
        isTrue,
      );
      expect(
        fixes.any((fix) => fix.toString().contains('AddDisposeCallFix')),
        isTrue,
      );
    });
  });
}
