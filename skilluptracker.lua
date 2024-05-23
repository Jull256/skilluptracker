addon.name      = 'skilluptracker';
addon.author    = 'Jull - Original by Mujihina';
addon.version   = '1.01';
addon.desc      = 'Displays current decimal and cap in skillup messages.';
addon.link      = 'https://github.com/Jull256/skilluptracker/';

require('common');
local settings = require('settings');
local chat = require('chat');
local grades = require('job_grades')
local skills = require('skills');

local defaults = T{
    skills = T{};
    skillup_colors = { 213, 210, 167 };
    cap_color = 220;
}

local skilluptracker = {
    Settings = settings.load(defaults),
    Player = AshitaCore:GetMemoryManager():GetPlayer();
};

-- Calculate max skill level based on grade and job level
local function calculate_max(level, grade)
    if (grade == "Z" or level == 0) then return 0 end
    if (grade == "A+") then
        if (level < 51) then return level*3 + 3 end
        if (level < 61) then return level*5 - 97 end
        if (level < 71) then return math.floor (level*4.85 - 88) end
        if (level < 81) then return level*5 - 99 end
        if (level < 91) then return level*6 - 179 end
        return level*7 - 269
    end
    if (grade == "A-") then
        if (level < 51) then return level*3 + 3 end
        if (level < 61) then return level*5 - 97 end
        if (level < 71) then return math.floor(level*4.1 - 43) end
        if (level < 81) then return level*5 - 106 end
        if (level < 91) then return level*6 - 186 end
        return level*7 - 276
    end
    if (grade == "B+") then
        if (level < 51) then return math.floor(level*2.9 + 2.101)  end
        if (level < 61) then return math.floor(level*4.9 - 98)  end
        if (level < 71) then return math.floor(level*3.7 - 26) end
        if (level < 73) then return level*4 - 47 end        
        if (level < 81) then return level*5 - 119 end
        if (level < 91) then return level*6 - 199 end        
        return level*7 - 289
    end
    if (grade == "B") then
        if (level < 51) then return math.floor(level*2.9 + 2.101)  end
        if (level < 61) then return math.floor(level*4.9 - 98)  end
        if (level < 71) then return math.floor(level*3.23 + 2.2) end
        if (level < 74) then return level*4 - 52 end
        if (level < 81) then return level*5 - 125 end
        if (level < 91) then return level*6 - 205 end
        return level*7 - 295
    end
    if (grade == "B-") then
        if (level < 51) then return math.floor(level*2.9 + 2.101)  end
        if (level < 61) then return math.floor(level*4.9 - 98)  end
        if (level < 71) then return math.floor(level*2.7 + 34) end
        if (level < 74) then return level*3 + 13 end
        if (level < 76) then return level*4 - 60 end
        if (level < 81) then return level*5 - 135 end        
        if (level < 91) then return level*6 - 215 end
        return level*7 - 305
    end
    if (grade == "C+") then
        if (level < 51) then return math.floor(level*2.8 + 2.201) end
        if (level < 61) then return math.floor(level*4.8 - 98) end
        if (level < 71) then return math.floor(level*2.5 + 40) end
        if (level < 76) then return level*3 + 5 end
        if (level < 81) then return level*5 - 145 end
        if (level < 91) then return level*6 - 225 end
        return level*7 - 315
    end
    if (grade == "C") then
        if (level < 51) then return math.floor(level*2.8 + 2.201) end
        if (level < 61) then return math.floor(level*4.8 - 98) end
        if (level < 71) then return math.floor(level*2.25 + 55) end
        if (level < 76) then return math.floor(level*2.6 + 30) end
        if (level < 81) then return level*5 - 150 end
        if (level < 91) then return level*6 - 230 end
        return level*7 - 320        
    end
    if (grade == "C-") then
        if (level < 51) then return math.floor(level*2.8 + 2.201) end
        if (level < 61) then return math.floor(level*4.8 - 98) end
        if (level < 71) then return level*2 + 70 end
        if (level < 76) then return level*2 + 70 end
        if (level < 81) then return level*5 - 155 end
        if (level < 91) then return level*6 - 235 end
        return level*7 - 325        
    end
    if (grade == "D") then
        if (level < 51) then return math.floor(level*2.7 + 1.3) end
        if (level < 61) then return math.floor(level*4.7 - 99) end
        if (level < 71) then return math.floor(level*1.85 + 72) end
        if (level < 76) then return math.floor(level*1.7 + 83) end
        if (level < 81) then return level*4 - 90 end
        if (level < 91) then return level*5 - 170 end
        return level*6 - 260
    end
    if (grade == "E") then
        if (level < 51) then return math.floor(level*2.5 + 1.5) end
        if (level < 61) then return math.floor(level*4.5 - 99) end
        if (level < 76) then return level*2 + 50 end
        if (level < 81) then return level*3 - 25 end
        if (level < 91) then return level*4 - 105 end
        return level*5 - 195
    end
    if (grade == "F") then    
        if (level < 51) then return math.floor(level*2.3 + 1.701) end
        if (level < 61) then return math.floor(level*4.3 - 99) end
        if (level < 81) then return math.floor(level*2 + 39) end
        if (level < 91) then return level*3 - 41 end
        return level*4 - 131
    end
    if (grade == "G") then
        if (level < 51) then return level*2 + 1 end
        if (level < 71) then return level*3 - 49 end
        if (level < 91) then return level*2 + 21 end
        return level*3 - 69
    end
    print(chat.header(addon.name) .. chat.warning(('Unrecognized grade: %s'):format(grade)));
    return 0
end

-- Get max skill level of skill with skill id = i
local function get_max_level(i)
    -- Don't look up grades or max skillcap for crafting skills
    if (skills[tonumber(i)]['category'] == 'Synthesis') then return 0; end

    -- Should never happen but still a potential crash prevention
    if (grades[i] == nil) then return 0; end

    local main_grade = grades[i][skilluptracker.Player:GetMainJob()];
    local main_max = calculate_max(skilluptracker.Player:GetMainJobLevel(), main_grade);

    if (skilluptracker.subJob) then
        local sub_grade = grades[i][skilluptracker.Player:GetSubJob()];
        local sub_max = calculate_max(skilluptracker.Player:GetSubJobLevel(), sub_grade);
        return math.max(main_max, sub_max);
    else
        return main_max;
    end
end

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        skilluptracker.Settings = s;
    end

    settings.save();
end);

-- get short name of skill, and return skill id.
local function get_skill_id(skill_name)
    --Fix for Hand-to-hand
    if (skill_name == "Hand To Hand" or skill_name == "Hand-to-hand") then skill_name = "Hand-to-Hand" end
    --Fix for Leathercraft/Leatherworking
    if (skill_name == "Leatherworking") then skill_name = "Leathercraft" end
    
    local _,skill = skills:find_if(function(s) 
        return s.en == skill_name or s.ja == skill_name;
    end);
    if (skill) then
        return skill.id;
    else
        print(chat.header(addon.name) .. chat.warning(('Unable to find skill id for %s'):format(skill_name)));
        return 0;
    end
end

local function cond_color(bool, color, str)
    return bool and chat.color2(color, str) or chat.message(str);
end

-- Returns the ashita skill object and the maxlevel
local function getSkillData(skill_id)
    local PSkill;
    local maxLevel = 0;
    if (skills[skill_id]['category'] == 'Synthesis') then
        PSkill = skilluptracker.Player:GetCraftSkill(skill_id - 48);
        maxLevel = (PSkill:GetRank() + 1) * 10;
    else
        PSkill = skilluptracker.Player:GetCombatSkill(skill_id);
        maxLevel = get_max_level(skill_id);
    end

    return PSkill, maxLevel;
end

ashita.events.register('text_in', 'skilluptracker_HandleText', function (e)
    if (e.blocked) then return; end

    -- Regular skillup
    -- Example: "Name's healing magic skill rises 0.1"
    if (e.message:match(' skill rises 0.')) then
        local line = AshitaCore:GetChatManager():ParseAutoTranslate(e.message_modified, false);
        local _,_, strbegin, player_name, skill_name, increase = line:find("(.+) %A+(%a+)%A+'s%A+([%s%a]+)%A+ skill rises 0.(%d+)");
        if (skill_name == nil) then return; end
        local skill_id = get_skill_id(skill_name:capitalize());

        -- Unable to find skill_id
        if (not skill_id) then
            print(chat.header(addon.name) .. chat.warning('Unknown skill : '..skill_name));
            return;
        end
    
        local PSkill, maxLevel = getSkillData(skill_id);

        -- Init the skill settings if necessary
        if (skilluptracker.Settings.skills[skill_id] == nil) then
            skilluptracker.Settings.skills[skill_id] = T{
                id = skill_id,
                level = PSkill:GetSkill() * 10,
            };
        end

        -- Increase the skill by the message amount
        local settingsSkill = skilluptracker.Settings.skills[skill_id];
        settingsSkill.level = settingsSkill.level + increase;
        settings.save();

        -- Modify the log message
        local str = (" (%0.1f/%d)"):format(settingsSkill.level / 10, maxLevel);
        e.message_modified = (strbegin..' ')
            :append(chat.color2(1, player_name))
            :append(chat.message('\'s '))
            :append(chat.color2(213, skill_name))
            :append(chat.message(' skill rises '))
            :append(chat.color2(skilluptracker.Settings.skillup_colors[math.min(increase, #skilluptracker.Settings.skillup_colors)], '0.'..tostring(increase)))
            :append(cond_color(PSkill:IsCapped(), skilluptracker.Settings.cap_color, str))
    end

    -- New skill level
    -- Example: "Name's healing magic skill reaches level 167"
    if (e.message:match(' skill reaches level ')) then
        local line = AshitaCore:GetChatManager():ParseAutoTranslate(e.message_modified, false);
        local _,_, strbegin, player_name, skill_name, level_str = line:find("(.+) %A+(%a+)%A+'s%A+([%s%a]+)%A+ skill reaches level (%d+)");
        if (skill_name == nil) then return; end
        local skill_id = get_skill_id(skill_name:capitalize());

        -- Unable to find skill_id
        if (not skill_id) then
            print(chat.header(addon.name) .. chat.warning('Unknown skill : '..skill_name));
            return;
        end

        local PSkill, maxLevel = getSkillData(skill_id);

        -- Init the skill settings if necessary
        if (skilluptracker.Settings.skills[skill_id] == nil) then
            skilluptracker.Settings.skills[skill_id] = T{
                id = skill_id,
                level = PSkill:GetSkill() * 10,
            };
        end

        -- Resync if we're lagging behind
        local newLevel = tonumber(level_str) * 10;
        if (skilluptracker.Settings.skills[skill_id] < newLevel) then
            skilluptracker.Settings.skills[skill_id].level = newLevel;
            settings.save();
        end

        -- Modify the log message
        e.message_modified = (strbegin..' ')
            :append(chat.color2(1, player_name))
            :append(chat.message('\'s '))
            :append(chat.color2(213, skill_name))
            :append(chat.message(' skill reaches level '))
            :append(cond_color(PSkill:IsCapped(), skilluptracker.Settings.cap_color, level_str))
            :append(chat.color2(skilluptracker.Settings.cap_color, '/'..maxLevel));
    end
end);