local drawIcon = require "drawIcon"
local ae2 = peripheral.wrap('back');
local termOutput = term
local monitor = peripheral.wrap('top');
if monitor then
    termOutput = monitor
end

local maxHistory, maxHeight = termOutput.getSize();
local graphColor = colors.red;
local itemName = 'diamond'

maxHeight = maxHeight - 3
maxHistory = maxHistory - 7

local history = {1,3,5,9,12,18,14,12}
local previousValue = 0
local previousLongValue = 0
local previousTimer = 0
local loopSpeed = 0.2

local function addHistory(value)
    table.insert(history, value) -- inserts the value into "history"
    if #history > maxHistory then -- if there's too many items in the table ...
        table.remove(history, 1) -- remove the oldest value
    end
end

local function getItemCount()
    itemMetadata = ae2.findItem(itemName).getMetadata()
    return itemMetadata.count
end

local function getFakeItemCount()
    if previousValue == 0 then
        return math.floor(100000 * math.random())
    end

    return previousValue - (10 - (20 * math.random()))
end

local function getMaxOfList(list)
    return math.max(unpack(list))
end

local function getMinOfList(list)
    return math.min(unpack(list))
end

local function clearTerm()
    termOutput.setBackgroundColor(colors.black);
    termOutput.clear()
end
 
function drawPixel(x, y, color)
    local tempColor = graphColor
    if color then
        tempColor = color
    end

    termOutput.setCursorPos(x, y)
    termOutput.setBackgroundColor(tempColor)
    termOutput.write(" ")
end 

function normalizeList(list)
    local minValue = list[1]
    local maxValue = list[1]
    for i = 2, #list do
        if list[i] < minValue then
            minValue = list[i]
        elseif list[i] > maxValue then
            maxValue = list[i]
        end
    end
    local range = maxValue - minValue
    local normalized = {}
    for i = 1, #list do
        if range == 0 then
            normalized[i] = 1
        else
            normalized[i] = (maxValue - list[i]) / range
        end
    end
    return normalized
end


function convertToPositions(list)
    local positions = {}
    local normalizedList = normalizeList(list)
    for i = 1, #list do
        positions[i] = normalizedList[i] * maxHeight
    end
    return positions
end

local function drawGraph(history, startX, startY)

    local positions = convertToPositions(history)
    for x = 1, maxHistory, 1 do
        local y = positions[x]
        if y then
            local previousY = positions[x-1]
            if previousY then
                local diffY = previousY - y
                if not (diffY == 0) then
                    if diffY > 0 then
                        for i = previousY, y, -1 do
                            drawPixel(x - 1 + startX, math.floor(i) + startY, colors.green)
                        end
                    else
                        for i = y, previousY, -1 do
                            drawPixel(x - 1 + startX, math.floor(i) + startY)
                        end
                    end
                end
            end

            drawPixel(x + startX, math.floor(y) + startY)
        end
    end
end

clearTerm()

function write(x,y,text, color)
    local tempColor = termOutput.getTextColor()
    if color then
        termOutput.setTextColor(color)
    end
    termOutput.setCursorPos(x,y)
    termOutput.write(text)
    termOutput.setTextColor(tempColor)
end

function writeCurrentCount(itemCount)
    local diff = itemCount - previousValue
    local op = ''
    local diffColor = colors.white
    if(diff < 0) then
        diffColor = colors.red
    elseif diff > 0 then
        op = "+"
        diffColor = colors.green
    end
    local baseText = 'Current ' ..itemName.. ' count : ' .. itemCount
    write(1, 1, baseText)
    write(#baseText, 1, '('.. op .. diff ..')', diffColor)
end

function writeLongDiff(itemCount)
    local diff = itemCount - previousLongValue
    local op = ''
    local diffColor = colors.white
    if(diff < 0) then
        diffColor = colors.red
    elseif diff > 0 then
        op = "+"
        diffColor = colors.green
    end
    local baseText = 'Diff in the past 5 minutes :  '
    write(1, 2, baseText)
    write(#baseText, 2, op .. diff, diffColor)
end

while true do
    local itemCount = 1
    clearTerm()

    if previousLongValue == 0 then
        previousLongValue = itemCount
    end

    writeCurrentCount(itemCount)
    writeLongDiff(itemCount)

    addHistory(itemCount)

    local min = getMinOfList(history)
    local max = getMaxOfList(history)

    write(1,3,tostring(max))
    write(1,maxHeight + 3,tostring(min))

    drawGraph(history, 7, 3)
    previousValue = itemCount
    if previousLongValue == 0 then
        previousLongValue = itemCount
    end
    os.sleep(loopSpeed)

    previousTimer = previousTimer + 1

    if previousTimer == ((1 * loopSpeed) * 60 * 5) then
        previousTimer = 0
        previousLongValue = itemCount
    end
end