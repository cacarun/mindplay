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
│   ├── ReactionTime/   # 反应时间游戏相关视图
│   │   ├── ReactionTimeIntroView.swift
│   │   ├── ReactionTimeGameView.swift
│   │   └── ReactionTimeResultView.swift
│   └── SequenceMemory/ # 序列记忆游戏相关视图
│       ├── SequenceMemoryIntroView.swift
│       ├── SequenceMemoryGameView.swift
│       └── SequenceMemoryResultView.swift
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
    case sequenceMemory = "Sequence Memory"
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

### 序列记忆测试 (Sequence Memory Test)

测试用户的短期记忆能力，评估用户记忆和重复模式的能力。

#### 游戏玩法

1. 用户可以选择宫格大小（2×2、3×3 或 4×4）
2. 游戏开始后，系统会按顺序点亮一系列按钮
3. 用户需要按照相同的顺序点击这些按钮
4. 每成功完成一轮，序列会增加一个新的按钮
5. 如果用户点错顺序，游戏结束
6. 系统记录用户成功记忆的最长序列长度

#### 成绩评估

- 长度 >= 12：优秀
- 长度 9-11：良好
- 长度 6-8：平均
- 长度 < 6：需要提高

## 标准游戏流程与页面布局

为保持应用内各游戏的一致性和良好用户体验，所有游戏均应遵循以下标准流程和布局规范：

### 游戏流程

每个游戏均包含三个主要页面，按以下顺序展示：

1. **介绍页面 (IntroView)**：介绍游戏玩法，显示最佳成绩，提供游戏选项和开始按钮
2. **游戏页面 (GameView)**：实际游戏进行的页面，提供交互元素和游戏状态显示
3. **结果页面 (ResultView)**：游戏结束后显示成绩、评级和统计信息，提供重新开始和返回主菜单选项

### 页面布局规范

#### 介绍页面 (IntroView) 布局

1. **标题区域**：
   - 大标题：游戏名称，使用largeTitle字体
   - 副标题：简短的游戏描述，使用subheadline字体和次要颜色

2. **选项区域**：
   - 置于游戏说明前
   - 包含在带圆角和阴影的卡片式容器内
   - 选项按钮横向排列，等宽分布，占满整个卡片宽度
   - 选中状态使用蓝色背景和白色文字，未选中状态使用淡蓝色背景

3. **最佳成绩和开始按钮**：
   - 并排放置在同一个带圆角和阴影的卡片内
   - 最佳成绩显示在左侧
   - 开始按钮设置在右侧，使用蓝色背景和白色文字

4. **游戏说明**：
   - 包含游戏玩法和规则的详细说明
   - 使用清晰的章节标题和简洁的文字描述

#### 游戏页面 (GameView) 布局

1. **状态区域**：
   - 显示当前游戏状态（如等级、回合、得分等）
   - 位于屏幕顶部，清晰可见

2. **游戏区域**：
   - 占据屏幕主要部分
   - 交互元素设计合理，符合人体工程学
   - 提供清晰的视觉反馈

3. **控制区域**：
   - 包含必要的游戏控制按钮（如适用）
   - 位于屏幕底部，便于操作

#### 结果页面 (ResultView) 布局

1. **成绩展示**：
   - 主要成绩使用大字体突出显示
   - 包含表现评级（优秀、良好、平均等）

2. **统计区域**：
   - 显示详细的游戏统计信息
   - 使用图表或其他可视化方式展示数据

3. **解释区域**：
   - 提供成绩意义的解释
   - 可能包含提高建议

4. **操作按钮**：
   - 包含"再玩一次"和"返回菜单"按钮
   - 位于屏幕底部，便于操作

## 如何添加新游戏

要添加新游戏，需要执行以下步骤并遵循上述标准：

1. 在 `GameType` 枚举中添加新游戏类型
2. 为新游戏创建相应的视图文件（介绍、游戏和结果视图）
3. 确保遵循标准游戏流程和页面布局规范
4. 在 `HomeView` 中的 `destinationView` 方法中添加新游戏的导航逻辑
5. 在本地化文件中添加新游戏相关的字符串

