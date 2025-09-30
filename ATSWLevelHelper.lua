-- ATSW专业升级利器 v1.0.0
-- AdvancedTradeSkillWindow增强插件，显示配方技能等级阈值（橙/黄/绿）
-- 作者：AEPAX
-- 依赖：AdvancedTradeSkillWindow

-- 检查依赖插件
if not ATSW_GetTradeSkillInfo then
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ATSW专业升级利器需要AdvancedTradeSkillWindow插件！|r")
    return
end

-- 全局变量
local VERSION = "3.0.0"
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

    -- Hook所有ATSW技能按钮的SetText方法
    for i = 1, 23 do
        local buttonName = "ATSWSkill" .. i
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

                -- 检查是否已经添加过等级信息（避免重复添加）
                if string.find(text, "|cffff8000") or string.find(text, "●") then
                    originalSetText[buttonName](self, text)
                    return
                end

                -- 获取按钮对应的实际配方索引
                local recipeIndex = self:GetID()
                if not recipeIndex or recipeIndex == 0 then
                    originalSetText[buttonName](self, text)
                    return
                end

                -- 获取配方信息
                local skillName, skillType = GetTradeSkillInfo(recipeIndex)
                if skillName and skillType ~= "header" then
                    -- 获取等级信息
                    local levelInfo = GetRecipeLevelInfo(recipeIndex)
                    if levelInfo ~= "" then
                        -- 计算需要填充的空格数，使数字靠右对齐
                        -- 数字部分最多占15个字符（" 30  " + " " + "30  " + " " + "300"）
                        local nameLength = string.len(text)
                        local numberLength = 15  -- 预留最大长度
                        local maxLineLength = 51  -- 一行51个字符（往后挪3位）
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

                -- 调用原始SetText
                originalSetText[buttonName](self, text)
            end

            hookedButtons[buttonName] = true
        end
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
        DEFAULT_CHAT_FRAME:AddMessage("/atswlevel toggle - 开关插件")
        DEFAULT_CHAT_FRAME:AddMessage("/atswlevel numbers - 切换数字显示")
        DEFAULT_CHAT_FRAME:AddMessage("/atswlevel test - 测试功能")
        DEFAULT_CHAT_FRAME:AddMessage("/atswlevel debug - 查看API完整数据")
    end
end
