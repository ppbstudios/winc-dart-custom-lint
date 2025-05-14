part of '../dispose_presenter.dart';

clb.PluginBase createPlugin() => _DisposePresenterPlugin();

class _DisposePresenterPlugin extends clb.PluginBase {
  @override
  List<clb.LintRule> getLintRules(clb.CustomLintConfigs _) => [
    const MustDisposeRule(),
  ];
}
