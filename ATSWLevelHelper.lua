-- ATSW专业升级利器 v1.0.0
-- AdvancedTradeSkillWindow/ATSW2增强插件，显示配方技能等级阈值（橙/黄/绿）
-- 作者：AEPAX
-- 依赖：AdvancedTradeSkillWindow 或 AdvancedTradeSkillWindow2

-- 检测ATSW版本
local ATSW_VERSION = nil
local BUTTON_PREFIX = nil
local BUTTON_COUNT = 23

if ATSW_GetTradeSkillInfo then
    -- ATSW 1.x
    ATSW_VERSION = "ATSW"
    BUTTON_PREFIX = "ATSWSkill"
elseif ATSWFrame then
    -- ATSW 2.x
    ATSW_VERSION = "ATSW2"
    BUTTON_PREFIX = "ATSWRecipe"
else
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ATSW专业升级利器需要AdvancedTradeSkillWindow或AdvancedTradeSkillWindow2插件！|r")
    return
end

-- 全局变量
local VERSION = "1.0.0"
local settings = {
    enabled = true,
    showNumbers = true, -- 显示数字
}
local isInitialized = false

-- 获取当前专业名称（英文）
local function GetCurrentProfessionName()
    local skillName = GetTradeSkillLine()
    if not skillName then
        return nil
    end

    -- 中文到英文的映射
    local professionMap = {
        ["炼金术"] = "Alchemy",
        ["锻造"] = "Blacksmithing",
        ["制皮"] = "Leatherworking",
        ["裁缝"] = "Tailoring",
        ["工程学"] = "Engineering",
        ["附魔"] = "Enchanting",
        ["烹饪"] = "Cooking",
        ["急救"] = "First Aid",
        ["采矿"] = "Mining",
    }

    return professionMap[skillName] or skillName
end

-- 获取当前专业等级
local function GetCurrentProfessionSkill()
    local skillName = GetTradeSkillLine()
    if not skillName then
        return 0
    end

    -- 遍历技能列表找到当前专业
    for i = 1, GetNumSkillLines() do
        local name, _, _, skillLevel = GetSkillLineInfo(i)
        if name == skillName then
            return skillLevel or 0
        end
    end

    return 0
end

-- 通过spell_id获取配方数据
local function GetRecipeDataBySpellID(spellID)
    if not EnhancedRecipeDatabase or not spellID then
        return nil
    end

    local professionName = GetCurrentProfessionName()
    if not professionName then
        return nil
    end

    local recipes = EnhancedRecipeDatabase.recipes[professionName]
    if not recipes then
        return nil
    end

    return recipes[spellID]
end

-- 格式化等级信息显示（只显示黄/绿/灰三个等级）
local function FormatLevelInfo(recipeData, currentSkill)
    if not recipeData or not recipeData.skill_thresholds then
        return ""
    end

    local thresholds = recipeData.skill_thresholds
    local yellow = thresholds.yellow or 0
    local green = thresholds.green or 0
    local gray = thresholds.gray or 0

    if not settings.showNumbers then
        -- 只显示颜色点（橙/黄/绿）
        if currentSkill < yellow then
            return "|cffff8000●|r"  -- 橙色
        elseif currentSkill < green then
            return "|cffffff00●|r"  -- 黄色
        else
            return "|cff40ff40●|r"  -- 绿色
        end
    end

    -- 格式化每个数字：
    -- 第一个数字：两位数前面加空格，后面加空格；三位数不加
    local yellowStr
    if yellow >= 100 then
        yellowStr = string.format("%d", yellow)
    else
        yellowStr = string.format(" %d ", yellow)  -- 前后各加一个空格
    end

    -- 第二个数字：两位数后面加空格，三位数不加
    local greenStr = green >= 100 and string.format("%d", green) or string.format("%d ", green)

    -- 第三个数字：不加空格
    local grayStr = string.format("%d", gray)

    -- 根据当前等级决定每个数字的颜色（橙/黄/绿）
    local yellowColored
    if currentSkill < yellow then
        yellowColored = string.format("|cffff8000%s|r", yellowStr)  -- 橙色
    else
        yellowColored = string.format("|cff808080%s|r", yellowStr)  -- 灰色（已超过）
    end

    local greenColored
    if currentSkill < green then
        greenColored = string.format("|cffffff00%s|r", greenStr)  -- 黄色
    else
        greenColored = string.format("|cff808080%s|r", greenStr)  -- 灰色（已超过）
    end

    local grayColored
    if currentSkill < gray then
        grayColored = string.format("|cff40ff40%s|r", grayStr)  -- 绿色
    else
        grayColored = string.format("|cff808080%s|r", grayStr)  -- 灰色（已超过）
    end

    -- 显示数字（橙/黄/绿，超过的显示灰色）
    return yellowColored .. " " .. greenColored .. " " .. grayColored
end

-- 获取配方的等级信息（主要接口）
local function GetRecipeLevelInfo(index)
    if not index then
        return ""
    end

    local skillName, skillType = GetTradeSkillInfo(index)
    if not skillName or skillType == "header" then
        return ""
    end

    -- 获取当前专业等级
    local currentSkill = GetCurrentProfessionSkill()

    -- 尝试通过spell_id获取配方数据
    -- 首先需要获取spell_id，这里我们通过配方名称匹配
    local professionName = GetCurrentProfessionName()
    if not professionName or not EnhancedRecipeDatabase then
        return ""
    end

    local recipes = EnhancedRecipeDatabase.recipes[professionName]
    if not recipes then
        return ""
    end

    -- 遍历配方查找匹配的名称
    for spellID, recipeData in pairs(recipes) do
        if recipeData.name_cn == skillName or recipeData.name_en == skillName then
            return FormatLevelInfo(recipeData, currentSkill)
        end
    end

    -- 如果没找到，返回简单的颜色标记
    if skillType == "optimal" then
        return "|cffff8000●|r"
    elseif skillType == "medium" then
        return "|cffffff00●|r"
    elseif skillType == "easy" then
        return "|cff40ff40●|r"
    elseif skillType == "trivial" then
        return "|cff808080●|r"
    end

    return ""
end

-- Hook ATSW按钮的SetText方法
local hookedButtons = {}
local originalSetText = {}

local function HookATSWButtonSetText()
    if not settings.enabled then
        return
    end

    -- Hook所有ATSW按钮的SetText方法（支持ATSW和ATSW2）
    for i = 1, BUTTON_COUNT do
        local buttonName = BUTTON_PREFIX .. i
        local button = getglobal(buttonName)
        if button and not hookedButtons[buttonName] then
            -- 保存原始SetText方法
            originalSetText[buttonName] = button.SetText

            -- Hook SetText方法
            button.SetText = function(self, text)
                if not text or text == "" then
                    originalSetText[buttonName](self, text)
                    return
                end

                -- 检查文本中是否已经包含我们的等级信息
                if string.find(text, "|cffff8000") or string.find(text, "●") then
                    originalSetText[buttonName](self, text)
                    return
                end

                -- 从文本中提取配方名称（移除颜色标签和其他信息）
                local recipeName = text
                -- 移除颜色标签
                recipeName = string.gsub(recipeName, "|c%x%x%x%x%x%x%x%x", "")
                recipeName = string.gsub(recipeName, "|r", "")
                -- 移除可能的数量信息 [x/y]
                recipeName = string.gsub(recipeName, "%s*|c.-|r", "")
                recipeName = string.gsub(recipeName, "%s*%[.-%]", "")
                -- 去除首尾空格
                recipeName = string.gsub(recipeName, "^%s*(.-)%s*$", "%1")

                -- 通过配方名称查找等级信息
                local professionName = GetCurrentProfessionName()
                if not professionName or not EnhancedRecipeDatabase then
                    originalSetText[buttonName](self, text)
                    return
                end

                local recipes = EnhancedRecipeDatabase.recipes[professionName]
                if not recipes then
                    originalSetText[buttonName](self, text)
                    return
                end

                -- 遍历配方查找匹配的名称
                local recipeData = nil
                for spellID, data in pairs(recipes) do
                    if data.name_cn == recipeName or data.name_en == recipeName then
                        recipeData = data
                        break
                    end
                end

                if recipeData then
                    -- 获取当前专业等级
                    local currentSkill = GetCurrentProfessionSkill()

                    -- 格式化等级信息
                    local levelInfo = FormatLevelInfo(recipeData, currentSkill)

                    if levelInfo ~= "" then
                        -- 根据ATSW版本使用不同的对齐方式
                        if ATSW_VERSION == "ATSW2" then
                            -- ATSW2: 使用FontString精确测量宽度
                            if not measureText then
                                -- measureText未创建，使用简单的空格
                                text = text .. "  " .. levelInfo
                            else
                                -- 使用隐藏的FontString来测量文本宽度（不影响显示）
                                -- 测量原始文本宽度（移除颜色标签）
                                local cleanText = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
                                cleanText = string.gsub(cleanText, "|r", "")

                                measureText:SetText(cleanText)
                                local textWidth = measureText:GetStringWidth()

                                -- 测量等级信息宽度（移除颜色标签）
                                local cleanLevelInfo = string.gsub(levelInfo, "|c%x%x%x%x%x%x%x%x", "")
                                cleanLevelInfo = string.gsub(cleanLevelInfo, "|r", "")
                                measureText:SetText(cleanLevelInfo)
                                local levelInfoWidth = measureText:GetStringWidth()

                                -- 测量单个空格宽度
                                measureText:SetText(" ")
                                local spaceWidth = measureText:GetStringWidth()

                                -- ATSW2的目标总宽度（文本 + 空格 + 等级信息）
                                local maxTotalWidth = 260  -- 总宽度限制

                                -- 计算需要的空格数
                                if spaceWidth > 0 then
                                    -- 目标：textWidth + padding + levelInfoWidth = maxTotalWidth
                                    local paddingNeeded = maxTotalWidth - textWidth - levelInfoWidth
                                    if paddingNeeded > spaceWidth * 2 then  -- 至少2个空格
                                        local spaceCount = math.floor(paddingNeeded / spaceWidth)
                                        local padding = string.rep(" ", spaceCount)
                                        text = text .. padding .. levelInfo
                                    else
                                        text = text .. "  " .. levelInfo
                                    end
                                else
                                    text = text .. "  " .. levelInfo
                                end
                            end
                        else
                            -- ATSW 1.x: 使用原来的字符串长度计算方式
                            local nameLength = string.len(text)
                            local numberLength = 15  -- 预留最大长度
                            local maxLineLength = 51  -- 一行51个字符
                            local paddingLength = maxLineLength - nameLength - numberLength

                            if paddingLength > 0 then
                                local padding = string.rep(" ", paddingLength)
                                text = text .. padding .. levelInfo
                            else
                                -- 如果名称太长，直接添加一个空格
                                text = text .. " " .. levelInfo
                            end
                        end
                    end
                end

                -- 调用原始SetText
                originalSetText[buttonName](self, text)
            end

            hookedButtons[buttonName] = true
        end
    end
end

-- 创建一个隐藏的FontString用于测量文本宽度
local measureFrame = nil
measureText = nil  -- 全局变量，确保Hook函数能访问

local function CreateMeasureFrame()
    if not measureFrame then
        measureFrame = CreateFrame("Frame", "ATSWLevelHelper_MeasureFrame", UIParent)
        measureFrame:Hide()
        measureText = measureFrame:CreateFontString(nil, "ARTWORK")
        measureText:SetFont("Fonts\\FRIZQT__.ttf", 12)  -- 使用与ATSW2相同的字体和大小
    end
end

-- 初始化函数
local function Initialize()
    if isInitialized then
        return
    end

    -- 检查数据库是否加载
    if not EnhancedRecipeDatabase then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ATSW专业升级利器: 数据库未加载！|r")
        return
    end

    -- 创建测量用的FontString
    CreateMeasureFrame()

    -- Hook ATSW按钮
    HookATSWButtonSetText()

    isInitialized = true
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00ATSW专业升级利器 v" .. VERSION .. " 已加载！|r")
end

-- 事件处理
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "ATSWLevelHelper" then
        -- 延迟初始化，确保所有依赖都已加载
        local initFrame = CreateFrame("Frame")
        local timer = 0
        initFrame:SetScript("OnUpdate", function()
            timer = timer + arg1
            if timer >= 1 then
                Initialize()
                initFrame:SetScript("OnUpdate", nil)
            end
        end)
    elseif event == "TRADE_SKILL_SHOW" then
        -- 每次打开专业窗口时重新Hook
        HookATSWButtonSetText()
    end
end)

-- 斜杠命令
SLASH_ATSWLEVEL1 = "/atswlevel"
SLASH_ATSWLEVEL2 = "/atsw等级"
SlashCmdList["ATSWLEVEL"] = function(msg)
    local command = strlower(msg or "")

    if command == "toggle" or command == "开关" then
        settings.enabled = not settings.enabled
        local status = settings.enabled and "启用" or "禁用"
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00ATSW专业升级利器已" .. status .. "|r")

    elseif command == "numbers" or command == "数字" then
        settings.showNumbers = not settings.showNumbers
        local status = settings.showNumbers and "显示" or "隐藏"
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00等级数字已" .. status .. "|r")

    elseif command == "test" or command == "测试" then
        -- 测试显示功能
        DEFAULT_CHAT_FRAME:AddMessage("=== 测试配方显示功能 ===")
        DEFAULT_CHAT_FRAME:AddMessage("检测到的ATSW版本: " .. (ATSW_VERSION or "未知"))
        DEFAULT_CHAT_FRAME:AddMessage("按钮前缀: " .. (BUTTON_PREFIX or "未知"))

        local tradeskillName = GetTradeSkillLine()
        if not tradeskillName then
            DEFAULT_CHAT_FRAME:AddMessage("请先打开专业窗口")
        else
            DEFAULT_CHAT_FRAME:AddMessage("当前专业: " .. tradeskillName)

            local currentSkill = GetCurrentProfessionSkill()
            DEFAULT_CHAT_FRAME:AddMessage("当前专业等级: " .. currentSkill)

            local professionName = GetCurrentProfessionName()
            DEFAULT_CHAT_FRAME:AddMessage("专业英文名: " .. (professionName or "未知"))

            -- 调试：检查数据库
            if EnhancedRecipeDatabase then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00数据库已加载|r")
                if professionName and EnhancedRecipeDatabase.recipes[professionName] then
                    local count = 0
                    for _ in pairs(EnhancedRecipeDatabase.recipes[professionName]) do
                        count = count + 1
                    end
                    DEFAULT_CHAT_FRAME:AddMessage("数据库中有 " .. count .. " 个" .. professionName .. "配方")
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000数据库中没有找到专业: " .. (professionName or "nil") .. "|r")
                end
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000数据库未加载！|r")
            end

            -- 显示前几个配方的信息
            local numSkills = GetNumTradeSkills()
            DEFAULT_CHAT_FRAME:AddMessage("找到 " .. numSkills .. " 个技能")

            for i = 1, math.min(5, numSkills) do
                local skillName, skillType = GetTradeSkillInfo(i)
                if skillName and skillType ~= "header" then
                    local levelInfo = GetRecipeLevelInfo(i)
                    DEFAULT_CHAT_FRAME:AddMessage(i .. ". " .. skillName .. " -> " .. (levelInfo ~= "" and levelInfo or "无数据"))
                end
            end
        end

    elseif command == "debug" or command == "调试" then
        -- 调试命令：显示API返回的完整数据
        DEFAULT_CHAT_FRAME:AddMessage("=== 调试：API完整数据 ===")
        DEFAULT_CHAT_FRAME:AddMessage("检测到的ATSW版本: " .. (ATSW_VERSION or "未知"))

        local tradeskillName = GetTradeSkillLine()
        if not tradeskillName then
            DEFAULT_CHAT_FRAME:AddMessage("请先打开专业窗口")
        else
            DEFAULT_CHAT_FRAME:AddMessage("当前专业: " .. tradeskillName)

            local numSkills = GetNumTradeSkills()
            DEFAULT_CHAT_FRAME:AddMessage("技能总数: " .. numSkills)
            DEFAULT_CHAT_FRAME:AddMessage("显示前3个配方的完整API数据：")

            for i = 1, math.min(3, numSkills) do
                local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(i)
                if skillName and skillType ~= "header" then
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00--- 配方 " .. i .. " ---|r")
                    DEFAULT_CHAT_FRAME:AddMessage("  名称: " .. (skillName or "nil"))
                    DEFAULT_CHAT_FRAME:AddMessage("  难度类型: " .. (skillType or "nil"))
                    DEFAULT_CHAT_FRAME:AddMessage("  可制作数: " .. tostring(numAvailable or 0))
                    DEFAULT_CHAT_FRAME:AddMessage("  展开状态: " .. tostring(isExpanded))
                    DEFAULT_CHAT_FRAME:AddMessage("  替代动词: " .. (altVerb or "nil"))
                    DEFAULT_CHAT_FRAME:AddMessage("  技能点: " .. tostring(numSkillUps or 0))

                    -- 图标
                    local icon = GetTradeSkillIcon(i)
                    if icon then
                        DEFAULT_CHAT_FRAME:AddMessage("  图标: " .. icon)
                    end

                    -- 冷却时间
                    local cooldown = GetTradeSkillCooldown(i)
                    if cooldown and cooldown > 0 then
                        DEFAULT_CHAT_FRAME:AddMessage("  冷却时间: " .. cooldown .. "秒")
                    end

                    -- 制作数量
                    local minMade, maxMade = GetTradeSkillNumMade(i)
                    if minMade then
                        DEFAULT_CHAT_FRAME:AddMessage("  制作数量: " .. minMade .. "-" .. (maxMade or minMade))
                    end

                    -- 物品链接
                    local itemLink = GetTradeSkillItemLink(i)
                    if itemLink then
                        DEFAULT_CHAT_FRAME:AddMessage("  物品链接: " .. itemLink)
                    end

                    -- 材料信息
                    local numReagents = GetTradeSkillNumReagents(i)
                    if numReagents and numReagents > 0 then
                        DEFAULT_CHAT_FRAME:AddMessage("  材料数量: " .. numReagents)
                        for j = 1, numReagents do
                            local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(i, j)
                            if reagentName then
                                DEFAULT_CHAT_FRAME:AddMessage("    材料" .. j .. ": " .. reagentName .. " x" .. reagentCount .. " (拥有:" .. playerReagentCount .. ")")
                            end
                        end
                    end
                end
            end
        end

    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00ATSW专业升级利器 v" .. VERSION .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("当前兼容版本: " .. (ATSW_VERSION or "未知"))
        DEFAULT_CHAT_FRAME:AddMessage("/atswlevel toggle - 开关插件")
        DEFAULT_CHAT_FRAME:AddMessage("/atswlevel numbers - 切换数字显示")
        DEFAULT_CHAT_FRAME:AddMessage("/atswlevel test - 测试功能")
        DEFAULT_CHAT_FRAME:AddMessage("/atswlevel debug - 查看API完整数据")
    end
end
