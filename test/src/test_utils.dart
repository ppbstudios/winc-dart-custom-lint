import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

CompilationUnit parseTestSource(String content) {
  return parseString(
    content: content,
    featureSet: FeatureSet.latestLanguageVersion(),
  ).unit;
}

String createTestSource(List<String> declarations) {
  return declarations.join('\n\n');
}

File createAnalysisTestFile(String content) {
  final source = parseTestSource(content);
  final path = 'test/src/test_file.dart';
  final file = File(path);
  file.writeAsStringSync(source.toSource());
  return file;
}
