local pl = {
	file = require "pl.file",
	dir = require "pl.dir",
	path = require "pl.path",
}

local pretty = require "pl.pretty"

local wrap_str_t = {
	"BEGIN:VENV",
	"BEGIN:VBODY",
	"Date:01.01.2015 21:00:00",
	"TEXT;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:",
	"END:VBODY",
	"END:VENV",
	"END:VMSG",
}

local input_fname = assert(arg[1], "arg #1 as input file name expected")
local output_fname_prefix = assert(arg[2], "arg #2 as output file name prefix expected")

function quote_utf8(str)
	local bytes = { string.byte(tostring(str), 1, -1) }
	local escaped_chars = {}
	for byte_idx, byte in ipairs(bytes) do
		table.insert(escaped_chars, string.format("=%02X", byte))
	end
	return table.concat(escaped_chars)
end

function gen_out_fname(prefix, n)
	return string.format("%s_%03d.vmg", tostring(prefix),
			assert(tonumber(n), "gen_out_fname() arg #2: expected number")
		)
end

function read_file_and_split_by_lines(fname, part_lines_n)

	part_lines_n = tonumber(part_lines_n) or 10

	local fd = assert(io.open(fname, "rb"))

	local blocks = {}
	local cur_block_n = 1
	local cur_line_in_block = 0

	for line in fd:lines() do
		
		-- Calculate block number
		cur_line_in_block = cur_line_in_block + 1
		if cur_line_in_block > part_lines_n then
			cur_line_in_block = 1
			cur_block_n = cur_block_n + 1
		end

		-- Prepare block
		blocks[cur_block_n] = blocks[cur_block_n] or {}

		-- Write data to block
		table.insert(blocks[cur_block_n], line)
		table.insert(blocks[cur_block_n], "\n")
	end

	fd:close()

	return blocks
end

function read_file_and_split_by_words(fname, part_size)

	part_size = tonumber(part_size) or 1600

	local fd = assert(io.open(fname, "rb"))
	local fdata = fd:read("*a")
	fd:close()

	local blocks = {}
	local cur_block_n = 1
	local cur_block_size = 0

	for word in string.gmatch(fdata, "(%S+%s*)") do
		
		-- Calculate block number
		cur_block_size = cur_block_size + string.len(word)
		if cur_block_size > part_size then
			cur_block_size = string.len(word)
			cur_block_n = cur_block_n + 1
		end

		-- Prepare block
		blocks[cur_block_n] = blocks[cur_block_n] or {}

		-- Write data to block
		table.insert(blocks[cur_block_n], word)
	end

	return blocks
end

function save_blocks_to_vmg_files(blocks, prefix)

	local output_fname_prefix = prefix

	for block_idx, block in ipairs(blocks) do
		local out = {}
		out.fname = gen_out_fname(output_fname_prefix, block_idx)
		out.block_body = table.concat(block)
		out.block_body_fixed_n = string.gsub(out.block_body, "\r\n", "\n")
		out.block_body_fixed_n = string.gsub(out.block_body_fixed_n, "\n", "\r\n")
		out.block_escaped_body = quote_utf8(out.block_body_fixed_n)
		
		out.vmg_data_t = {}
		for i, v in pairs(wrap_str_t) do
			out.vmg_data_t[i] = v
		end
		out.vmg_data_t[4] = out.vmg_data_t[4] .. out.block_escaped_body
		
		out.vmg_data = table.concat(out.vmg_data_t, "\r\n").."\r\n"

		-- DEBUG
		--print(pretty.write(block))
		--print(pretty.write(out))

		local out_fd = assert(io.open(out.fname, "wb"))
		out_fd:write(out.vmg_data)
		out_fd:close()
	end
end

-- Output
local blocks = read_file_and_split_by_words(input_fname)

-- DEBUG
--[[
for i, v in ipairs(blocks) do
	print("BLOCK #"..tostring(i))
	print("BLOCK_DATA:", table.concat(v))
end
]]
--print(pretty.write(blocks))

save_blocks_to_vmg_files(blocks, output_fname_prefix)

--print(table.concat(wrap_str_t, "\n"))

