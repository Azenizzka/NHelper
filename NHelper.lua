script_name("N Helper")
script_author("Azenizzka")

-----

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

-----

imgui.HotKey = require("imgui_addons").HotKey

-----

local directIni = "NHelper.ini"
local mainIni = inicfg.load({
    settings = {
        key = "[18,82]",
        autoreconnect = false,
        timeactive = false,
        minrecon = 600,
        hr1 = 4,
        hr2 = 6,
        render = false,
        timehour = 20,
        weather = 37,
        twchange = false,
        timeminute = 30,
        lavkaname = "N Helper",
        selecteditem = 7,
        lavkanameactive = false,
        rolen = false,
        rsemena = false,
        rlines = true,
        rname = true,
        renderlavka = false,
        nhelpact = true,
        robject = false,
        renderid = 228,
        widthtext = 15,
        width = 2,
        maxrecon = 1200
    }
}, 'NHelper')
if not doesFileExist('NHelper.ini') then
    inicfg.save(mainIni, 'NHelper.ini')
end

-----

local main_window_state = imgui.ImBool(false)
local autoreconnect_window_state = imgui.ImBool(false)
local settime_window_state = imgui.ImBool(false)
local timeactive = imgui.ImBool(mainIni.settings.timeactive)
local autoreconnect = imgui.ImBool(mainIni.settings.autoreconnect)
local minrecon = imgui.ImInt(mainIni.settings.minrecon)
local maxrecon = imgui.ImInt(mainIni.settings.maxrecon)
local hr1 = imgui.ImInt(mainIni.settings.hr1)
local hr2 = imgui.ImInt(mainIni.settings.hr2)
local twchange = imgui.ImBool(mainIni.settings.twchange)
local timehour = imgui.ImInt(mainIni.settings.timehour)
local weather = imgui.ImInt(mainIni.settings.weather) 
local timeminute = imgui.ImInt(mainIni.settings.timeminute)
local lavkanameactive = imgui.ImBool(mainIni.settings.lavkanameactive)
local lavkanameactive_window_state = imgui.ImBool(false)
local lavkaname = imgui.ImBuffer(mainIni.settings.lavkaname, 256)
local sw, sh = getScreenResolution()
local selecteditem = imgui.ImInt(mainIni.settings.selecteditem)
local select_window = 1
local nhelpact = imgui.ImBool(mainIni.settings.nhelpact)
local renderlavka = imgui.ImBool(mainIni.settings.renderlavka)
local render_lavka_state = imgui.ImBool(false)
local robject = imgui.ImBool(mainIni.settings.robject)

local rolen = imgui.ImBool(mainIni.settings.rolen)
local rsemena = imgui.ImBool(mainIni.settings.rsemena)
local renderid = imgui.ImInt(mainIni.settings.renderid)

local rlines = imgui.ImBool(mainIni.settings.rlines)
local rname = imgui.ImBool(mainIni.settings.rname)
local width = imgui.ImFloat(mainIni.settings.width)
local widthtext = imgui.ImInt(mainIni.settings.widthtext)

local render_window_state = imgui.ImBool(false)
local render = imgui.ImBool(mainIni.settings.render)
-----

local tag = "[N Helper] "
local tagcolor = 0x20f271
local rendercolorline = 0xFF8f8f8f
local rendercolortext = 0xFF7fd4ce
local textcolor = "{DCDCDC}"
local warncolor = "{9c9c9c}"
font = renderCreateFont("Arial Black", 15)

------

local ActiveMenu = {
    v = decodeJson(mainIni.settings.key)
}

------------- AUTO_UPDATE --------------

local dlstatus = require('moonloader').download_status
update_state = false

local script_vers = 2
local script_vers_text = "1.1"

local update_url = "https://raw.githubusercontent.com/Azenizzka/NHelper/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://raw.githubusercontent.com/Azenizzka/NHelper/main/NHelper.lua"
local script_path = thisScript().path




-----

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("nhelp", nhelp_cmd)
    sampRegisterChatCommand("reconnect", reconnect_cmd)
    sampRegisterChatCommand("check", check_cmd)

    --------------- AUTO_UPDATE --------------


    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.update.vers) > script_vers then
                sampAddChatMessage(tag .. textcolor .. "Îáíàðóæåíî îáíîâëåíèå! Ñòàðàÿ âåðñèÿ: " .. warncolor .. script_vers_text .. textcolor .. " Íîâàÿ âåðñèÿ: " .. updateIni.update.vers_text, tagcolor)
                sampAddChatMessage(tag .. textcolor .. "Íà÷èíàþ óñòàíîâêó îáíîâëåíèÿ " .. warncolor .. updateIni.update.vers_text .. textcolor .. "..", tagcolor)
                update_status = true
            elseif tonumber(updateIni.update.vers) == script_vers then
                sampAddChatMessage(tag .. textcolor .. "Îáíîâëåíèé íå îáíàðóæåíî!", tagcolor)
            end
            os.remove(update_path)
        end
    end)



    ------------------

    sampAddChatMessage(tag .. textcolor .. "Ñêðèïò óñïåøíî çàãðóæåí! Âåðñèÿ: " .. script_vers_text, tagcolor)
    sampAddChatMessage(tag .. textcolor .. "Àêòèâàöèÿ ñêðèïòà: " .. warncolor .. "/nhelp " .. textcolor .. "èëè " .. warncolor .. table.concat( rkeys.getKeysName(ActiveMenu.v), "+"), tagcolor)
    sampAddChatMessage(tag .. textcolor .. "Àâòîð ñêðèïòà: " .. warncolor .. "Azenizzka", tagcolor)

    bindMenu = rkeys.registerHotKey(ActiveMenu.v, true, nhelp)

    theme()

    imgui.Process = false

    while true do
        wait(0)

        --------------- AUTO_UPDATE -------------
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(tag .. textcolor .. "Ñêðèïò óñïåøíî îáíîâëåí!", tagcolor)
                    thisScript():reload()
                end
            end)
            break

        end



        -----------------------------------------

        if twchange.v then
            setTime()
            setWeather()
        end

        if render.v then
            for _, v in pairs(getAllObjects()) do
                local id = getObjectModel(v)
                if isObjectOnScreen(v) and rolen.v and id == 19315 then
                    local name = "Îëåíü"
                    local _, OX, OY, OZ = getObjectCoordinates(v)
                    local PX, PY, PZ = getCharCoordinates(PLAYER_PED)
                    local OXS, OYS, OZS = convert3DCoordsToScreen(OX, OY, OZ)
                    local PXS, PYS, PZS = convert3DCoordsToScreen(PX, PY, PZ)
                    if rlines.v then
                        renderDrawLine(PXS, PXS , OXS, OYS, width.v, rendercolorline)
                    end
                    if rname.v then
                        renderFontDrawText(font, name, OXS ,OYS, rendercolortext)
                    end
    
                end

                if isObjectOnScreen(v) and rsemena.v and id == 859 then
                    local name = "Ñåìåíà"
                    local _, OX, OY, OZ = getObjectCoordinates(v)
                    local PX, PY, PZ = getCharCoordinates(PLAYER_PED)
                    local OXS, OYS, OZS = convert3DCoordsToScreen(OX, OY, OZ)
                    local PXS, PYS, PZS = convert3DCoordsToScreen(PX, PY, PZ)
                    if rlines.v then
                        renderDrawLine(PXS, PXS , OXS, OYS, width.v, rendercolorline)
                    end
                    if rname.v then
                        renderFontDrawText(font, name, OXS ,OYS, rendercolortext)
                    end
    
                end

                if isObjectOnScreen(v) and robject.v and id == renderid.v then
                    local name = renderid.v
                    local _, OX, OY, OZ = getObjectCoordinates(v)
                    local PX, PY, PZ = getCharCoordinates(PLAYER_PED)
                    local OXS, OYS, OZS = convert3DCoordsToScreen(OX, OY, OZ)
                    local PXS, PYS, PZS = convert3DCoordsToScreen(PX, PY, PZ)
                    if rlines.v then
                        renderDrawLine(PXS, PXS , OXS, OYS, width.v, rendercolorline)
                    end
                    if rname.v then
                        renderFontDrawText(font, name, OXS ,OYS, rendercolortext)
                    end
    
                end
            end
        end
    end

    

end 


----- imgui
function imgui.OnDrawFrame()
    
    ----- Ïðîâåðêà imgui Process
    if not autoreconnect_window_state.v and not main_window_state.v and not settime_window_state.v and not lavkanameactive_window_state.v and not render_window_state.v and not render_lavka_state.v then
        imgui.Process = false
    end

    ----- Íàñòðîéêè ðåíäåðà ëàâîê
    if render_lavka_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(330,200), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Íàñòðîéêè Ðåíäåðà Ëàâîê", render_lavka_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('lavkarendersettings', imgui.ImVec2(315, 165), false)


        imgui.EndChild()
        imgui.End()
    end

    ----- Íàñòðîéêè Ðåíäåðà
    if render_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(340,200), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Íàñòðîéêè Ðåíäåðà", render_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('rendersettings', imgui.ImVec2(325, 165), false)

        imadd.ToggleButton("Ëèíèè", rlines)
        imgui.SameLine()
        imgui.Text(u8'Ëèíèè')
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Áóäåò âåñòè ëèíèè\näî îáüåêòà")
        imgui.SameLine()
        imgui.SetCursorPosX(130)
        imgui.PushItemWidth(100)
        imgui.SliderFloat(u8'Øèðèíà ëèíèé', width, 0.1, 10)
        imgui.PopItemWidth()

        imadd.ToggleButton('Òèï', rname)
        imgui.SameLine()
        imgui.Text(u8"Îáüåêò")
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Áóäåò îòîáðàæàòüñÿ\níàçâàíèå ïðåäìåòà, íà êîòîðûé\níàñòðîåí ðåíäåð")
        imgui.SameLine()
        imgui.SetCursorPosX(130)
        imgui.PushItemWidth(100)
        if imgui.SliderInt(u8'Ðàçìåð òåêñòà', widthtext, 1, 40) then
            font = renderCreateFont("Arial Black", widthtext.v)    
        end
        imgui.PopItemWidth()
        imadd.ToggleButton("id object", robject)
        imgui.SameLine()
        imgui.Text(u8"Èä îáüåêòà")
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Âàëë-Õàê íà èä îáüåêòà, êîòîðûé\nâû óêàçàëè")

        imgui.SameLine(_, 50)
        imgui.SetCursorPosX(130)
        imgui.PushItemWidth(100)
        imgui.InputInt('##1', renderid, -1, -1)
        imgui.PopItemWidth()

        imgui.Separator()

        imadd.ToggleButton("Îëåíè", rolen)
        imgui.SameLine()
        imgui.Text(u8"Îëåíè")

        imadd.ToggleButton("Ñåìåíà", rsemena)
        imgui.SameLine()
        imgui.Text(u8"Ñåìåíà")

        imgui.EndChild()
        imgui.End()

    end


    ----- Íàñòðîéêè ëàâêè 
    if lavkanameactive_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 400), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2), sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Íàñòðîéêè ëàâêè", lavkanameactive_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('lavkanameactive', imgui.ImVec2(285, 365), false)
        imgui.PushItemWidth(150)
        imgui.InputText(u8'Íàçâàíèå ëàâêè', lavkaname)
        imgui.PopItemWidth()

        if imgui.Button(u8'Ñîõðàíèòü íàçâàíèå', imgui.ImVec2(130, 20)) then
            mainIni.settings.lavkaname = lavkaname.v
            inicfg.save(mainIni, directIni)
            local textvalue = #lavkaname.v
            if textvalue >= 21 then
                lavkaname.v = ""
                sampAddChatMessage(tag .. textcolor .. "Êîëè÷åñòâî ñèìâîëîâ äîëæíî áûòü îò " .. warncolor .. "3 " .. textcolor .. "äî " .. warncolor .. "20" .. textcolor .. ".", tagcolor)
            elseif textvalue <= 2 then
                lavkaname.v = ""
                sampAddChatMessage(tag .. textcolor .. "Êîëè÷åñòâî ñèìâîëîâ äîëæíî áûòü îò " .. warncolor .. "3 " .. textcolor .. "äî " .. warncolor .. "20" .. textcolor .. ".", tagcolor)
            elseif textvalue then
                sampAddChatMessage(tag .. textcolor .. "Íàçâàíèå óñïåøíî ñîõðàíåíî!", tagcolor)
            end
        end
        imgui.Separator()
        imgui.Combo(u8'Âûáîð öâåòà', selecteditem, {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"}, -1)
        imgui.Separator()   
        imgui.TextColored(imgui.ImVec4(0.91, 0.31, 0.31, 1), u8"1 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.91, 0.31, 0.75, 1), u8"2 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.71, 0.31, 0.91, 1), u8"3 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.4, 0.31, 0.91, 1), u8"4 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.31, 0.62, 0.91, 1), u8"5 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.31, 0.84, 0.91, 1), u8"6 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.31, 0.91, 0.64, 1), u8"7 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.31, 0.91, 0.38, 1), u8"8 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.62, 0.91, 0.31, 1), u8"9 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.82, 0.91, 0.31, 1), u8"10 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.91, 0.74, 0.31, 1), u8"11 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.91, 0.52, 0.31, 1), u8"12 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.65, 0.19, 0.19, 1), u8"13 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.19, 0.25, 0.65, 1), u8"14 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.19, 0.65, 0.25, 1), u8"15 öâåò: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"16 öâåò: " .. lavkaname.v)
    

        imgui.EndChild()
        imgui.End()
    end

    ----- Íàñòðîéêè âðåìåíè è ïîãîäû
    if settime_window_state.v then
        
        imgui.SetNextWindowSize(imgui.ImVec2(190, 105), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2), sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8"Íàñòðîéêè âðåìåíè, ïîãîäû", settime_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('settingssettime', imgui.ImVec2(175, 70), false)

        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'×àñû', timehour, 0, 23)
        imgui.PopItemWidth()
        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'Ìèíóòû', timeminute, 0, 59)
        imgui.PopItemWidth()
        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'Ïîãîäà', weather, 0, 45)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.TextQuestion(u8'(?)', u8"0 - 7 = íåñêîëüêî âàðèàíòîâ ÷èñòîãî ñèíåãî íåáà\n08 = ãðîçà\n09 = ãóñòîé òóìàí è ïàñìóðíî\n10 = ÿñíîå íåáî\n11 = äèêîå ïåêëî\n12 - 15 = ñìóãëàÿ è íåïðèÿòíàÿ ïîãîäà\n16 = òóñêëàÿ è äîæäëèâàÿ\n17 - 18 = æàðà\n19 = ïåñ÷àíàÿ áóðÿ\n20 = òóìàííàÿ ïîãîäà\n21 = íî÷ü ñ ïóðïóðíûì íåáîì\n22 = íî÷ü ñ çåëåíîâàòûì íåáîì\n23 â 26 = èçìåíåíèÿ áëåäíîãî àïåëüñèíà\n27 â 29 = èçìåíåíèÿ ñâåæèé ñèíèå\n30 â 32 = èçìåíåíèÿ òåìíîãî, íåÿñíîãî, ÷èðêà\n33 = âå÷åð â êîðè÷íåâàòûõ îòòåíêàõ\n34 = ïîãîäà ñ ñèíèìè/ïóðïóðíûìè îòòåíêàìè\n35 = òóñêëàÿ è óíûëàÿ ïîãîäà â êîðè÷íåâûõ òîíàõ\n36 â 38 = ÿðêàÿ è òóìàííàÿ ïîãîäà â òîíàõ àïåëüñèíà\n39 = î÷åíü ÿðêàÿ ïîãîäà\n40 â 42 = íåÿñíàÿ ïîãîäà â ïóðïóðíûõ/ñèíèõ öâåòàõ\n43 = ò¸ìíûå è åäêèå îáëàêà\n44 = ÷¸ðíî-áåëîå íåáî\n45 = ïóðïóðíîå íåáî")

        imgui.EndChild()
        imgui.End()
    end

    ----- Íàñòðîéêè àâòîðåêîííåêòà
    if autoreconnect_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2), sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
        imgui.Begin(u8"Íàñòðîéêè Àâòî-Ðåêîííåêòà", autoreconnect_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        
        imgui.BeginChild('settingsautoreconnect', imgui.ImVec2(285, 165), false)

        imgui.PushItemWidth(100)
        imgui.InputInt(u8"Ìèíèìàëüíàÿ çàäåðæêà", minrecon)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Âûñòàâëÿåòñÿ â ñåêóíäàõ")

        imgui.PushItemWidth(100)
        imgui.InputInt(u8"Ìàêñèìàëüíàÿ çàäåðæêà", maxrecon)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Âûñòàâëÿåòñÿ â ñåêóíäàõ")


        imgui.Separator()

        imadd.ToggleButton("##timeactive", timeactive)
        imgui.SameLine()
        imgui.Text(u8"Íå ïåðåïîäêëþ÷àòüñÿ àâòîìàòè÷åñêè")
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Åñëè âû áûëè îòêëþ÷åíû â ýòî âðåìÿ, òî\nâû íå áóäåòå ïåðåïîäêëþ÷àòüñÿ àâòîìàòè÷åñêè\nP.s. âðåìÿ áåðåòñÿ ñ êîìïüþòåðà\nñïåöèàëüíî äëÿ Ìèøêè)")

        imgui.Text(u8"Îò")
        imgui.SameLine()
        imgui.PushItemWidth(25)
        imgui.InputInt('##1', hr1, 0, 0)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.SetCursorPosX(50)
        imgui.Text(u8'÷àñîâ ')
    
        imgui.Text(u8"Äî")
        imgui.SameLine()
        imgui.PushItemWidth(25)
        imgui.InputInt('##2', hr2, 0, 0)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.SetCursorPosX(50)
        imgui.Text(u8"÷àñîâ")
        


        if imgui.Button(u8'Ïðîâåðèòü Çíà÷åíèÿ') then
            if hr1.v >= 24 or hr1.v < 0 then
                hr1.v = 10
            elseif hr2.v >= 24 or hr2.v < 0 then
                hr2.v = 20
            elseif hr1.v >= hr2.v then
                hr1.v = 10
                hr2.v = 20
                sampAddChatMessage(tag .. textcolor .. "Âûñòàâèòå ÷àñû â ïîðÿäêå óâåëè÷åíèÿ!", tagcolor)
            end
        end
    


        imgui.EndChild()

        imgui.End()
        
    end


    ----- Îñíîâíîå îêíî
    if main_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(1000, 600), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2), sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
        imgui.Begin("N Helper", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
    
        imgui.BeginChild('', imgui.ImVec2(150, 565), false)
        imgui.SetCursorPos(imgui.ImVec2(55,10))
        imgui.Text(u8'Ìåíþ')
        imgui.SetCursorPos(imgui.ImVec2(55,35))
        imgui.Separator()
        imgui.SetCursorPos(imgui.ImVec2(10, 45))
        if imgui.Button(u8'Ìîäèôèêàöèè', imgui.ImVec2(130, 25)) then
         select_window = 1
        end
        imgui.SetCursorPos(imgui.ImVec2(10, 75))
        if imgui.Button(u8'Áèíäû êëàâèø', imgui.ImVec2(130, 25)) then
         select_window = 2
        end
        imgui.SetCursorPos(imgui.ImVec2(0, 530))
        imgui.Separator()
        imgui.Text(u8' Àâòîð: Azenizzka')
        imgui.SetCursorPos(imgui.ImVec2(0, 550))
        imgui.Text(u8" Âåðñèÿ: " .. script_vers_text)

        imgui.SetCursorPos(imgui.ImVec2(10, 485))
        imgui.Separator()
        imgui.SetCursorPos(imgui.ImVec2(10, 495))
        if imgui.Button(u8"Ñîõðàíèòü êîíôèã", imgui.ImVec2(130,25)) then
            funcsave()
        end 
        imgui.EndChild()

        imgui.SameLine()
        ------------------------------------- ÌÎÄÈÔÈÊÀÖÈÈ ----------------------------------------
        if select_window == 1 then
            imgui.BeginChild('1', imgui.ImVec2(830  , 565), false)
            imadd.ToggleButton("##active", autoreconnect)
            imgui.SameLine()
            imgui.Text(u8'Àâòîðåêîííåêò')
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8'Àâòîìàòè÷åñêîå ïåðåïîäêëþ÷åíèå ê ñåðâåðó,\nåñëè âû áûëè îòêëþ÷åíû.\nÇàäåðæêà íà ïåðåçàõîä âûáèðàåòñÿ ðàíäîìíî,\nâûñòàâëÿåòñÿ âàìè, îò ìèíèìàëüíîãî\näî ìàêñèìàëüíîãî çíà÷åíèÿ')
            imgui.SameLine(0, 10)
            if imgui.Button(u8'Íàñòðîéêè##1', imgui.ImVec2(75, 20)) then
                autoreconnect_window_state_func()
            end
            imadd.ToggleButton("##stime", twchange)
            imgui.SameLine()
            imgui.Text(u8"Èçìåíåíèå âðåìåíè è ïîãîäû")
            imgui.SameLine()
            if imgui.Button(u8"Íàñòðîéêè##2", imgui.ImVec2(75, 20)) then
                settime_window_state_func()
            end

            imadd.ToggleButton("##lavkanameactive", lavkanameactive)
            imgui.SameLine()
            imgui.Text(u8'Àâòî Ëàâêà')
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"Åñëè âû ïîñòàâèëè ëàâêó, òî\nñêðèïò ñàì ïèøåò åå íàçâàíèå\nè âûáèðàåò öâåò")
            imgui.SameLine()
            if imgui.Button(u8'Íàñòðîéêè##3', imgui.ImVec2(75, 20)) then
                lavkanameactive_window_state_func()
            end

            imadd.ToggleButton("##render", render)
            imgui.SameLine()
            imgui.Text(u8'Ðåíäåð')
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"Âàëë-Õàê íà ïðåäìåòû")
            imgui.SameLine()
            if imgui.Button(u8"Íàñòðîéêè##4", imgui.ImVec2(75,20)) then
                render_window_state_func()
            end

            imadd.ToggleButton("renderlavka", renderlavka)
            imgui.SameLine()
            imgui.Text(u8"Ðåíäåð ëàâêè")
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"Âàëë-Õàê íà ñâîáîäíûå ëàâêå\n(Äëÿ Öåíòðàëüíîãî ðûíêà)")
            imgui.SameLine()
            if imgui.Button(u8"Íàñòðîéêè", imgui.ImVec2(75, 20)) then
                render_lavka_state_func()
            end

            imgui.EndChild()
    
        elseif select_window == 2 then
            imgui.BeginChild('2', imgui.ImVec2(830, 565), false)
            
            imadd.ToggleButton("otkl", nhelpact)
            imgui.SameLine()
            imgui.Text(u8'Àêòèâàöèÿ ñêðèïòà')
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"Åñëè âêëþ÷åíî, òî ñêðèïò ìîæíî\nàêòèâèðîâàòü ïî êíîïêå")
            if imgui.HotKey('##1', ActiveMenu, _, 75) then
                rkeys.changeHotKey(bindMenu, ActiveMenu.v)
                sampAddChatMessage(tag .. textcolor .. "Âû óñïåøíî èçìåíèëè êëàâèøó àêòèâàöèè íà: " .. warncolor .. table.concat(rkeys.getKeysName(ActiveMenu.v), " + "), tagcolor)

            end
        
    
            imgui.EndChild()
        end
        imgui.End()
    end
end

----- Êîìàíäà /nhelp
function nhelp_cmd()
    main_window_state.v = not main_window_state.v
    imgui.Process = main_window_state.v
end

----- Óñòàíîâêà ïîãîäû
function setWeather()
    local abc = tonumber(weather.v)
    if abc ~= nil and abc >= 0 and abc <= 45 then
      forceWeatherNow(abc)
    end
end

----- Óñòàíîâêà âðåìåíè
function setTime()
    setTimeOfDay(timehour.v, timeminute.v)
end

----- Îêíî íàñòðîåê ÀâòîÐåêîííåêòà
function autoreconnect_window_state_func()
    autoreconnect_window_state.v = not autoreconnect_window_state.v
end

----- Îêíî Íàñòðîåê âðåìåíè è ïîãîäû
function settime_window_state_func()
    settime_window_state.v = not settime_window_state.v
end

----- Îêíî íàñòðîåê ðåíäåðà
function render_window_state_func()
    render_window_state.v = not render_window_state.v
end

----- Ïîäêëþ÷åí ê ñåðâåðó èëè íåò? Åñëè íåò, òî ðåêîííåêò
function onReceivePacket(id)
    if id == 32 and autoreconnect.v then
        lua_thread.create(function()
            local ip, port = sampGetCurrentServerAddress()
            math.randomseed(os.clock())
            local a = math.random(minrecon.v, maxrecon.v)
            sampAddChatMessage(tag .. textcolor .. 'Çàäåðæêà: '.. warncolor .. a .. textcolor .. ' ñåê.', tagcolor)
            wait(a * 1000)

            local canreconnecthr = true
            local hrs = tonumber(os.date("%H"))
            if timeactive.v then
                if hrs >= hr1.v and hrs <= hr2.v then
                    canreconnecthr = false
                end
            end

            if id == 32 and canreconnecthr then 
                 sampConnectToServer(ip, port)
            else
                sampAddChatMessage(tag .. textcolor .. "Îòìåíà àâòîðåêîííåêòà, âû óæå ïåðåçàøëè, èëè ó íàñ âûáðàíî íå òî âðåìÿ", tagcolor)
            end
        end)
    end
end

----- Êîìàíäà /reconnect
function reconnect_cmd(arg)
    lua_thread.create(function()
        sampSetGamestate(5)
        local ip, port = sampGetCurrentServerAddress()
        sampAddChatMessage(tag .. textcolor .. 'Çàäåðæêà: '.. warncolor.. arg .. textcolor ..' ñåê.', tagcolor)
        wait(arg * 1000)
        sampConnectToServer(ip, port)
    end)
end

----- imgui.TextQuestion()
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
----- Îêíî íàñòðîåê ëàâêè 
function lavkanameactive_window_state_func()
    lavkanameactive_window_state.v = not lavkanameactive_window_state.v
end

function render_lavka_state_func()
    render_lavka_state.v = not render_lavka_state.v
end

----- Ôóíêöèÿ ëàâêè + äèàëîã
function sampev.onShowDialog(id, style, title, b1, b2, text)

    if lavkanameactive.v then
        if id == 3021 then
            sampSendDialogResponse(3021, 1, 0, _)
        end
        if id == 3020 then
            sampSendDialogResponse(3020, 1, _, lavkaname.v)
        end

        
        if id == 3030 then
            sampSendDialogResponse(3030, 1, selecteditem.v, _)
        end
    end

    ----- 25528 âûáîð ñïàâíà

    
end

function check_cmd()
    local id = sampGetCurrentDialogId()
    local x, y, z = getCharCoordinates(PLAYER_PED)
    local Object = createObject(19336, x+10, y, z)
    setObjectScale(antennaObject, 1)
    createObject(19203, x, y, z)
    sampAddChatMessage("ß ãåé êñòà)", -1)
end


----- Ôóíêöèÿ ñîõðàíåíèÿ
function funcsave()
    mainIni.settings.key = encodeJson(ActiveMenu.v)
    mainIni.settings.autoreconnect = autoreconnect.v
    mainIni.settings.minrecon = minrecon.v
    mainIni.settings.maxrecon = maxrecon.v
    mainIni.settings.timeactive = timeactive.v
    mainIni.settings.hr1 = hr1.v
    mainIni.settings.hr2 = hr2.v
    mainIni.settings.twchange = twchange.v
    mainIni.settings.timehour = timehour.v
    mainIni.settings.weather = weather.v
    mainIni.settings.timeminute = timeminute.v
    mainIni.settings.lavkanameactive = lavkanameactive.v
    mainIni.settings.lavkaname = lavkaname.v
    mainIni.settings.selecteditem = selecteditem.v
    mainIni.settings.render = render.v
    mainIni.settings.rolen = rolen.v
    mainIni.settings.rlines = rlines.v
    mainIni.settings.rname = rname.v
    mainIni.settings.width = width.v
    mainIni.settings.widthtext = widthtext.v
    mainIni.settings.rsemena = rsemena.v
    mainIni.settings.nhelpact = nhelpact.v
    mainIni.settings.renderlavka = renderlavka.v
    mainIni.settings.robject = robject.v
    mainIni.settings.renderid = renderid.v

    inicfg.save(mainIni, directIni)

    sampAddChatMessage(tag .. textcolor .. "Íàñòðîéêè áûëè ñîõðàíåíû!", tagcolor)
end

----- Ôóíêöèÿ öåíòðèðîâàíèÿ êóðñîðà
function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

----- Òåìà èìãóè
function theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
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

function nhelp()
    if nhelpact.v then
        main_window_state.v = not main_window_state.v
        imgui.Process = main_window_state.v
    end

end

