# ATSW Level Helper

魔兽世界乌龟服专业技能升级辅助插件,为 [AdvancedTradeSkillWindow](https://github.com/refaim/AdvancedTradeSkillWindow) 和 AdvancedTradeSkillWindow2 添加配方等级阈值显示功能。

**同时支持 ATSW 1.x 和 ATSW 2.x！**

[中文说明](#中文说明) | [English](#english)

---

## English

### Introduction

**ATSW Level Helper** is an addon for Turtle WoW that enhances [AdvancedTradeSkillWindow](https://github.com/refaim/AdvancedTradeSkillWindow) and AdvancedTradeSkillWindow2 by displaying skill level thresholds (Orange/Yellow/Green) for each recipe, helping you efficiently level your professions.

**Supports both ATSW 1.x and ATSW 2.x!** The addon automatically detects which version you have installed.

### Requirements

- **Turtle WoW**
- **AdvancedTradeSkillWindow** or **AdvancedTradeSkillWindow2** addon

### Files

- `ATSWLevelHelper.lua` - Main addon code
- `ATSWLevelHelper.toc` - Addon metadata
- `EnhancedRecipeDatabase.lua` - Recipe database (1,577 recipes with Chinese translations)
- `LICENSE` - MIT License
- `README.md` - This file
- `使用说明.txt` - Chinese instructions

### Supported Professions

- Alchemy (炼金术)
- Blacksmithing (锻造)
- Leatherworking (制皮)
- Tailoring (裁缝)
- Engineering (工程学)
- Enchanting (附魔)
- Cooking (烹饪)
- First Aid (急救)
- Mining - Smelting only (采矿-熔炼)

### Usage

1. Install **AdvancedTradeSkillWindow** or **AdvancedTradeSkillWindow2** and **ATSWLevelHelper**
2. Open any tradeskill window
3. Level thresholds (Orange/Yellow/Green) will appear next to each recipe name


### Commands

- `/atswlevel` - Show help
- `/atswlevel toggle` - Enable/disable addon
- `/atswlevel numbers` - Toggle number display
- `/atswlevel test` - Test with first 5 recipes
- `/atswlevel debug` - Show API data

---

## 中文说明

### 简介

**ATSW Level Helper** 是魔兽世界乌龟服的专业技能辅助插件,为 [AdvancedTradeSkillWindow](https://github.com/refaim/AdvancedTradeSkillWindow) 和 AdvancedTradeSkillWindow2 添加配方等级阈值显示,帮助你高效冲专业等级。

**同时支持 ATSW 1.x 和 ATSW 2.x！** 插件会自动检测你安装的版本。

### 系统要求

- **魔兽世界乌龟服**
- **AdvancedTradeSkillWindow** 或 **AdvancedTradeSkillWindow2** 插件

### 文件说明

- `ATSWLevelHelper.lua` - 主程序文件
- `ATSWLevelHelper.toc` - 插件描述文件
- `EnhancedRecipeDatabase.lua` - 配方数据库(1,577个配方,含中文翻译)
- `LICENSE` - MIT许可证
- `README.md` - 本文件
- `使用说明.txt` - 中文使用说明

### 支持的专业

- 炼金术 (Alchemy)
- 锻造 (Blacksmithing)
- 制皮 (Leatherworking)
- 裁缝 (Tailoring)
- 工程学 (Engineering)
- 附魔 (Enchanting)
- 烹饪 (Cooking)
- 急救 (First Aid)
- 采矿-熔炼 (Mining - Smelting)

### 使用方法

1. 安装 **AdvancedTradeSkillWindow** 或 **AdvancedTradeSkillWindow2** 和 **ATSWLevelHelper** 两个插件
2. 打开任意专业技能窗口
3. 配方名称后会自动显示等级阈值（橙/黄/绿）


### 命令

- `/atswlevel` 或 `/atsw等级` - 显示帮助
- `/atswlevel toggle` 或 `/atswlevel 开关` - 开关插件
- `/atswlevel numbers` - 切换数字显示
- `/atswlevel test` - 测试前5个配方
- `/atswlevel debug` - 显示API数据

---

**作者:** AEPAX | **数据来源:** [乌龟服数据库](https://database.turtle-wow.org/) | **许可证:** MIT
