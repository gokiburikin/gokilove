--[[ Big Number Formatting ]]

local bnf = {}
bnf.precision = 2
bnf.symbols = {}

function bnf.attach(symbol,digits)
	bnf.symbols[digits] = symbol
end

function bnf.detach(digits)
	bnf.symbols[digits] = nil
end

function bnf.flatFormat(number,decimals)
	decimals = decimals or 0
	return string.format("%." .. decimals .. "f",number)
end

function bnf.format(number,decimals)
	number = bnf.flatFormat(number,decimals)
	local digits = #(math.floor(tonumber(number)) .. "") - bnf.precision
	local truncated = 0
	local symbol = ""
	for i=digits-1,1,-1 do
		if bnf.symbols[i] ~= nil then
			symbol = bnf.symbols[i]
			truncated = i
			break
		end
	end
	local decimalTruncation = 0
	if decimals > 0 then
		decimalTruncation = decimals + 1
	end
	return (number .. ""):sub(1, digits - truncated + bnf.precision + decimalTruncation) .. symbol
end

bnf.attach("K",3)
bnf.attach("M",6)
bnf.attach("G",9)
bnf.attach("T",12)
bnf.attach("P",15)
bnf.attach("E",18)
bnf.attach("Z",21)
bnf.attach("Y",24)

return bnf