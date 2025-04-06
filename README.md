# Mind Play

![Mind Play Logo](mindplay/Assets.xcassets/AppIcon.appiconset/AppIcon-60@2x.png)

Mind Play 是一款专注于认知能力训练的 iOS 应用，通过有趣的游戏帮助用户提升反应速度、注意力和记忆力等认知能力。

## 技术架构

### 开发环境
- 语言: Swift 5.9
- 框架: SwiftUI
- 最低支持版本: iOS 16.0
- 开发工具: Xcode 15

### 项目结构

```
mindplay/
├── Models/             # 数据模型
│   └── GameModel.swift # 游戏类型和数据管理
├── Views/              # 视图组件
│   ├── HomeView.swift  # 主页视图
│   └── ReactionTime/   # 反应时间游戏相关视图
│       ├── ReactionTimeIntroView.swift
│       ├── ReactionTimeGameView.swift
│       └── ReactionTimeResultView.swift
├── Localization/       # 本地化资源
│   ├── Localizable.swift
│   ├── en.lproj/
│   └── zh-Hans.lproj/
└── ContentView.swift   # 应用入口视图
```

### 核心组件

#### GameDataManager
负责游戏数据的管理，包括保存和获取游戏成绩。使用 `UserDefaults` 存储用户的游戏数据。

```swift
class GameDataManager: ObservableObject {
    func saveResult(gameType: GameType, score: Double)
    func getBestScore(for gameType: GameType) -> Double?
}
```

#### 游戏类型
使用枚举定义不同的游戏类型，便于扩展新游戏。

```swift
enum GameType: String, CaseIterable, Identifiable {
    case reactionTime = "Reaction Time"
    // 未来游戏将在此添加
}
```

### 多语言支持

应用支持英文和简体中文，使用系统的本地化机制自动切换语言。

- 使用 `Localizable.strings` 文件存储本地化字符串
- 通过 `NSLocalizedString` 获取当前语言的字符串
- 应用会根据系统语言设置自动切换界面语言

## 游戏介绍

### 反应时间测试 (Reaction Time Test)

测试用户的视觉反应速度，评估用户对视觉刺激的反应时间。

#### 游戏玩法

1. 用户可以选择测试回合数（1, 3, 5 或 10 轮）
2. 游戏开始后，屏幕会先显示红色，提示用户等待
3. 当屏幕变为绿色时，用户需要尽快点击屏幕
4. 系统会记录用户从屏幕变绿到点击的时间（毫秒）
5. 如果用户在屏幕变绿之前点击，会提示"太早了"，需要重新开始该回合
6. 完成所有回合后，系统会显示用户的平均反应时间和每轮成绩

#### 成绩评估

- 小于 200 毫秒：优秀
- 200-250 毫秒：良好
- 250-300 毫秒：平均
- 大于 300 毫秒：低于平均

## 未来计划

以下是计划添加的新游戏类型：

1. **记忆力游戏**：测试用户的短期记忆能力
2. **注意力游戏**：测试用户的注意力和专注力
3. **逻辑思维游戏**：测试用户的逻辑推理能力

## 如何添加新游戏

要添加新游戏，需要执行以下步骤：

1. 在 `GameType` 枚举中添加新游戏类型
2. 为新游戏创建相应的视图文件（介绍、游戏和结果视图）
3. 在 `HomeView` 中的 `destinationView` 方法中添加新游戏的导航逻辑
4. 在本地化文件中添加新游戏相关的字符串

## 贡献

欢迎对 Mind Play 项目进行贡献！如果你有任何问题或建议，请随时联系我。
