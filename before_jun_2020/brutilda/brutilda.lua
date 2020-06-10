#!/usr/bin/env lua

-- path to 7z exe file
local P7ZEXE = "7z"

-- archive to bruteforce
local ARCHIVE_NAME = "3.7z"

-- particular file inside archive to extract (can speed up bruteforcing)
--local AFILE = "images/1.jpg"
local AFILE = nil

local dict = {
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z",
}
local dict_rev = {}
for i, v in ipairs(dict) do
  dict_rev[v] = i
end

function try_passwd (fname, passwd)
  local starttime = os.time()
  --io.write(string.format("\"%s\": trying \"%s\" ... ", fname, passwd))
  io.write(string.format("%s ", passwd))
  io.flush()
  local st = os.execute(string.format("%s t -p\"%s\" %s >1.log 2>2.log",
      P7ZEXE, passwd, fname))
  local endtime = os.time()
  local dt = endtime - starttime
  if st == 0 then
    print(string.format("OK (%d s)", dt))
    return true
  elseif st ~= 2 and st ~= 512 then
    print(string.format("Error %d (%d s)", st, dt))
    os.exit(2)
  else
    print(string.format("Failed (%d s)", dt))
    return false
  end
end

function try_passwd_file (fname, passwd, infname)
  local starttime = os.time()
  --io.write(string.format("\"%s\": trying \"%s\" ... ", fname, passwd))
  io.write(string.format("%s ", passwd))
  io.flush()
  local st = os.execute(string.format("%s t -p\"%s\" %s \"%s\">1.log 2>2.log",
      P7ZEXE, passwd, fname, infname))
  local endtime = os.time()
  local dt = endtime - starttime
  if st == 0 then
    print(string.format("OK (%d s)", dt))
    return true
  elseif st ~= 2 and st ~= 512 then
    print(string.format("Error %d (%d s)", st, dt))
    os.exit(2)
  else
    print(string.format("Failed (%d s)", dt))
    return false
  end
end

function inc_passwd (passwd_t, pos)
  pos = pos or 1
  if not passwd_t[pos] then
    passwd_t[pos] = dict[1]
    return
  end
  local word = passwd_t[pos]
  local word_idx = dict_rev[word]
  if word_idx == #dict then
    passwd_t[pos] = dict[1]
    inc_passwd(passwd_t, pos + 1)
  else
    passwd_t[pos] = dict[word_idx + 1]
  end
end

local function filewrite(fname, data)
  local fd = assert(io.open(fname, "wb"))
  assert(fd:write(data))
  assert(fd:close())
end

local function fileread(fname)
  local fd = assert(io.open(fname, "rb"))
  local data = assert(fd:read("*a"))
  assert(fd:close())
  return data
end

function store_passwd (passwd_t, fname)
  local word_indices = {}
  for i, word in ipairs(passwd_t) do
    local word_idx = dict_rev[word]
    table.insert(word_indices, word_idx)
  end
  local data_str = table.concat(word_indices, " ")
  filewrite("_brutilda_tmp", data_str)
  os.rename("_brutilda_tmp", fname)
end

function load_passwd (fname)
  local ok, data = pcall(fileread, fname)
  if not ok then
    return {}
  end
  local passwd_t = {}
  for data_word in string.gmatch(data, "%d+") do
    local word_idx = assert(tonumber(data_word))
    local word = dict[word_idx]
    table.insert(passwd_t, word)
  end
  return passwd_t
end

---------------------------------------


local passwd_t = load_passwd("passwd.last")
local lastsavetime = os.time()
local archive_fname = ARCHIVE_NAME
local archive_file = AFILE

local function main ()
  for i = 1, 1000000000000 do
    inc_passwd(passwd_t)
    local passwd_str = table.concat(passwd_t, "")
    local isfound
    if archive_file then
      isfound = try_passwd_file(archive_fname, passwd_str, archive_file)
    else
      isfound = try_passwd(archive_fname, passwd_str)
    end
    if isfound then
      print("PASSWORD: "..passwd_str)
      print("press enter to continue...")
      io.read()
      os.exit(0)
    end
    local curtime = os.time()
    if curtime - lastsavetime > 10 then
      io.write("saving progress... ")
      io.flush()
      store_passwd(passwd_t, "passwd.last")
      print("saved")
      lastsavetime = curtime
    end
  end
end

main()

