local sampev = require 'samp.events'
local f = require 'moonloader'.font_flag
local font = renderCreateFont('Arial', 10, f.BOLD + f.SHADOW)
local active = false
local lavki = {}

function main()
    repeat wait(0) until isSampAvailable()
    sampRegisterChatCommand('lavki', function() active = not active end)
    
    while true do wait(0)

        if active then
            local input = sampGetInputInfoPtr()
            local input = getStructElement(input, 0x8, 4)
            local PosX = getStructElement(input, 0x8, 4)
            local PosY = getStructElement(input, 0xC, 4)
            renderFontDrawText(font, 'Свободно лавок: '..#lavki, PosX, PosY + 80, 0xFFFFFFFF, 0x90000000)
            
            for v = 1, #lavki do
                
                if doesObjectExist(lavki[v]) then
                    local result, obX, obY, obZ = getObjectCoordinates(lavki[v])
                    local x, y, z = getCharCoordinates(PLAYER_PED)
                    
                    if result then
                        local ObjX, ObjY = convert3DCoordsToScreen(obX, obY, obZ)
                        local myX, myY = convert3DCoordsToScreen(x, y, z)

                        if isObjectOnScreen(lavki[v]) then
                            renderDrawLine(ObjX, ObjY, myX, myY, 1, 0xFF52FF4D)
                            renderDrawPolygon(myX, myY, 10, 10, 10, 0, 0xFFFFFFFF)
                            renderDrawPolygon(ObjX, ObjY, 10, 10, 10, 0, 0xFFFFFFFF)
                            renderFontDrawText(font, 'Свободна', ObjX - 30, ObjY - 20, 0xFF16C910, 0x90000000)
                        end
                    end
                end
            end
        end
    end
end


function sampev.onSetObjectMaterialText(id, data)
    
    if data.text:find('Номер %d+%. {......}Свободная!') then
        local object = sampGetObjectHandleBySampId(id) 
        table.insert(lavki, object)
    else
        local ob = sampGetObjectHandleBySampId(id)
        for i = 1, #lavki do
            if ob == lavki[i] then
                table.remove(lavki, i)
            end
        end
    end
end

function sampev.onDestroyObject(id)
    for k = 1, #lavki do
        local ob = sampGetObjectHandleBySampId(id)
        if ob == lavki[k] then
            table.remove(lavki, k)
        end
    end
end

