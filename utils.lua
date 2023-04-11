local utils = {}

function utils.tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

function utils.splitString(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

return utils