/// 应用元信息。
///
/// CI 通过 `--dart-define=APP_VERSION=...` 注入发布版本；本地构建默认跟随当前
/// `pubspec.yaml` 的基础版本。升级版本时请同步更新这里的默认值。
const String kAppVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: 'v1.0.1',
);

/// 项目仓库地址。
const String kProjectUrl = 'https://github.com/WenHe233/daolema-app';
