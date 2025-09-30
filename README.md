# ATSW Level Helper

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/AEPAX/ATSWLevelHelper/releases)
[![WoW](https://img.shields.io/badge/WoW-1.12-orange.svg)](https://turtle-wow.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**ATSW Level Helper** is an enhancement addon for [AdvancedTradeSkillWindow](https://github.com/refaim/AdvancedTradeSkillWindow) on Turtle WoW. It displays skill level thresholds (Orange/Yellow/Green) for each recipe in the tradeskill window, helping you quickly identify which recipes are best for leveling your profession.

[中文说明](#中文说明) | [English](#english)

---

## English

### Features

- 🎨 **Color-Coded Thresholds**: Displays three skill level thresholds for each recipe
  - **Orange**: Level when recipe turns yellow
  - **Yellow**: Level when recipe turns green
  - **Green**: Level when recipe turns gray
- 🔄 **Dynamic Coloring**: Thresholds you've already passed are shown in gray
- 📊 **Comprehensive Database**: 1,577 recipes covering all 9 professions
- 🌐 **Full Chinese Translation**: 100% recipe name translation
- ⚡ **Lightweight**: No performance impact, seamless integration with ATSW
- 📏 **Right-Aligned Display**: Numbers are neatly aligned on the right side

### Requirements

- **World of Warcraft 1.12** (Turtle WoW)
- **AdvancedTradeSkillWindow** addon (required dependency)

### Installation

1. Download the latest release from [Releases](https://github.com/AEPAX/ATSWLevelHelper/releases)
2. Extract the `ATSWLevelHelper` folder to your `World of Warcraft/Interface/AddOns/` directory
3. Make sure **AdvancedTradeSkillWindow** is also installed
4. Launch the game and enable both addons in the character selection screen

### Usage

1. Open any tradeskill window (e.g., Blacksmithing, Alchemy, Cooking)
2. The addon will automatically display level thresholds next to each recipe name
3. Use slash commands for configuration:
   - `/atswlevel` - Show help
   - `/atswlevel toggle` - Enable/disable the addon
   - `/atswlevel numbers` - Toggle number display on/off
   - `/atswlevel test` - Test functionality (shows info for first 5 recipes)
   - `/atswlevel debug` - Show detailed API data

### Example

```
Minor Healing Potion    55  75  95
```
- **55** (Orange): Recipe turns yellow at skill level 55
- **75** (Yellow): Recipe turns green at skill level 75
- **95** (Green): Recipe turns gray at skill level 95

If your current skill is 80, it will display:
```
Minor Healing Potion    55  75  95
                       (gray)(yellow)(green)
```

### Supported Professions

- Alchemy
- Blacksmithing
- Leatherworking
- Tailoring
- Engineering
- Enchanting
- Cooking
- First Aid
- Mining (smelting)

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Credits

- **Author**: AEPAX
- **Data Source**: [Turtle WoW Database](https://database.turtle-wow.org/)
- **Dependency**: [AdvancedTradeSkillWindow](https://github.com/refaim/AdvancedTradeSkillWindow)

### Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/AEPAX/ATSWLevelHelper/issues) on GitHub.

---

## 中文说明

### 功能特性

- 🎨 **彩色等级阈值**：为每个配方显示三个技能等级阈值
  - **橙色**：配方变黄的等级
  - **黄色**：配方变绿的等级
  - **绿色**：配方变灰的等级
- 🔄 **动态着色**：已超过的等级显示为灰色
- 📊 **完整数据库**：1,577个配方，覆盖全部9个专业
- 🌐 **完整中文翻译**：100%配方名称翻译
- ⚡ **轻量级**：无性能影响，与ATSW无缝集成
- 📏 **右对齐显示**：数字整齐地对齐在右侧

### 系统要求

- **魔兽世界 1.12**（乌龟服）
- **AdvancedTradeSkillWindow** 插件（必需依赖）

### 安装方法

1. 从 [Releases](https://github.com/AEPAX/ATSWLevelHelper/releases) 下载最新版本
2. 将 `ATSWLevelHelper` 文件夹解压到 `魔兽世界/Interface/AddOns/` 目录
3. 确保同时安装了 **AdvancedTradeSkillWindow** 插件
4. 启动游戏，在角色选择界面启用两个插件

### 使用方法

1. 打开任意专业技能窗口（如锻造、炼金、烹饪等）
2. 插件会自动在每个配方名称后显示等级阈值
3. 使用斜杠命令进行配置：
   - `/atswlevel` - 显示帮助
   - `/atswlevel toggle` - 开关插件功能
   - `/atswlevel numbers` - 切换数字显示/隐藏
   - `/atswlevel test` - 测试功能（显示前5个配方信息）
   - `/atswlevel debug` - 显示详细API数据

### 示例

```
初级治疗药水    55  75  95
```
- **55**（橙色）：技能等级55时配方变黄
- **75**（黄色）：技能等级75时配方变绿
- **95**（绿色）：技能等级95时配方变灰

如果你当前技能等级是80，将显示为：
```
初级治疗药水    55  75  95
              (灰色)(黄色)(绿色)
```

### 支持的专业

- 炼金术
- 锻造
- 制皮
- 裁缝
- 工程学
- 附魔
- 烹饪
- 急救
- 采矿（熔炼）

### 贡献

欢迎贡献！请随时提交 Pull Request。

### 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

### 致谢

- **作者**：AEPAX
- **数据来源**：[乌龟服数据库](https://database.turtle-wow.org/)
- **依赖插件**：[AdvancedTradeSkillWindow](https://github.com/refaim/AdvancedTradeSkillWindow)

### 支持

如果遇到问题或有建议，请在 GitHub 上 [提交 issue](https://github.com/AEPAX/ATSWLevelHelper/issues)。

---

## Changelog

### v1.0.0 (2025-09-30)
- 🎉 Initial release
- ✅ 1,577 recipes with 100% Chinese translation
- ✅ Orange/Yellow/Green color-coded thresholds
- ✅ Dynamic coloring for passed thresholds
- ✅ Right-aligned number display
- ✅ Support for all 9 professions

