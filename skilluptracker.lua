addon.name      = 'skilluptracker';
addon.author    = 'Jull - Original by Mujihina';
addon.version   = '1.00';
addon.desc      = 'Displays current decimal and cap in skillup messages.';
addon.link      = 'https://github.com/Jhuul/skilluptracker/';

require('common');
local settings = require('settings');
local chat = require('chat');
local grades = require('job_grades')
local skills = require('skills');

local defaults = T{
    skills = T{};
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

-- Update level for skill_id.
local function update_skill(skill_id, level)
    if (skilluptracker.Settings.skills[skill_id] and skilluptracker.Settings.skills[skill_id]['level']) then
        skilluptracker.Settings.skills[skill_id]['level'] = level;
        settings.save();
    end    
end

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
        return tostring(skill.id);
    else
        print(chat.header(addon.name) .. chat.warning(('Unable to find skill id for %s'):format(skill_name)));
        return "0"
    end
end

ashita.events.register('text_in', 'skilluptracker_HandleText', function (e)
    if (e.injected == true) then return; end
    if (e.blocked) then return; end
    
    local line = e.message:strip_colors()
    if (line:match('skill rises')) then
        local _,_, player_name, skill_name, increase  = line:find("(%a+)'s (.+) skill rises 0.(%d+)")
        local skill_id = get_skill_id(skill_name:capitalize())

        -- Unable to find skill_id
        if (not skill_id) then
            print(chat.header(addon.name) .. chat.warning('Unknown skill : '..skill_name));
            return;
        end

        if (skilluptracker.Settings.skills[skill_id] == nil) then
            skilluptracker.Settings.skills[skill_id] = {
                id = skill_id,
                level = 0,
                short_name = skill_name
            };
        end
        local old_level = skilluptracker.Settings.skills[skill_id]['level']
        local new_level = tonumber(old_level) + (tonumber(increase) / 10)

        update_skill(skill_id, new_level);

        if (skills[tonumber(skill_id)]['category'] == 'Synthesis') then
            e.message_modified = ("%s (%0.1f)"):format(e.message_modified, new_level);
        else
            local max = get_max_level(tonumber(skill_id))
            e.message_modified = ("%s (%0.1f/%d)"):format(e.message_modified, new_level, max)
        end
    end
end);