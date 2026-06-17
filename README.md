# 导了吗 · daolema

一个**私密、克制、中性**的个人状态记录与统计 App（Flutter，iOS / Android 多平台）。
用 GitHub 风格年度热力图、趋势统计、标签分析与目标管理，帮你安静地观察自己的节奏与习惯——不评判、不说教。

> 本项目由 Claude Design 导出的高保真原型 `导了吗.dc.html` 1:1 实现而来。原型为
> HTML/CSS/JS 编排，这里按"还原视觉、而非照搬原型脚手架"的原则用 Flutter 重建
> （不复刻原型里的手机外框与假状态栏，App 直接铺满真机屏幕）。

## 功能

底部导航四页 + 多个覆盖层：

- **首页**：今天记录了吗？· 今日/本周/本月次数 · 距上次 · 一键「记录一次」· 本周目标进度 · 年度热力图（53 周横向滚动）· 最近一次记录
- **日历**：月历翻月 · 每日次数色点 · 选中日详情（编辑/删除/补录）
- **统计**：7/30/90/今年区间 · 6 项总览 · 趋势折线 · 星期分布 · 时间段分布 · 标签排行 · 间隔统计
- **设置**：外观浅/深切换 · 主色调四色 · App 锁 / Face ID / 伪装模式 / 模糊通知 · 立即锁定 · 标签管理 · 导出 CSV/JSON · 导入 · 加密备份 · 目标设置 · 清空数据
- **记录弹窗**：日期/时间/次数 · 标签多选 · 心情&压力 1–5 · 备注
- **隐私锁**：6 位密码点阵 + 数字键盘 + Face ID
- **伪装模式**：开启后名称→「习惯记录」、首页→「今天状态如何？」、通知文案同步切换

主题：**浅色（暖纸张）/ 深色（暖墨）** 双主题 + **森绿 / 墨蓝 / 藕紫 / 琥珀** 四套主色调（连热力图同步换色）。
标题与数字用 Noto Serif SC（思源宋体），正文用系统字体。

## 技术栈

- **Flutter**（iOS / Android，附带 web 与 windows 目标便于调试）
- 状态管理：`provider` + `ChangeNotifier`（`AppController`）
- 本地持久化：**drift（SQLite）** 存记录 · `shared_preferences` 存设置/目标/标签 · `flutter_secure_storage` 存锁屏 PIN（本地优先，数据不出本机）
- 矢量图标：`flutter_svg`（沿用原型 SVG path）

## 运行

```bash
flutter pub get
dart run build_runner build      # 生成 drift 代码（已提交，改表结构后重跑）
flutter run                      # 选择 iOS 模拟器 / Android 设备
```

- **iOS / Android**：开箱即用（drift 使用各平台原生 SQLite）。
- **Windows 桌面**（本地快速验证）：`flutter run -d windows`。
- **Web**：drift 在 web 上需要 `sqlite3.wasm` 与 `drift_worker.js` 放入 `web/` 目录后才能持久化，默认未附带。

## 目录结构

```
lib/
  main.dart                  入口：初始化 DB/prefs、首跑写入演示数据、注入 Provider
  app.dart                   MaterialApp + RootShell（Stack 组装页面/覆盖层/锁屏/Toast）
  theme/                     palette(双主题+四主色派生) · app_theme(字体)
  data/
    db/                      drift Records 表
    models/                  RecordEntry · Goals · AppSettings
    repositories/            记录仓库(drift) · 设置仓库(prefs+secure)
    seed/                    mulberry32 演示数据生成
  state/app_controller.dart  全局状态 + 行为 + 持久化（移植自原型 renderVals）
  util/                      日期 · 统计/热力图纯函数 · SVG 图标
  widgets/                   iOS 开关/分组卡/分段切换/进度条/logo/底部导航/Toast
  features/                  home / calendar / stats / settings / record / overlays / lock
test/                        纯逻辑单测（算法与调色板）
```

## 数据与隐私

- 数据**仅保存在本机**（SQLite + 本地 key-value）。
- 首次启动写入约一年的种子演示数据（基于固定随机种子，可复现）；可在设置页「清空全部数据」清除。
- 锁屏当前沿用原型行为（任意 6 位或 Face ID 解锁），已预留真实 PIN 校验接口。
- 数据导出/导入/加密备份当前为提示占位（与原型一致），可在此基础上接入真实文件读写。

## CI

`.github/workflows/build.yml`：push / PR 时在 GitHub Actions 上自动 `flutter analyze` + `flutter test` + 打 release APK 并上传产物；macOS runner 校验 iOS 可编译。
