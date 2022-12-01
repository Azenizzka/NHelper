script_name("N Helper")
script_author("Azenizzka")

---------- ����-���������� ----------

local script_vers = 5
local script_vers_text = "1.5"
local dlstatus = require("moonloader").download_status
update_state = false

local update_url = "https://raw.githubusercontent.com/Azenizzka/NHelper/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://raw.githubusercontent.com/Azenizzka/NHelper/main/NHelper.lua"
local script_path = thisScript().path

---------- ���������� ----------

require "lib.moonloader"

local vkeys = require "vkeys"
local rkeys = require "rkeys"
local inicfg = require "inicfg"
local imadd = require 'imgui_addons'
local imgui = require "imgui"
local encoding = require "encoding"
local sampev = require "samp.events"

encoding.default = "CP1251"
u8 = encoding.UTF8

imgui.HotKey = require("imgui_addons").HotKey

---------- ���������, ��������� .ini ----------

local directIni = "NHelper.ini"
local mainIni = inicfg.load({

    autoreconnect = {
        toggle = false,
        min = 600,
        max = 1200,
        dont_reconnect = false,
        dont_reconnect_hour_first = 5,
        dont_reconnect_hour_second = 10
    },

    lavka = {
        toggle = false,
        name = "N Helper",
        color = 8,
    },

    timechange = {
        toggle = false,
        hours = 20,
        minutes = 30,
        weather = 37
    },

    addspawn = {
        toggle = false,
        waittoggle = false,
        id = 1,
        wait = 5
    }

}, "NHelper")

if not doesFileExist("NHelper.ini") then
    inicfg.save(mainIni, "NHelper.ini")
end

---------- ����������, ������� ----------

local tag = "[N Helper] "
local tagcolor = 0x20f271
local textcolor = "{DCDCDC}"
local warncolor = "{9c9c9c}"
rx, ry = getScreenResolution()
local falpha = 0.01
local colors = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"}

local selected_window = 1

local main_window_state = imgui.ImBool(false)
local autoreconnect_settings_window_state = imgui.ImBool(false)
local lavka_settings_window_state = imgui.ImBool(false)
local timechange_settings_window_state = imgui.ImBool(false)
local addspawn_settings_window_state = imgui.ImBool(false)

local addspawn_toggle = imgui.ImBool(mainIni.addspawn.toggle)
local addspawn_id = imgui.ImInt(mainIni.addspawn.id)
local addspawn_wait = imgui.ImInt(mainIni.addspawn.wait)
local addspawn_waittoggle = imgui.ImBool(mainIni.addspawn.waittoggle)

local timechange_hours = imgui.ImInt(mainIni.timechange.hours)
local timechange_minutes = imgui.ImInt(mainIni.timechange.minutes)
local timechange_weather = imgui.ImInt(mainIni.timechange.weather)
local timechange_toggle = imgui.ImBool(mainIni.timechange.toggle)

local lavka_color = imgui.ImInt(mainIni.lavka.color)
local lavka_name = imgui.ImBuffer(mainIni.lavka.name, 256)
local lavka_toggle = imgui.ImBool(mainIni.lavka.toggle)


local autoreconnect_toggle = imgui.ImBool(mainIni.autoreconnect.toggle)
local autoreconnect_min = imgui.ImInt(mainIni.autoreconnect.min)
local autoreconnect_max = imgui.ImInt(mainIni.autoreconnect.max)
local autoreconnect_dont_reconnect = imgui.ImBool(mainIni.autoreconnect.dont_reconnect)
local autoreconnect_dont_reconnect_hour_first = imgui.ImInt(mainIni.autoreconnect.dont_reconnect_hour_first)
local autoreconnect_dont_reconnect_hour_second = imgui.ImInt(mainIni.autoreconnect.dont_reconnect_hour_second)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end

    ---------- ����-���������� ----------

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.update.vers) > script_vers then
                sampAddChatMessage(tag .. textcolor .. "���������� ����������! ������ ������: " .. warncolor .. script_vers_text .. textcolor .. " ����� ������: " .. warncolor .. updateIni.update.vers_text, tagcolor)
                sampAddChatMessage(tag .. textcolor .. "������� ��������� ���������� " .. warncolor .. updateIni.update.vers_text .. textcolor .. "..", tagcolor)
                update_status = true
            elseif tonumber(updateIni.update.vers) == script_vers then
                sampAddChatMessage(tag .. textcolor .. "���������� �� ����������!", tagcolor)
            end
            os.remove(update_path)
        end
    end)

    ----------

    sampRegisterChatCommand("nhelp", nhelp_cmd)
    sampRegisterChatCommand("rec", rec_cmd)
    sampRegisterChatCommand("check", check_cmd)

    imgui.Process = false
    theme()

    while true do 
        wait(0)

        if timechange_toggle.v then
            setTime()
            setWeather()
        end

        ---------- ����-���������� ----------

        if update_status then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(tag .. textcolor .. "������ ������� ��������!", tagcolor)
                    thisScript():reload()
                end
            end)
            break
        end

    end
end




function imgui.OnDrawFrame()

    if not main_window_state.v then
        imgui.Process = false
    end

------------- ��������� ������ -----------
    if addspawn_settings_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(230, 110), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(rx / 2, ry / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8"��������� ������ ������", addspawn_settings_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('##18', imgui.ImVec2(215, 75), false)

        imgui.PushItemWidth(70)
        imgui.InputInt(u8'����� ������', addspawn_id)
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"����� �����, ��� ��� ����� ������������.\n�� ������, ���� ����� �������: [1] ������\n�� ��������� ����� 1")
        imgui.Separator()
        imadd.ToggleButton('##19', addspawn_waittoggle)
        imgui.SameLine()
        imgui.Text(u8"�������� ����� �������")
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"�������� � �������� ����� ���, ���\n��������� ����� �� ������")
        imgui.PushItemWidth(50)
        imgui.InputInt('', addspawn_wait, 0, 0)
        imgui.SameLine()
        imgui.Text(u8'������')


        imgui.EndChild()
        imgui.End()
    end



---------- ��������� ������� � ������ --------------
    if timechange_settings_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(210, 100), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(rx / 2, ry / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8"��������� ������� � ������", timechange_settings_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('##15', imgui.ImVec2(195, 65), false)

        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'����', timechange_hours, 0, 23)
        imgui.PopItemWidth()
        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'������', timechange_minutes, 0, 59)
        imgui.PopItemWidth()
        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'������', timechange_weather, 0, 45)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.TextQuestion(u8'(?)', u8"0 - 7 = ��������� ��������� ������� ������ ����\n08 = �����\n09 = ������ ����� � ��������\n10 = ����� ����\n11 = ����� �����\n12 - 15 = ������� � ���������� ������\n16 = ������� � ���������\n17 - 18 = ����\n19 = �������� ����\n20 = �������� ������\n21 = ���� � ��������� �����\n22 = ���� � ����������� �����\n23 � 26 = ��������� �������� ���������\n27 � 29 = ��������� ������ �����\n30 � 32 = ��������� �������, ��������, �����\n33 = ����� � ������������ ��������\n34 = ������ � ������/���������� ���������\n35 = ������� � ������ ������ � ���������� �����\n36 � 38 = ����� � �������� ������ � ����� ���������\n39 = ����� ����� ������\n40 � 42 = ������� ������ � ���������/����� ������\n43 = ����� � ����� ������\n44 = �����-����� ����\n45 = ��������� ����")



        imgui.EndChild()
        imgui.End()
    end



---------- ��������� �������������� ----------
    if autoreconnect_settings_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(290, 135), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(rx / 2, ry / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8"��������� ����-����������", autoreconnect_settings_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('##4', imgui.ImVec2(275, 100), false)

        imgui.PushItemWidth(100)
        imgui.InputInt(u8"����������� ��������", autoreconnect_min)
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"����������� � ��������")

        imgui.PushItemWidth(100)
        imgui.InputInt(u8"������������ ��������", autoreconnect_max)
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"����������� � ��������")
        imgui.Separator()

        imadd.ToggleButton(u8'##5', autoreconnect_dont_reconnect)
        imgui.SameLine()
        imgui.Text(u8'�� ����������������')
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"�������������� ��������������� �� �����\n����������� � ��������� ���������� �������")

        imgui.Text(u8"��")
        imgui.SameLine()
        imgui.PushItemWidth(50)
        imgui.SliderInt('##6', autoreconnect_dont_reconnect_hour_first, 0, 23)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.Text(u8"��")
        imgui.SameLine()
        imgui.PushItemWidth(50)
        imgui.SliderInt('##7', autoreconnect_dont_reconnect_hour_second, 0, 23)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.Text(u8"�����.")
        imgui.EndChild()
        imgui.End()
    end


---------- ��������� ����� ----------
    if lavka_settings_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 400), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(rx / 2, ry / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8"��������� ����-�����", lavka_settings_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('##11', imgui.ImVec2(285, 365), false)

        imgui.PushItemWidth(150)
        imgui.InputText(u8'�������� �����', lavka_name)
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"�������� ������ ���� �� 3 �� 20 �������� ������������.")
        if imgui.Button(u8'��������� ��������##12') then
            local textvalue = #lavka_name.v
            if textvalue < 3 or textvalue > 20 then
                sampAddChatMessage(tag .. textcolor .. "�������� ������ ���� �� 3 �� 20 �������� ������������.", tagcolor)
                lavka_name.v = "N Helper"
            else
                sampAddChatMessage(tag .. textcolor .. "��� �����!", tagcolor)
            end
        end
        imgui.Separator()

        imgui.PushItemWidth(100)
        imgui.Combo(u8'����� �����##13', lavka_color, colors, #colors)
        imgui.Separator()

        imgui.Text(u8'1 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.91, 0.31, 0.31, 1), lavka_name.v)

        imgui.Text(u8'2 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.91, 0.31, 0.75, 1), lavka_name.v)

        imgui.Text(u8'3 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.71, 0.31, 0.91, 1), lavka_name.v)

        imgui.Text(u8'4 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.4, 0.31, 0.91, 1), lavka_name.v)

        imgui.Text(u8'5 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.31, 0.62, 0.91, 1), lavka_name.v)

        imgui.Text(u8'6 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.31, 0.84, 0.91, 1), lavka_name.v)

        imgui.Text(u8'7 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.31, 0.91, 0.64, 1), lavka_name.v)

        imgui.Text(u8'8 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.31, 0.91, 0.38, 1), lavka_name.v)

        imgui.Text(u8'9 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.62, 0.91, 0.31, 1), lavka_name.v)

        imgui.Text(u8'10 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.82, 0.91, 0.31, 1), lavka_name.v)

        imgui.Text(u8'11 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.91, 0.74, 0.31, 1), lavka_name.v)

        imgui.Text(u8'12 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.91, 0.52, 0.31, 1), lavka_name.v)

        imgui.Text(u8'13 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.65, 0.19, 0.19, 1), lavka_name.v)

        imgui.Text(u8'14 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.19, 0.25, 0.65, 1), lavka_name.v)

        imgui.Text(u8'15 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.19, 0.65, 0.25, 1), lavka_name.v)

        imgui.Text(u8'16 ����:') 
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), lavka_name.v)


        imgui.EndChild()
        imgui.End()
    end


---------- �������� ���� ----------
    if main_window_state.v then
        renderDrawBox(0, 0, rx, ry, 0x50030303)
        savecfg()

        imgui.SetNextWindowSize(imgui.ImVec2(1000, 600), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(rx / 2, ry / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin("N Helper", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('##1', imgui.ImVec2(150, 565), false)

        imgui.SetCursorPos(imgui.ImVec2(55, 15))
        imgui.Text(u8"����")
        imgui.SetCursorPosY(40)
        imgui.Separator()

        imgui.SetCursorPos(imgui.ImVec2(10, 50))
        if imgui.Button(u8'�����������', imgui.ImVec2(130, 30)) then
            selected_window = 1
        end

        imgui.SetCursorPos(imgui.ImVec2(10, 525))
        imgui.Separator()
        imgui.Text(u8"�����: Azenizzka")
        imgui.Text(u8"������: " .. script_vers_text)

        imgui.EndChild()

        imgui.SameLine()
        ---------- ����������� ----------
        if selected_window == 1 then
            imgui.BeginChild('##2', imgui.ImVec2(830, 565), false)

            imadd.ToggleButton("##3", autoreconnect_toggle)
            imgui.SameLine()
            imgui.Text(u8"����-���������")
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"������������� �������������� ��� � �������, ����\n�� ���� �� ���� ���������. ����� ������� ��������� ��������.")
            imgui.SameLine()
            if imgui.Button(u8"���������##9") then 
                autoreconnect_settings_window_state.v = not autoreconnect_settings_window_state.v
            end 

            imadd.ToggleButton("##8", lavka_toggle)
            imgui.SameLine()
            imgui.Text(u8"����-�����")
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"������������� �������� ���� � �������� �����")
            imgui.SameLine()
            if imgui.Button(u8"���������##10") then
                lavka_settings_window_state.v = not lavka_settings_window_state.v
            end

            imadd.ToggleButton("##14", timechange_toggle)
            imgui.SameLine()
            imgui.Text(u8"��������� ������� � ������")
            imgui.SameLine()
            if imgui.Button(u8"���������##15") then
                timechange_settings_window_state.v = not timechange_settings_window_state.v
            end

            imadd.ToggleButton("##16", addspawn_toggle)
            imgui.SameLine()
            imgui.Text(u8"���� ����� ������")
            imgui.SameLine()
            imgui.TextQuestion('(?)', "�������������� ����� ������, ���� ��\n������� � ADD-VIP")
            imgui.SameLine()
            if imgui.Button(u8'���������##17') then
                addspawn_settings_window_state.v = not addspawn_settings_window_state.v
            end

            imgui.EndChild()
        end

        imgui.End()

    end

end

------ �������� �������
function nhelp_cmd()
    main_window_state.v = not main_window_state.v
    imgui.Process = main_window_state.v
    alpha()
end

------ ��������� �������
function setTime()
    setTimeOfDay(timechange_hours.v, timechange_minutes.v)
end

------ ��������� ������
function setWeather()
    local weather = tonumber(timechange_weather.v)
    forceWeatherNow(weather)
end

------ ��������� �� �������
function rec_cmd(arg)
    lua_thread.create(function()
        sampSetGamestate(5)
        local ip, port = sampGetCurrentServerAddress()
        sampAddChatMessage(tag .. textcolor .. '��������: '.. warncolor.. arg .. textcolor ..' ���.', tagcolor)
        wait(arg * 1000)
        sampConnectToServer(ip, port)
    end)

end

----- ��������� � ������� ��� ���? ���� ���, �� ���������
function onReceivePacket(id)
    if id == 32 and autoreconnect_toggle.v then
        lua_thread.create(function()
            local ip, port = sampGetCurrentServerAddress()
            math.randomseed(os.clock())
            local a = math.random(autoreconnect_min.v, autoreconnect_max.v)
            sampAddChatMessage(tag .. textcolor .. '��������: '.. warncolor .. a .. textcolor .. ' ���.', tagcolor)
            wait(a * 1000)

            local canreconnecthr = true
            local hrs = tonumber(os.date("%H"))
            if autoreconnect_dont_reconnect.v then
                if hrs >= autoreconnect_dont_reconnect_hour_first.v and hrs <= autoreconnect_dont_reconnect_hour_second.v then
                    canreconnecthr = false
                end
            end

            if id == 32 and canreconnecthr then 
                 sampConnectToServer(ip, port)
            elseif id == 32 and not canreconnecthr then
                sampAddChatMessage(tag .. textcolor .. "������ ��������������, � ��� ���������� ��� �����", tagcolor)
            elseif id ~= 32 then
                sampAddChatMessage(tag .. textcolor .. "������ ��������������, �� ��� ���������.", tagcolor)
            end
        end)
    end
end

----- ���� ����� � ���������
function sampev.onShowDialog(id, style, title, b1, b2, text)

    if lavka_toggle.v then
        if id == 3021 then
            sampSendDialogResponse(3021, 1, 0)
        end
        if id == 3020 then
            sampSendDialogResponse(3020, 1, _, lavka_name.v)
        end

        
        if id == 3030 then
            sampSendDialogResponse(3030, 1, lavka_color.v)
        end
    end

    if id == 25530 then
        if addspawn_toggle.v then
            if addspawn_waittoggle.v then
                lua_thread.create(function()
                    local a = addspawn_id.v-1
                    time = addspawn_wait.v * 1000
                    wait(time)
                    sampAddChatMessage(tag .. textcolor .. "������� " .. warncolor .. addspawn_id.v .. textcolor .. " �����.", tagcolor)
                    sampSendDialogResponse(25530, 1, a, _)
                end)
            elseif not addspawn_waittoggle.v then 
                local a = addspawn_id.v-1
                sampSendDialogResponse(25530, 1, a, _)
                sampAddChatMessage(tag .. textcolor .. "������� " .. warncolor .. addspawn_id.v .. textcolor .. " �����.", tagcolor)
            end
        end
    end 

end

------ ����������
function savecfg()
    mainIni.addspawn.toggle = addspawn_toggle.v
    mainIni.addspawn.waittoggle = addspawn_waittoggle.v
    mainIni.addspawn.id = addspawn_id.v
    mainIni.addspawn.wait = addspawn_wait.v

    mainIni.timechange.hours = timechange_hours.v
    mainIni.timechange.minutes = timechange_minutes.v
    mainIni.timechange.weather = timechange_weather.v
    mainIni.timechange.toggle = timechange_toggle.v

    mainIni.lavka.toggle = lavka_toggle.v
    mainIni.lavka.name = lavka_name.v
    mainIni.lavka.color = lavka_color.v

    mainIni.autoreconnect.toggle = autoreconnect_toggle.v
    mainIni.autoreconnect.min = autoreconnect_min.v
    mainIni.autoreconnect.max = autoreconnect_max.v
    mainIni.autoreconnect.dont_reconnect = autoreconnect_dont_reconnect.v
    mainIni.autoreconnect.dont_reconnect_hour_first = autoreconnect_dont_reconnect_hour_first.v
    mainIni.autoreconnect.dont_reconnect_hour_second = autoreconnect_dont_reconnect_hour_second.v

    inicfg.save(mainIni, directIni)

end

function check_cmd()
    local id = sampGetCurrentDialogId()
    sampAddChatMessage(id, -1)
end

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function alpha()
    lua_thread.create(function()
        if falpha > 0 then
            falpha = 0
        end
        while falpha >= 0 and falpha <= 1 do
            falpha = falpha + 0.02
            wait(10)
            theme()
        end
        theme()
    end)
end

function theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.Alpha = falpha
    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 5
    style.ChildWindowRounding = 4
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 10.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 8
    style.GrabRounding = 1
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
    colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
    colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
    colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
    colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
    colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
    colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
    colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
    colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
    colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
    colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
    colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.00, 0.90, 0.50, 1.00)
    colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
end