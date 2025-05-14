part of '../dispose_presenter.dart';

/// Helper Method:
/// Check if the class is subclass of [State]
@protected
bool isStateSubClass(InterfaceType? node) {
  InterfaceType? curr = node;

  while (curr != null) {
    if (curr.element.name == 'State') return true;
    curr = curr.superclass;
  }

  return false;
}

/// Helper Method:
/// Check if the instance's type is subclass of [Presenter]
@protected
bool isPresenterSubType(DartType? node) {
  if (node is! InterfaceType) return false;

  InterfaceType? curr = node;

  while (curr != null) {
    if (curr.element.name == 'Presenter') return true;
    curr = curr.superclass;
  }

  return false;
}

/// Helper Method:
/// Get all presenter instance from [ClassDeclaration]
@protected
Iterable<VariableDeclaration> getPresenterInstance(ClassDeclaration node) =>
    node.members
        .whereType<FieldDeclaration>()
        .expand((f) => f.fields.variables)
        .where((v) => isPresenterSubType(v.declaredElement?.type));

/// Helper Method:
/// Check if the class has dispose method
///
/// returns `null` when [dispose] is not found
@protected
bool? hasDisposeMethod(ClassDeclaration node) {
  final fields = getPresenterInstance(node);
  if (fields.isEmpty) return null;

  final disposeMethod = node.members
      .whereType<MethodDeclaration>()
      .firstWhereOrNull(
        (m) =>
            m.name.lexeme == 'dispose' &&
            m.declaredElement?.hasOverride == true,
        // m.metadata.any((a) => a.name.name == 'override'),
      );

  if (disposeMethod == null) return null;

  final source = disposeMethod.body.toSource();
  for (final field in fields) {
    final name = field.name.lexeme;
    final called = RegExp(
      r'\b' + RegExp.escape(name) + r'\.dispose\(\)',
    ).hasMatch(source);

    if (!called) return false;
  }

  return true;
}
