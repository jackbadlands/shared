local function cp1251_to_ibm866 (str) 
    local symbols = {} 
    for char in string.gmatch(str, ".") do 
        local byte = string.byte(char) 
        if byte >= 192 and byte <= 239 then 
            table.insert(symbols, string.char(byte - 64)) 
        elseif byte >= 240 and byte <= 255 then 
            table.insert(symbols, string.char(byte - 16)) 
        else 
            table.insert(symbols, char) 
        end 
    end 
    return table.concat(symbols, "") 
end 

local function ibm866_to_cp1251 (str) 
    local symbols = {} 
    for char in string.gmatch(str, ".") do 
        local byte = string.byte(char) 
        if byte >= (192 - 64) and byte <= (239 - 64) then 
            table.insert(symbols, string.char(byte + 64)) 
        elseif byte >= (240 - 16) and byte <= (255 - 16) then 
            table.insert(symbols, string.char(byte + 16)) 
        else 
            table.insert(symbols, char) 
        end 
    end 
    return table.concat(symbols, "") 
end 

conv_ibm866_cp1251 = {
	ibm866_to_cp1251 = ibm866_to_cp1251,
	cp1251_to_ibm866 = cp1251_to_ibm866,
}

return conv_ibm866_cp1251

