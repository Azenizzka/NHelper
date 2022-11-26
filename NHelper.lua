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

local script_url = ""
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
                sampAddChatMessage(tag .. textcolor .. "Обнаружено обновление! Старая версия: " .. warncolor .. script_vers_text .. textcolor .. " Новая версия: " .. updateIni.update.vers_text, tagcolor)
                sampAddChatMessage(tag .. textcolor .. "Начинаю установку обновления " .. warncolor .. updateIni.update.vers_text .. textcolor .. "..", tagcolor)
                update_status = true
            elseif tonumber(updateIni.update.vers) == script_vers then
                sampAddChatMessage(tag .. textcolor .. "Обновлений не обнаружено!", tagcolor)
            end
            os.remove(update_path)
        end
    end)



    ------------------

    sampAddChatMessage(tag .. textcolor .. "Скрипт успешно загружен! Версия: " .. script_vers_text, tagcolor)
    sampAddChatMessage(tag .. textcolor .. "Активация скрипта: " .. warncolor .. "/nhelp " .. textcolor .. "или " .. warncolor .. table.concat( rkeys.getKeysName(ActiveMenu.v), "+"), tagcolor)
    sampAddChatMessage(tag .. textcolor .. "Автор скрипта: " .. warncolor .. "Azenizzka", tagcolor)

    bindMenu = rkeys.registerHotKey(ActiveMenu.v, true, nhelp)

    theme()

    imgui.Process = false

    while true do
        wait(0)

        --------------- AUTO_UPDATE -------------
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(tag .. textcolor .. "Скрипт успешно обновлен!", tagcolor)
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
                    local name = "Олень"
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
                    local name = "Семена"
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
    
    ----- Проверка imgui Process
    if not autoreconnect_window_state.v and not main_window_state.v and not settime_window_state.v and not lavkanameactive_window_state.v and not render_window_state.v and not render_lavka_state.v then
        imgui.Process = false
    end

    ----- Настройки рендера лавок
    if render_lavka_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(330,200), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Настройки Рендера Лавок", render_lavka_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('lavkarendersettings', imgui.ImVec2(315, 165), false)


        imgui.EndChild()
        imgui.End()
    end

    ----- Настройки Рендера
    if render_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(340,200), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Настройки Рендера", render_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('rendersettings', imgui.ImVec2(325, 165), false)

        imadd.ToggleButton("Линии", rlines)
        imgui.SameLine()
        imgui.Text(u8'Линии')
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Будет вести линии\nдо обьекта")
        imgui.SameLine()
        imgui.SetCursorPosX(130)
        imgui.PushItemWidth(100)
        imgui.SliderFloat(u8'Ширина линий', width, 0.1, 10)
        imgui.PopItemWidth()

        imadd.ToggleButton('Тип', rname)
        imgui.SameLine()
        imgui.Text(u8"Обьект")
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Будет отображаться\nназвание предмета, на который\nнастроен рендер")
        imgui.SameLine()
        imgui.SetCursorPosX(130)
        imgui.PushItemWidth(100)
        if imgui.SliderInt(u8'Размер текста', widthtext, 1, 40) then
            font = renderCreateFont("Arial Black", widthtext.v)    
        end
        imgui.PopItemWidth()
        imadd.ToggleButton("id object", robject)
        imgui.SameLine()
        imgui.Text(u8"Ид обьекта")
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Валл-Хак на ид обьекта, который\nвы указали")

        imgui.SameLine(_, 50)
        imgui.SetCursorPosX(130)
        imgui.PushItemWidth(100)
        imgui.InputInt('##1', renderid, -1, -1)
        imgui.PopItemWidth()

        imgui.Separator()

        imadd.ToggleButton("Олени", rolen)
        imgui.SameLine()
        imgui.Text(u8"Олени")

        imadd.ToggleButton("Семена", rsemena)
        imgui.SameLine()
        imgui.Text(u8"Семена")

        imgui.EndChild()
        imgui.End()

    end


    ----- Настройки лавки 
    if lavkanameactive_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 400), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2), sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Настройки лавки", lavkanameactive_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('lavkanameactive', imgui.ImVec2(285, 365), false)
        imgui.PushItemWidth(150)
        imgui.InputText(u8'Название лавки', lavkaname)
        imgui.PopItemWidth()

        if imgui.Button(u8'Сохранить название', imgui.ImVec2(130, 20)) then
            mainIni.settings.lavkaname = lavkaname.v
            inicfg.save(mainIni, directIni)
            local textvalue = #lavkaname.v
            if textvalue >= 21 then
                lavkaname.v = ""
                sampAddChatMessage(tag .. textcolor .. "Количество символов должно быть от " .. warncolor .. "3 " .. textcolor .. "до " .. warncolor .. "20" .. textcolor .. ".", tagcolor)
            elseif textvalue <= 2 then
                lavkaname.v = ""
                sampAddChatMessage(tag .. textcolor .. "Количество символов должно быть от " .. warncolor .. "3 " .. textcolor .. "до " .. warncolor .. "20" .. textcolor .. ".", tagcolor)
            elseif textvalue then
                sampAddChatMessage(tag .. textcolor .. "Название успешно сохранено!", tagcolor)
            end
        end
        imgui.Separator()
        imgui.Combo(u8'Выбор цвета', selecteditem, {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"}, -1)
        imgui.Separator()   
        imgui.TextColored(imgui.ImVec4(0.91, 0.31, 0.31, 1), u8"1 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.91, 0.31, 0.75, 1), u8"2 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.71, 0.31, 0.91, 1), u8"3 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.4, 0.31, 0.91, 1), u8"4 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.31, 0.62, 0.91, 1), u8"5 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.31, 0.84, 0.91, 1), u8"6 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.31, 0.91, 0.64, 1), u8"7 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.31, 0.91, 0.38, 1), u8"8 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.62, 0.91, 0.31, 1), u8"9 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.82, 0.91, 0.31, 1), u8"10 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.91, 0.74, 0.31, 1), u8"11 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.91, 0.52, 0.31, 1), u8"12 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.65, 0.19, 0.19, 1), u8"13 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.19, 0.25, 0.65, 1), u8"14 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(0.19, 0.65, 0.25, 1), u8"15 цвет: " .. lavkaname.v)
        imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"16 цвет: " .. lavkaname.v)
    

        imgui.EndChild()
        imgui.End()
    end

    ----- Настройки времени и погоды
    if settime_window_state.v then
        
        imgui.SetNextWindowSize(imgui.ImVec2(190, 105), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2), sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8"Настройки времени, погоды", settime_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild('settingssettime', imgui.ImVec2(175, 70), false)

        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'Часы', timehour, 0, 23)
        imgui.PopItemWidth()
        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'Минуты', timeminute, 0, 59)
        imgui.PopItemWidth()
        imgui.PushItemWidth(100)
        imgui.SliderInt(u8'Погода', weather, 0, 45)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.TextQuestion(u8'(?)', u8"0 - 7 = несколько вариантов чистого синего неба\n08 = гроза\n09 = густой туман и пасмурно\n10 = ясное небо\n11 = дикое пекло\n12 - 15 = смуглая и неприятная погода\n16 = тусклая и дождливая\n17 - 18 = жара\n19 = песчаная буря\n20 = туманная погода\n21 = ночь с пурпурным небом\n22 = ночь с зеленоватым небом\n23 в 26 = изменения бледного апельсина\n27 в 29 = изменения свежий синие\n30 в 32 = изменения темного, неясного, чирка\n33 = вечер в коричневатых оттенках\n34 = погода с синими/пурпурными оттенками\n35 = тусклая и унылая погода в коричневых тонах\n36 в 38 = яркая и туманная погода в тонах апельсина\n39 = очень яркая погода\n40 в 42 = неясная погода в пурпурных/синих цветах\n43 = тёмные и едкие облака\n44 = чёрно-белое небо\n45 = пурпурное небо")

        imgui.EndChild()
        imgui.End()
    end

    ----- Настройки автореконнекта
    if autoreconnect_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2), sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
        imgui.Begin(u8"Настройки Авто-Реконнекта", autoreconnect_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        
        imgui.BeginChild('settingsautoreconnect', imgui.ImVec2(285, 165), false)

        imgui.PushItemWidth(100)
        imgui.InputInt(u8"Минимальная задержка", minrecon)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Выставляется в секундах")

        imgui.PushItemWidth(100)
        imgui.InputInt(u8"Максимальная задержка", maxrecon)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Выставляется в секундах")


        imgui.Separator()

        imadd.ToggleButton("##timeactive", timeactive)
        imgui.SameLine()
        imgui.Text(u8"Не переподключаться автоматически")
        imgui.SameLine()
        imgui.TextQuestion('(?)', u8"Если вы были отключены в это время, то\nвы не будете переподключаться автоматически\nP.s. время берется с компьютера\nспециально для Мишки)")

        imgui.Text(u8"От")
        imgui.SameLine()
        imgui.PushItemWidth(25)
        imgui.InputInt('##1', hr1, 0, 0)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.SetCursorPosX(50)
        imgui.Text(u8'часов ')
    
        imgui.Text(u8"До")
        imgui.SameLine()
        imgui.PushItemWidth(25)
        imgui.InputInt('##2', hr2, 0, 0)
        imgui.PopItemWidth()
        imgui.SameLine()
        imgui.SetCursorPosX(50)
        imgui.Text(u8"часов")
        


        if imgui.Button(u8'Проверить Значения') then
            if hr1.v >= 24 or hr1.v < 0 then
                hr1.v = 10
            elseif hr2.v >= 24 or hr2.v < 0 then
                hr2.v = 20
            elseif hr1.v >= hr2.v then
                hr1.v = 10
                hr2.v = 20
                sampAddChatMessage(tag .. textcolor .. "Выставите часы в порядке увеличения!", tagcolor)
            end
        end
    


        imgui.EndChild()

        imgui.End()
        
    end


    ----- Основное окно
    if main_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(1000, 600), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2), sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
        imgui.Begin("N Helper", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
    
        imgui.BeginChild('', imgui.ImVec2(150, 565), false)
        imgui.SetCursorPos(imgui.ImVec2(55,10))
        imgui.Text(u8'Меню')
        imgui.SetCursorPos(imgui.ImVec2(55,35))
        imgui.Separator()
        imgui.SetCursorPos(imgui.ImVec2(10, 45))
        if imgui.Button(u8'Модификации', imgui.ImVec2(130, 25)) then
         select_window = 1
        end
        imgui.SetCursorPos(imgui.ImVec2(10, 75))
        if imgui.Button(u8'Бинды клавиш', imgui.ImVec2(130, 25)) then
         select_window = 2
        end
        imgui.SetCursorPos(imgui.ImVec2(0, 530))
        imgui.Separator()
        imgui.Text(u8' Автор: Azenizzka')
        imgui.SetCursorPos(imgui.ImVec2(0, 550))
        imgui.Text(u8" Версия: " .. script_vers_text)

        imgui.SetCursorPos(imgui.ImVec2(10, 485))
        imgui.Separator()
        imgui.SetCursorPos(imgui.ImVec2(10, 495))
        if imgui.Button(u8"Сохранить конфиг", imgui.ImVec2(130,25)) then
            funcsave()
        end 
        imgui.EndChild()

        imgui.SameLine()
        ------------------------------------- МОДИФИКАЦИИ ----------------------------------------
        if select_window == 1 then
            imgui.BeginChild('1', imgui.ImVec2(830  , 565), false)
            imadd.ToggleButton("##active", autoreconnect)
            imgui.SameLine()
            imgui.Text(u8'Автореконнект')
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8'Автоматическое переподключение к серверу,\nесли вы были отключены.\nЗадержка на перезаход выбирается рандомно,\nвыставляется вами, от минимального\nдо максимального значения')
            imgui.SameLine(0, 10)
            if imgui.Button(u8'Настройки##1', imgui.ImVec2(75, 20)) then
                autoreconnect_window_state_func()
            end
            imadd.ToggleButton("##stime", twchange)
            imgui.SameLine()
            imgui.Text(u8"Изменение времени и погоды")
            imgui.SameLine()
            if imgui.Button(u8"Настройки##2", imgui.ImVec2(75, 20)) then
                settime_window_state_func()
            end

            imadd.ToggleButton("##lavkanameactive", lavkanameactive)
            imgui.SameLine()
            imgui.Text(u8'Авто Лавка')
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"Если вы поставили лавку, то\nскрипт сам пишет ее название\nи выбирает цвет")
            imgui.SameLine()
            if imgui.Button(u8'Настройки##3', imgui.ImVec2(75, 20)) then
                lavkanameactive_window_state_func()
            end

            imadd.ToggleButton("##render", render)
            imgui.SameLine()
            imgui.Text(u8'Рендер')
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"Валл-Хак на предметы")
            imgui.SameLine()
            if imgui.Button(u8"Настройки##4", imgui.ImVec2(75,20)) then
                render_window_state_func()
            end

            imadd.ToggleButton("renderlavka", renderlavka)
            imgui.SameLine()
            imgui.Text(u8"Рендер лавки")
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"Валл-Хак на свободные лавке\n(Для Центрального рынка)")
            imgui.SameLine()
            if imgui.Button(u8"Настройки", imgui.ImVec2(75, 20)) then
                render_lavka_state_func()
            end

            imgui.EndChild()
    
        elseif select_window == 2 then
            imgui.BeginChild('2', imgui.ImVec2(830, 565), false)
            
            imadd.ToggleButton("otkl", nhelpact)
            imgui.SameLine()
            imgui.Text(u8'Активация скрипта')
            imgui.SameLine()
            imgui.TextQuestion('(?)', u8"Если включено, то скрипт можно\nактивировать по кнопке")
            if imgui.HotKey('##1', ActiveMenu, _, 75) then
                rkeys.changeHotKey(bindMenu, ActiveMenu.v)
                sampAddChatMessage(tag .. textcolor .. "Вы успешно изменили клавишу активации на: " .. warncolor .. table.concat(rkeys.getKeysName(ActiveMenu.v), " + "), tagcolor)

            end
        
    
            imgui.EndChild()
        end
        imgui.End()
    end
end

----- Команда /nhelp
function nhelp_cmd()
    main_window_state.v = not main_window_state.v
    imgui.Process = main_window_state.v
end

----- Установка погоды
function setWeather()
    local abc = tonumber(weather.v)
    if abc ~= nil and abc >= 0 and abc <= 45 then
      forceWeatherNow(abc)
    end
end

----- Установка времени
function setTime()
    setTimeOfDay(timehour.v, timeminute.v)
end

----- Окно настроек АвтоРеконнекта
function autoreconnect_window_state_func()
    autoreconnect_window_state.v = not autoreconnect_window_state.v
end

----- Окно Настроек времени и погоды
function settime_window_state_func()
    settime_window_state.v = not settime_window_state.v
end

----- Окно настроек рендера
function render_window_state_func()
    render_window_state.v = not render_window_state.v
end

----- Подключен к серверу или нет? Если нет, то реконнект
function onReceivePacket(id)
    if id == 32 and autoreconnect.v then
        lua_thread.create(function()
            local ip, port = sampGetCurrentServerAddress()
            math.randomseed(os.clock())
            local a = math.random(minrecon.v, maxrecon.v)
            sampAddChatMessage(tag .. textcolor .. 'Задержка: '.. warncolor .. a .. textcolor .. ' сек.', tagcolor)
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
                sampAddChatMessage(tag .. textcolor .. "Отмена автореконнекта, вы уже перезашли, или у нас выбрано не то время", tagcolor)
            end
        end)
    end
end

----- Команда /reconnect
function reconnect_cmd(arg)
    lua_thread.create(function()
        sampSetGamestate(5)
        local ip, port = sampGetCurrentServerAddress()
        sampAddChatMessage(tag .. textcolor .. 'Задержка: '.. warncolor.. arg .. textcolor ..' сек.', tagcolor)
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
----- Окно настроек лавки 
function lavkanameactive_window_state_func()
    lavkanameactive_window_state.v = not lavkanameactive_window_state.v
end

function render_lavka_state_func()
    render_lavka_state.v = not render_lavka_state.v
end

----- Функция лавки + диалог
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

    ----- 25528 выбор спавна

    
end

function check_cmd()
    local id = sampGetCurrentDialogId()
    local x, y, z = getCharCoordinates(PLAYER_PED)
    local Object = createObject(19336, x+10, y, z)
    setObjectScale(antennaObject, 1)
    createObject(19203, x, y, z)
    sampAddChatMessage("Я гей кста)", -1)
end


----- Функция сохранения
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

    sampAddChatMessage(tag .. textcolor .. "Настройки были сохранены!", tagcolor)
end

----- Функция центрирования курсора
function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

----- Тема имгуи
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

