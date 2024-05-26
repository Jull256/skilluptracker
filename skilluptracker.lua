addon.name      = 'skilluptracker';
addon.author    = 'Jull (Original idea by Mujihina)';
addon.version   = '1.02';
addon.desc      = 'Displays current decimal and cap in skillup messages.';
addon.link      = 'https://github.com/Jull256/skilluptracker/';

require('common');
local ffi = require('ffi');
local settings = require('settings');
local chat = require('chat');
local grades = require('job_grades')
local imgui = require('imgui');
local skills = require('skills');

local defaults = T{
    skill_levels = {};
    colors = {
        skillups = { 106, 2, 6 };
        cap = 8; -- 4 for blue
        uncap = 106;
        msg = 129;
        skillname = 106;
        nickname = 106;
    }
}

local skilluptracker = {
    Visible = {false},
    Settings = settings.load(defaults),
    Player = AshitaCore:GetMemoryManager():GetPlayer(),
    MsgMode = 128, -- Can't be 129 because we filter these (simplelog conflict fix)
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
    printError(('Unrecognized grade: %s'):format(grade));
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

local function getSkillObject(skillID)
    local Player = AshitaCore:GetMemoryManager():GetPlayer();
    local Skill;

    if (skillID >= 48) then
        Skill = Player:GetCraftSkill(skillID - 48);
    else
        Skill = Player:GetCombatSkill(skillID);
    end

    if (not Skill) then
        printError("Couldn't load skill with ID "..skillID);
        return nil;
    end

    return Skill;
end

local function getSkillCap(pSkill, skillID)
    if (skillID >= 48) then
        return (pSkill:GetRank() + 1) * 10;
    else
        return get_max_level(skillID);
    end
end

local function getSkillUpColor(amount)
    return skilluptracker.Settings.colors.skillups[math.min(amount, #skilluptracker.Settings.colors.skillups)]
end

local function sendDecimalSkillupMessage(skillname, skillAmount, total, cap)
    local capped = total / 10 >= cap;
    local colors = skilluptracker.Settings.colors;
    AshitaCore:GetChatManager():AddChatMessage(skilluptracker.MsgMode, false,
        chat.color1(colors.msg, 'Your ')
        :append(chat.color1(colors.skillname, skillname))
        :append(chat.color1(colors.msg, ' skill rises '))
        :append(chat.color1(getSkillUpColor(skillAmount), ('0.%d'):fmt(skillAmount)))
        :append(chat.color1(colors.msg, ' points ('))
        :append(chat.color1(capped and colors.cap or colors.uncap, ("%0.1f"):fmt(total / 10)))
        :append(chat.color1(capped and colors.cap or colors.uncap, (" / %d"):fmt(cap)))
        :append(chat.color1(colors.msg, ')'))
    );
end

local function sendFullSkillupMessage(skillname, skillLevel, cap)
    local capped = skillLevel >= cap;
    local colors = skilluptracker.Settings.colors;
    AshitaCore:GetChatManager():AddChatMessage(skilluptracker.MsgMode, false,
        chat.color1(colors.msg, 'Your ')
        :append(chat.color1(colors.skillname, skillname))
        :append(chat.color1(colors.msg, ' skill reaches level '))
        :append(chat.color1(capped and colors.cap or colors.uncap, ('%d'):fmt(skillLevel)))
        :append(chat.color1(capped and colors.cap or colors.uncap, (" / %d"):fmt(cap)))
    );
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
            local pSkill = getSkillObject(skillID);
            local sSkill = skills[skillID];
            local savedLevel = skilluptracker.Settings.skill_levels[skillID] or pSkill:GetSkill() * 10;
            if (not pSkill or not sSkill) then return; end
            local skillCap = getSkillCap(pSkill, skillID);

            -- Increment
            savedLevel = savedLevel + skillAmount;

            -- Update the saved value
            skilluptracker.Settings.skill_levels[skillID] = savedLevel;
            settings.save();

            -- Send the skillup message to the log
            sendDecimalSkillupMessage(sSkill['en']:lower(), skillAmount, savedLevel, skillCap);

            -- Prevent the client from sending another message
            e.blocked = true;

        -- Full skillup
        elseif (packet.MessageNum == 53) then
            local skillID = packet.Data;
            local skillLevel = packet.Data2;
            local savedLevel = skilluptracker.Settings.skill_levels[skillID] or 0;
            local pSkill = getSkillObject(skillID);
            local sSkill = skills[skillID];
            if (not pSkill or not sSkill) then return; end
            local skillCap = getSkillCap(pSkill, skillID);

            -- Update the saved value if we're not sync'd
            if (math.floor(savedLevel / 10) ~= skillLevel) then
                skilluptracker.Settings.skill_levels[skillID] = skillLevel * 10;
            end

            -- Send the skillup message to the log
            -- pSkill:IsCapped() seems to return false for synthesis crafts under max rank
            sendFullSkillupMessage(sSkill['en']:lower(), skillLevel, skillCap);

            -- Prevent the client from sending another message
            e.blocked = true;
        end
    end
end);

--[[
* event: packet_in
* desc : Event called when the addon is processing incoming texts.
--]]
ashita.events.register('text_in', 'skilluptracker_HandleText', function (e)
    if (e.blocked) then return; end

    -- Block simplelog's default skillup messages (conflict fix)
    if (e.mode ~= 129) then return; end
    local line = e.message:strip_colors()
    if (line:match(' skill rises ') or line:match(' skill reaches ')) then
        e.blocked = true;
    end
end);

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'skilluptracker_HandleRender', function ()
    if (not skilluptracker.Visible[1]) then return; end
    
    -- Draw config window
    imgui.SetNextWindowSize({ 300, nil, });
    if imgui.Begin("SkillUpTracker Config", skilluptracker.Visible, ImGuiWindowFlags_NoResize) then
        imgui.TextColored({ 1.0, 1.0, 0.0, 1.0, }, ('Colors'):fmt(i));
        imgui.PushItemWidth(30);
        local msgColor = {skilluptracker.Settings.colors.msg};
        if (imgui.InputInt(' Message', msgColor, 0)) then
            skilluptracker.Settings.colors.msg = msgColor[1];
            settings.save();
        end
        local highlight = {skilluptracker.Settings.colors.skillname};
        if (imgui.InputInt(' Highlight', highlight, 0)) then
            skilluptracker.Settings.colors.skillups[1] = highlight[1];
            skilluptracker.Settings.colors.uncap = highlight[1];
            skilluptracker.Settings.colors.skillname = highlight[1];
            skilluptracker.Settings.colors.nickname = highlight[1];
            settings.save();
        end
        local skillup2 = {skilluptracker.Settings.colors.skillups[2]};
        if (imgui.InputInt(' 0.2 skillups', skillup2, 0)) then
            skilluptracker.Settings.colors.skillups[2] = skillup2[1];
            settings.save();
        end
        local skillup3 = {skilluptracker.Settings.colors.skillups[3]};
        if (imgui.InputInt(' >0.2 skillups', skillup3, 0)) then
            skilluptracker.Settings.colors.skillups[3] = skillup3[1];
            settings.save();
        end
        imgui.PopItemWidth()
        imgui.Separator();
        if (imgui.Button('Color Test')) then
            sendFullSkillupMessage('testing', 9, 10);
            sendDecimalSkillupMessage('testing', 1, 95, 10);
            sendDecimalSkillupMessage('testing', 2, 97, 10);
            sendDecimalSkillupMessage('testing', 3, 100, 10);
            sendFullSkillupMessage('testing', 10, 10);
        end
        imgui.SameLine();
        if (imgui.Button('Reset to defaults')) then
            -- Reset everything except the saved skill levels
            local save = skilluptracker.Settings.skill_levels;
            settings.reset();
            skilluptracker.Settings.skill_levels = save;
            settings.save();
        end
    end
    imgui.End();
end);

--[[
* event: command
* desc : Event called when the addon is processing a command.
--]]
ashita.events.register('command', 'skilluptracker_HandleCommand', function (e)
    -- Parse the command arguments
    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/sut', '/skilluptracker')) then return; end

    -- Block all related commands
    e.blocked = true;

    if (#args >= 1) then
        skilluptracker.Visible[1] = not skilluptracker.Visible[1];
        return;
    end
end);