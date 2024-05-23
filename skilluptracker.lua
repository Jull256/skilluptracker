addon.name      = 'skilluptracker';
addon.author    = 'Jull - Original by Mujihina';
addon.version   = '1.02';
addon.desc      = 'Displays current decimal and cap in skillup messages.';
addon.link      = 'https://github.com/Jull256/skilluptracker/';

require('common');
local ffi = require('ffi');
local settings = require('settings');
local chat = require('chat');
local grades = require('job_grades')
local skills = require('skills');

local defaults = T{
    skill_levels = {};
    colors = {
        skillups = { 106, 6, 5 };
        cap = 4;
        msg = 106;
        skillname = 1;
        nickname = 1;
    }
}

local skilluptracker = {
    Settings = settings.load(defaults),
    Player = AshitaCore:GetMemoryManager():GetPlayer();
};

-- FFI Prototypes
ffi.cdef[[
    // Packet: 0x0029 - Battle Message (Server To Client)
    typedef struct packet_battlemsg_s2c_t
    {
        uint16_t    id: 9;
        uint16_t    size: 7;
        uint16_t    sync;
        uint32_t    UniqueNoCas;    // PS2: UniqueNoCas
        uint32_t    UniqueNoTar;    // PS2: UniqueNoTar
        uint32_t    Data;           // PS2: data
        uint32_t    Data2;          // PS2: data2
        uint16_t    ActIndexCas;    // PS2: ActIndexCas
        uint16_t    ActIndexTar;    // PS2: ActIndexTar
        uint16_t    MessageNum;     // PS2: MessageNum
        uint8_t     Type;           // PS2: Type
        uint8_t     padding00;      // PS2: padding00
    } packet_battlemsg_s2c_t;
]];

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
    local Player = AshitaCore:GetMemoryManager():GetPlayer();

    -- Don't look up grades or max skillcap for crafting skills
    if (skills[tonumber(i)]['category'] == 'Synthesis') then return 0; end

    -- Should never happen but still a potential crash prevention
    if (grades[i] == nil) then return 0; end

    local mainJobGrade = grades[i][Player:GetMainJob()];
    local mainJobMax = calculate_max(Player:GetMainJobLevel(), mainJobGrade);

    local subJobGrade = grades[i][Player:GetSubJob()];
    if (subJobGrade) then
        local subJobMax = calculate_max(Player:GetSubJobLevel(), subJobGrade);
        return math.max(mainJobMax, subJobMax);
    else
        return mainJobMax;
    end
end

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        skilluptracker.Settings = s;
    end

    settings.save();
end);

local function printError(errorMsg)
    print(chat.header(addon.name):append(chat.error(errorMsg)));
end

local function getSkillObject(skill_id)
    local Player = AshitaCore:GetMemoryManager():GetPlayer();
    local Skill;

    if (skill_id >= 48) then
        Skill = Player:GetCraftSkill(skill_id - 48);
    else
        Skill = Player:GetCombatSkill(skill_id);
    end

    if (not Skill) then
        printError("Couldn't load skill with ID "..skill_id);
        return nil;
    end

    return Skill;
end

local function getSkillCap(pSkill, skillID)
    if (skillID >= 48) then
        return (PSkill:GetRank() + 1) * 10;
    else
        return get_max_level(skill_id);
    end
end

local function getSkillUpColor(amount)
    return skilluptracker.Settings.colors.skillups[math.min(amount, #skilluptracker.Settings.colors.skillups)]
end

--[[
* event: packet_in
* desc : Event called when the addon is processing incoming packets.
--]]
ashita.events.register('packet_in', 'skilluptracker_PacketIn', function (e)
    -- Packet: Battle Message
    if (e.id == 0x29) then
        local packet = ffi.cast('packet_battlemsg_s2c_t*', e.data_modified_raw);

        -- Decimal skillup
        if (packet.MessageNum == 38) then
            local skillID = packet.Data;
            local skillAmount = packet.Data2;
            local savedLevel = skilluptracker.Settings.skill_levels[skillID];
            local pSkill = getSkillObject(skill_id);
            local sSkill = skills[skill_id];
            if (not pSkill or not sSkill) then return; end
            local skillCap = getSkillCap(pSkill, skillID);

            -- Add the amount to the settings
            savedLevel = savedLevel + skillAmount;
            settings.save();

            -- Send the skillup message to the log
            local colors = skilluptracker.Settings.colors;
            AshitaCore:GetChatManager():AddChatMessage(colors.msg, false
                ("Your ")
                :append(chat.color1(colors.skillname, sSkill['en']))
                :append(' skill rises ')
                :append(chat.color1(getSkillUpColor(skillAmount), ('0.%d'):fmt(skillAmount)))
                :append('(')
                :append(chat.color1(pSkill:IsCapped() and colors.cap or colors.msg, ("%0.1f"):fmt(savedLevel / 10)))
                :append(chat.color1(colors.cap, ("/%d"):fmt(skillCap)))
                :append(')')
            );

            -- Prevent the client from sending another message
            e.blocked = true;

        -- Full skillup
        elseif (packet.MessageNum == 53) then
            local skillID = packet.Data;
            local skillLevel = packet.Data2;
            local savedLevel = skilluptracker.Settings.skill_levels[skillID];
            local pSkill = getSkillObject(skill_id);
            local sSkill = skills[skill_id];
            if (not pSkill or not sSkill) then return; end
            local skillCap = getSkillCap(pSkill, skillID);

            -- Update the saved value if we're not sync'd
            if (math.floor(savedLevel / 10) != skillLevel) then
                savedLevel = skillLevel * 10;
            end

            -- Send the skillup message to the log
            local colors = skilluptracker.Settings.colors;
            AshitaCore:GetChatManager():AddChatMessage(colors.msg, false
                ("Your ")
                :append(chat.color1(colors.skillname, sSkill['en']))
                :append(' skill reaches level ')
                :append(chat.color1(pSkill:IsCapped() and colors.cap or colors.msg, ('0.%d'):fmt(skillLevel)))
                :append(chat.color1(colors.cap, ("/%d"):fmt(skillCap)))
            );

            -- Prevent the client from sending another message
            e.blocked = true;
        end
    end
end
