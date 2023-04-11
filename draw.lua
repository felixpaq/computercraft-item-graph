local utils = require "utils"
local draw = {}
local MAX_COLORS = 16
local MAX_COLOR_VALUE = 2^(MAX_COLORS-1)
function draw.init(specificTerm)
    draw.term = specificTerm
    draw.backupColors = colors
    draw.colors = {}
end

function draw.clearTerm()
    draw.term.setBackgroundColor(colors.black)
    draw.term.clear()
end

function draw.resetColors()
    local colorCount = 16

    for i = 1, colorCount, 1 do
        local palette = 2^(i-1)
        draw.term.setPaletteColor(palette, draw.term.nativePaletteColor(palette))
    end
end

function storeColor(colorVector)
    if not (draw.colors[colorVector]) then
        local color = utils.tablelength(draw.colors)+1
        local palette = 2^(color-1)
        draw.colors[colorVector] = palette
        local r,g,b = table.unpack(utils.splitString(colorVector, ','))
        print(palette)
        if(palette > MAX_COLOR_VALUE) then
            draw.resetColors()
            error("too many colors")
        end

        draw.term.setPaletteColor(palette, tonumber(r)/255, tonumber(g)/255, tonumber(b)/255)
    end
    return draw.colors[colorVector]
end

function convertRGBtoTable(rgbFilePath)
    local t = {}

    for line in io.lines(rgbFilePath) do
        local lineT = {}
        local pixels = utils.splitString(line, ':')
        for key, value in pairs(pixels) do
            local newColor = storeColor(value)
            table.insert(lineT, newColor)
        end
        table.insert(t, lineT)
    end
    return t
end

function draw.drawPixel(x, y, color)
    paintutils.drawPixel(x,y,color)
end 

function draw.write(x,y,text, color)
    local tempColor = draw.term.getTextColor()
    if color then
        draw.term.setTextColor(color)
    end
    draw.term.setCursorPos(x,y)
    draw.term.write(text)
    draw.term.setTextColor(tempColor)
end

function draw.drawIcon(iconName, meta)

    draw.clearTerm()
    
    local itemName = iconName:gsub(":", "_").."-"..meta
    local filename = itemName .. ".rgb"

    if(fs.exists("/icons/"..filename)) then

        local shape = convertRGBtoTable("/icons/"..filename)

        if(utils.tablelength(draw.colors) > MAX_COLORS) then
            print('too many colors')
            return
        end

        local width = utils.tablelength(shape[1])
        local height = utils.tablelength(shape)

        local termWidth, termHeight = draw.term.getSize();

        local offsetX = (termWidth - width) / 2
        local offsetY = (termHeight - height) / 2

        for y = 1, height, 1 do
            local row = shape[y]
            for x = 1, width, 1 do
                local pixel = row[x]
                --draw.write(x + offsetX, y + offsetY, pixel)
                draw.drawPixel(x + offsetX, y + offsetY, pixel)
            end
        end
    end

end

return draw