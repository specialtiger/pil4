---练习7.1 请编写一个程序，该程序读取一个文本文件然后将每行的内容按照字母表顺序排序后重写该文件。
---如果调用时不带参数，则从标准输入读取并向标准输出写入；
---如果调用时传入一个文件名作为参数，则从该文件中读取并向标准输出写入；
---如果调用时传入两个文件名作为参数，则从第一个文件读取并将结果写入第二个文件中

---练习7.2
local function file_exists(name)
   local f = io.open(name,"r")
   if f then
      io.close(f)
	  return true
   end
   return false
end

local function SortAndWrite(inputFile,outputFile)
   local function writeHelper(str)
      local t = {string.byte(str,1,-1)}
      table.sort(t)
      str = string.char(table.unpack(t))
      io.write(str,"\n")
   end

   local of = nil
   if outputFile then
      if file_exists(outputFile) then
	     local signal = ""
		 local fmt = string.format("File %s is already existed, do you still want to rewrite it?(yes/no)",outputFile)
         while(signal ~= "YES" and signal ~= "NO") do
            print(fmt)
            signal = string.upper(io.read())
         end
         if signal == "YES" then
            of = io.output(outputFile)
         end
	  else
         of = io.output(outputFile)
	  end
   end
   if inputFile then
      for line in io.lines(inputFile) do
         writeHelper(line)
      end
   else
      writeHelper(io.read())
   end
   if not of then
      print()
   end
end

--SortAndWrite("7_1_input.txt","7_1_output.txt")


---练习7.3
--取决于解释器能分配的最大内存，不过最好一次性不要操作几十mb以上的文件（参见 www.lua.org/pil/21.2.1.html）

local function formatCost(copyType,costTime)
   return copyType.. " cost time : " .. costTime .. "s\n"
end

local function test7_3()
   assert(io.input("7_2_input.txt","r"))
   local str = io.read("a")
   local bytes = {string.byte(str)}
   local startTime = nil

   --byte by byte
   startTime = os.time()
   for i = 1,#bytes do
      io.write(bytes[i])
   end
   local cost1 = os.difftime(os.time() , startTime)

   --line by line
   startTime = os.time()
   for lines in io.lines("7_2_input.txt") do
      io.write(lines)
   end
   local cost2 = os.difftime(os.time() , startTime)

   --in chunks of 8kb
   startTime = os.time()
   for block in io.input():lines(2^13) do
      io.write(block)
   end
   local cost3 = os.difftime(os.time() , startTime)

   --whole file
   startTime = os.time()
   io.write(str)
   local cost4 = os.difftime(os.time() , startTime)
   print("\n=========Compare CostTime =========\n")
   print( formatCost("byte by byte", cost1 ))
   print( formatCost("line by line",cost2) )
   print( formatCost("in chunks of 8kb",cost3) )
   print( formatCost("whole file",cost4) )
end
--test7_3()


---练习7.4 
---练习7.5
local function getfileSize(file)
   if not file then
      return 0
   end
   local current = file:seek()
   local size = file:seek("end")
   file:seek("set",current)
   return size
end

local buffSize = 1024
local function printLast_N_Line(n,fileName)
   local file = io.open(fileName,"r")
   if not file then
      print(tostring(fileName).." file does not exist")
      return
   end
   n = n > 0 and n or 1
   local loopTime = 1
   local iFileSize = getfileSize(file)
   while true do
      local iCurSize = iFileSize - file:seek("end",math.max(-loopTime * buffSize,-iFileSize))
      local text = file:read("a")
      local _,occurrence = string.gsub(text, "\n", "\n")
      if occurrence > n - 1 then
         local diff = occurrence - (n - 1)
         while diff > 0 do
            local start = string.find(text,"\n")
            text = string.sub(text,start + 1,-1)
            diff = diff - 1
         end
         print(text)
         break
      elseif iCurSize == iFileSize then
	     print("N is larger than file's line, print all lines")
         print(text)
         break
      end
      loopTime = loopTime + 1
   end
end
--print("======test1======")
--printLast_N_Line(1,"7_2_input.txt")
--print("======test2======")
--printLast_N_Line(20,"7_2_input.txt")
--print("======test3======")
--printLast_N_Line(1,"none-exist.txt")
--print("======test4======")
--printLast_N_Line(3,"7_4_input.txt")
--print("======test5======")
--printLast_N_Line(100,"7_4_input.txt")
--print("======test6======")
--printLast_N_Line(-100,"7_4_input.txt")

---练习7.6
--注: os.execute 执行后返回错误码，而os.popen执行后返回file对象
local function isWindows()
   return package.config:sub(1,1) == "\\"
end

local function createDir(dirname)
   os.execute("mkdir " .. dirname)
end

local function removeDir(dirname,bForce)
   local cmd = nil
   if isWindows() then
      cmd = bForce and "rmdir /s " or "rmdir "
   else
      cmd = bForce and "rm -rf " or "rmdir "
   end
   os.execute(cmd .. dirname)
end

local function collectEntries(dirname)
   local str = nil
   local cmd = isWindows() and "dir "..dirname or "ls "..dirname
   local t = io.popen(cmd,"r")
   if t then
      str = t:read("a")
      print(str)
      t:close()
   end
   return str
end

--collectEntries("test7_6")
--removeDir("test7_6",true)


---练习7.7
local function changeMyDir(tar)
   local path = arg[0]
   if isWindows() then
      os.execute("move  " .. path .. " " .. tar)
   else
      os.execute("mv  " .. path .. " " .. tar)
   end
end
--changeMyDir("../chapter6")