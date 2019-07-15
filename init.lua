-- This program is an aiding device for keying using Hammerspoon.
-- To use it you need to have Hammerspoon installed and be granted Security Accessibility permission.
-- The configuration file path is :[~/.hammerspoon/init.lua]
-- Please access this configuration file and overwrite "init.lua" file from menu icon "Open comfig".
--
-- < Programable Keybinding >
-- 　While pressing OPTION key
--    ･Allow key with IJKL
--    ･PAGEUP(U)・PAGEDOWN(N)
--    ･Select one word(S)  One character back(D)
--    ･Select one line(W)
--
-- < Memory Clipboard >
--  ･option + 0                         	- clipboard history toggle change (Up to 10)
--  ･option + (1-9)number key           	- look stored words and stanby...
--  (no release option) + P key         	- Paste that.
--  ･option + (1-9)number key double tap	- Save the words in the clipboard to each key
--  ･cmd + ctrl + (1-9)number key       	- Paste the words
--  ･cmd + ctrl + 0 key                 	- save user data. Load it when reloading.
--                                        	The file path is :[~/.hammerspoon/UserSaveData.txt]
--
-- It will be amazing MAC.
--
-- This program code was written by a special LUA, so it needed a great deal of try-and-error to develop stable operation.
-- But now you can use this as a technical textbook, or as a code example.
-- If it helped you a lot, please donate to my work someday.

keymap = {
    Escape=53, f1=122, f2=120, f3=99, f4=118, f5=96, f6=97, f7=98, f8=100, f9=101, f10=109, f11=103, f12=111,
    n1=18, n2=19, n3=20, n4=21, n5=23, n6=22, n7=26, n8=28, n9=25, n0=29, minus=27, hut=24, yen=93, Delete=51,Del=117,
    Tab=48, q=12, w=13, e=14, r=15, t=17, y=16, u=32, i=34, o=31, p=35, atmark=33, kakko=30, Return=36,padEnter=76,
    Control=59, a=0, s=1, d=2, f=3, g=5, h=4, j=38, k=40, l=37, semicolon=41, colon=39, kakkotoji=42,
    Shift_L=56, z=6, x=7, c=8, v=9, b=11, n=45, m=46, comma=43, dot=47, slash=44, underber=94, Shift_R=60,
    CapsLock=57, Option=58, Command_L=55, Eisuu=102, space=49, Kana=104, Command_R=54, Fn=63,
    left=123, up=126, down=125, right=124, pageUp=116, pageDown=121, Home=115, Ends=119
    } -- keymap["left"] = 123

memoryNo={"1","2","3","4","5","6","7","8","9"}  ---clip key No.

collectgarbage(stop)
hs.timer.doAfter(0.2, function()
  hs.focus()
  hs.eventtap.keyStroke({"cmd"}, "h", 500)
end)

local storedhistory={}
local oncecopy={}
local countback =1
local No=""
local flags={}
local fl={}
local NewKeyEvent=hs.eventtap.event.newKeyEvent
local last_change = hs.pasteboard.changeCount()

hs.alert.defaultStyle.radius = 10
hs.alert.defaultStyle.strokeWidth = 0
hs.alert.defaultStyle.atScreenEdge = 0
hs.alert.defaultStyle.textSize = 20

local function save()
    for i=1,9 do
    	storedclip=hs.pasteboard.readAllData(memoryNo[i])["public.utf8-plain-text"]
        if  storedclip == nil then storedclip ="" end
        saveData[i] = storedclip
        hs.timer.usleep(200)
    end
    local fs = io.open("UserSaveData.txt", "w")
    for i, value in pairs(saveData) do
         print(i,":",value)
         fs:write(value.."\n")
    end
    fs:close()
    print("saved UserSaveData.txt")
end

local function read()
    saveData ={}
   fs = io.open("UserSaveData.txt", "r")
    for line in fs:lines() do
        table.insert(saveData, line)
    end
    fs:close()

    for i=1,9 do
    	Copy= saveData[i]
        hs.pasteboard.writeObjects(Copy, memoryNo[i])
        hs.timer.usleep(200)
    end

    for key, value in pairs(saveData) do
    print(key,":",value)
    end
    print("loded UserSaveData.txt")
end

-- local function read() -- hs.plist.read somehow nil. bug?
-- open=hs.fs.pathToAbsolute("~/.hammerspoon/"UserSavedTable.plist")
-- keySet = hs.plist.read(open)
-- end

local function Press_to(mods, key) --- keyinput function
    mods = mods or {}
    NewKeyEvent(mods, string.lower(key), true):post()
    hs.timer.usleep(100)
    NewKeyEvent(mods, string.lower(key), false):post()
end

local function stringcount(str)  --- stringcount("1212") = return 4
    local asc = 0
    for i=1, string.len(str) do
        if string.byte(str,i,i) < 128 then
        asc = asc + 1
        end
    end
        return math.ceil((string.len(str) - asc) / 3) + asc
end

--- --- --- Memory Clipboard --- --- ---
read()  --  Load user data file when reloading.

local function clipCopy(Np)
        Copy = hs.pasteboard.getContents()
        if Copy == nil then return false
        else
          hs.pasteboard.writeObjects(Copy, Np)
          hs.timer.usleep(200) ;return true
        end
end

local function clipPaste(No)
        paste = hs.pasteboard.readAllData(No)["public.utf8-plain-text"]
        if paste == nil then paste=""
        end
        hs.pasteboard.setContents(paste);
        hs.timer.usleep(200)
        NewKeyEvent('cmd', 'v', true):post();
        hs.timer.usleep(100)
        NewKeyEvent('cmd', 'v', false):post();return true
end

local function cliplook(Nl)
    if oncecopy[Nl] and Nl~="0" then clipCopy(Nl)
        if string.byte(Copy,1,1) >= 128 then
          str=tostring(stringcount(Copy)).." Characters"
        else str=tostring(stringcount(Copy)).." letters"
        end
        hs.alert.closeAll(0);hs.alert.show(str.." Saved. Paste:⌥+P",2); return true
    else
        oncecopy[Nl] = true
        hs.timer.doAfter(0.8, function() oncecopy[Nl] = false end)
        looking = hs.pasteboard.readAllData(Nl)["public.utf8-plain-text"]
        if looking ~= nil then
        hs.alert.show("⌥"..Nl.."P : "..string.sub(looking, 1, 255),2)
        end
    end
end

local function cliprevive()
        hs.pasteboard.setContents(hs.pasteboard.readString("@"));return true
end
--- --- --- --- clipboard history --- --- --- ---
local function cliphistory()
        ;if #storedhistory>10 then table.remove(storedhistory,1); end
        onboard=hs.pasteboard.getContents()
        if storedhistory[#storedhistory] ~= onboard then
          table.insert(storedhistory,onboard)
          hs.timer.usleep(200)
        end
end

local function togglehistory(Un)
        if Un==nil or Un > #storedhistory then
          hs.pasteboard.deletePasteboard("0")
        else
        hs.pasteboard.writeObjects(storedhistory[#storedhistory+1-Un],"0")
        hs.timer.usleep(100);
        end
end

local function historycheck()
        pb = hs.pasteboard.changeCount()
        if (pb > last_change) then cliphistory()
        last_change = pb
        end
end

-------------clipboard No. keybinding
for n,value in ipairs(memoryNo) do
    hs.hotkey.bind({'cmd','ctrl'}, memoryNo[n],
    function() clipPaste(memoryNo[n]) end)
end
    hs.hotkey.bind({'cmd','ctrl'}, "0", function() save() end)

 ------------------------------------------------------------- key handler --------
keytap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)

Press_key = event:getKeyCode()
flags = event:getFlags()
keyType = event:getType()
Iskeydown = event:getType() == 10
Iskeyup   = event:getType() == 11
Iskeyflag = event:getType() == 12

if Iskeydown then
  if flags.alt then alton = true
 ------------------------------------------------------------- keybind --------
    if Press_key == keymap["w"] then Press_to({'alt', 'shift'}, 'down'); Press_to({'cmd', 'shift'}, 'left'); return true
    elseif Press_key == keymap["j"] then Press_to(Onflags, 'left'); return true
    elseif Press_key == keymap["k"] then Press_to(Onflags, 'down'); return true
    elseif Press_key == keymap["i"] then Press_to(Onflags, 'up'); return true
    elseif Press_key == keymap["l"] then Press_to(Onflags, 'right'); return true

    elseif Press_key == keymap["u"] then Press_to(Onflags, 'pageup'); return true
    elseif Press_key == keymap["n"] then Press_to(Onflags, 'pagedown'); return true
    elseif Press_key == keymap["d"] then Press_to({'shift'}, 'right'); return true
    elseif Press_key == keymap["s"] then Press_to({'alt','shift'}, 'left'); return true
    end
 ------------------------------------------------------------- clipboad keybind --
    if Press_key == keymap["p"] then clipPaste(getNo); return true
    elseif Press_key == keymap["n1"] then getNo = "1"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n2"] then getNo = "2"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n3"] then getNo = "3"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n4"] then getNo = "4"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n5"] then getNo = "5"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n6"] then getNo = "6"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n7"] then getNo = "7"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n8"] then getNo = "8"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n9"] then getNo = "9"; clipCopy("@"); cliplook(getNo); return true
    elseif Press_key == keymap["n0"] then getNo = "0"; clipCopy("@")
      togglehistory(countback)
      countback = countback + 1
      hs.timer.usleep(200)
      cliplook(getNo);return true
    end
  end
 ------------------------------------------------------------- flags change--------
 elseif Iskeyflag then flags = event:getFlags()
    if flags.cmd then Onflags="alt"
      historycheck()
      if flags.shift then Onflags={"shift","alt"} end
    elseif flags.ctrl then Onflags="ctrl"
    elseif flags.shift then Onflags="shift"
    elseif flags.alt or flags==nil then Onflags=nil
    elseif alton and flags.alt~= true and not(flags.ctrl or flags.shift or flags.ctrl) then
        alton = false
        if getNo ~= nil then
           cliprevive() ; countback = 1 ; getNo = nil
        end
    else flags = event:getFlags() Onflags=nil
    end
 end
end)

keytap:start()