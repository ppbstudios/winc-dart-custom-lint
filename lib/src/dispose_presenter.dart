import 'package:analyzer/dart/ast/ast.dart'
    show
        ClassDeclaration,
        FieldDeclaration,
        MethodDeclaration,
        VariableDeclaration,
        BlockFunctionBody;
import 'package:analyzer/dart/element/type.dart' show DartType, InterfaceType;
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart' as clb;
import 'package:meta/meta.dart' show protected;

part 'dispose_presenter/helper.dart';
part 'dispose_presenter/lint.dart';
part 'dispose_presenter/meta.dart';
part 'dispose_presenter/rule.dart';
