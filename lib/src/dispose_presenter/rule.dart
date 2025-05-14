part of '../dispose_presenter.dart';

class MustDisposeRule extends clb.DartLintRule {
  const MustDisposeRule() : super(code: _outOfState);

  static const clb.LintCode _outOfState = clb.LintCode(
    name: 'presenter_instance_outside_state',
    problemMessage:
        'Presenter instance should be declared in StatefulWidget\'s State class',
  );

  static const clb.LintCode _noDispose = clb.LintCode(
    name: 'presenter_state_missing_dispose',
    problemMessage: 'Presenter instance should be disposed',
  );

  static const clb.LintCode _notDisposed = clb.LintCode(
    name: 'presenter_not_disposed',
    problemMessage: 'Presenter instance should be disposed',
  );

  @override
  void run(
    clb.CustomLintResolver resolver,
    ErrorReporter reporter,
    clb.CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final isState = isStateSubClass(node.declaredElement?.thisType);

      final presenterInstances = getPresenterInstance(node);
      if (presenterInstances.isEmpty) return;

      final hasDispose = hasDisposeMethod(node);

      for (final instance in presenterInstances) {
        /// If the [Presenter] instance is in the [State] class,
        if (!isState) {
          reporter.reportError(
            AnalysisError.forValues(
              source: resolver.source,
              offset: instance.offset,
              length: instance.length,
              errorCode: _outOfState,
              message: _outOfState.problemMessage,
            ),
          );
          continue;
        }

        /// If the [Presenter] instance is not disposed,
        if (hasDispose == null) {
          reporter.reportError(
            AnalysisError.forValues(
              source: resolver.source,
              offset: instance.offset,
              length: instance.length,
              errorCode: _noDispose,
              message: _noDispose.problemMessage,
            ),
          );
          continue;
        }

        /// If the [Presenter] instance is not disposed,
        if (hasDispose == false) {
          reporter.reportError(
            AnalysisError.forValues(
              source: resolver.source,
              offset: instance.offset,
              length: instance.length,
              errorCode: _notDisposed,
              message: _notDisposed.problemMessage,
            ),
          );
        }
      }
    });
  }

  @override
  List<String> get filesToAnalyze => ['**/*.dart'];

  @override
  List<clb.Fix> getFixes() => [_AddDisposeMethodFix(), _AddDisposeCallFix()];
}

class _AddDisposeMethodFix extends clb.DartFix {
  _AddDisposeMethodFix();

  @override
  void run(
    clb.CustomLintResolver resolver,
    clb.ChangeReporter reporter,
    clb.CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add dispose method',
        priority: 10,
      );

      changeBuilder.addDartFileEdit((builder) {
        final presenterInstances = getPresenterInstance(node);
        final disposeStatements = presenterInstances
            .map((instance) => '    ${instance.name.lexeme}.dispose();')
            .join('\n');

        final code = '''

  @override
  void dispose() {
$disposeStatements
    super.dispose();
  }
''';

        builder.addInsertion(node.rightBracket.offset, (builder) {
          builder.write(code);
        });
      });
    });
  }
}

class _AddDisposeCallFix extends clb.DartFix {
  _AddDisposeCallFix();

  @override
  void run(
    clb.CustomLintResolver resolver,
    clb.ChangeReporter reporter,
    clb.CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final disposeMethod = node.members
          .whereType<MethodDeclaration>()
          .firstWhereOrNull(
            (m) =>
                m.name.lexeme == 'dispose' &&
                m.declaredElement?.hasOverride == true,
          );

      if (disposeMethod == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add dispose call',
        priority: 10,
      );

      changeBuilder.addDartFileEdit((builder) {
        final body = disposeMethod.body;
        if (body is! BlockFunctionBody) return;

        final block = body.block;
        final statements = block.statements;

        final superCall = statements.lastWhereOrNull(
          (stmt) => stmt.toString().trim().startsWith('super.dispose()'),
        );

        final insertionOffset = superCall?.offset ?? block.leftBracket.end;

        final presenterInstances = getPresenterInstance(node);
        final disposeStatements =
            presenterInstances
                .map((instance) => '    ${instance.name.lexeme}.dispose();\n')
                .join();

        builder.addInsertion(insertionOffset, (builder) {
          builder.write(disposeStatements);
        });
      });
    });
  }
}
