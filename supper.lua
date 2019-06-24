local supper =
{
    _VERSION        = 'supper v1.0',
    _DESCRIPTION    = 'A collection of convenient functions to make common table tasks easier.',
    _LICENSE        = [[
Copyright (c) 2017 Ashley Pringle

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
}

--runs the function defined by input args
--t = supper.run(gamename, {"level", "cave", "make"}, ...) will run gamename.level.cave.make(...)
--use this to run different code by varying the input of the string key args
--this means we aren't limited to static functions like gamename.level.cave.make, and so don't need if or switch logic to do something like run game.level.desert.make instead of game.level.cave.make
supper.run = function(t,args,...)--takes in a table t, a list of strings args to identify the function, and function parameters for the function that will be run
	local r=nil--if we find a function in t it will be returned as r, otherwise WE return r as nil so nothing happens
	--TODO should we just check if table here?
	if #args>0 then--if we are dealing with a table, recursively dig through it to see if it contains any tables with keys matching the string args
		local f=t[args[1]]--check if first key in args is in the table
		if f then--if it is
			table.remove(args,1)--remove it froms args
			r=supper.run(f,args,...)--check f with next key in args, get the result (either r is a function or still nil)
		end
	elseif type(t)=="function" then--if we've run out of args and t is a function instead this iteration, then pass it back up the recursion chain
		r=t(...)
	end
	if r then--if all goes well and a function was found in the table with the provided args, r will be the function that is returned and run, otherwise r is still nil, so nothing happens
		return r
	end
end

--TODO THIS IS THE ONE YOU USED IN NANOGENMO AND INFINITE ADVENTURES
--puts a table called "names" in a table t
--the "names" tables is an enumerated list of all the key strings of the members of the table
--ie: t = {desert=function(...),cave=function(...),sewer=function(...)}
--then t.names[1]="desert", t.names[2]="cave", t.names[3]="sewer"
--these names can then be used to dynamically call member functions of the table t
--[[
supper.names = function(t,names)
	names=names or "names"
	local n={}
	for k,v in pairs(t) do
		table.insert(n,k)
	end
	t[names]=n
end
--]]

--this version doesn't make a table called names
supper.names = function(t)
	local names={}
	for k,v in pairs(t) do
		table.insert(names,k)
	end
	supper.copy(t,names)
end


--takes a table t of strings indexed by integer and makes integers with the strings as keys
--ie: t = {"boss", "enemy"} becomes {"boss", "enemy", boss = 1, enemy = 2}
supper.numbers = function(t)
	for i,v in ipairs(t) do
		t[v]=i
	end
end

--gives a random entry in any integer-indexed table
supper.random = function(t)
	return t[math.random(#t)]
end

supper.contains = function(t,value)
	for i,v in ipairs(t) do
		if v==value then
			return true
		end
	end
	return false
end

--copies all values and tables from a source table and adds them to the target table
--a new table is NOT made, so references to the target table are not broken
--also retains any values that were in the target table before copying (unless the source table has a value with the same key, in which case the value in the target table with that key is overwritten)
supper.copy = function(target,source)
	for k,v in pairs(source) do
		if type(v)~="table" then--any value in the source that isn't a table is put in the target
			target[k]=v
		else
			target[k]={}--any table in the source is recreated in the target, then has its values and tables recursively copied
			supper.copy(target[k],v)
		end
	end
end

--prints everything in a table to console by recursively travelling through every subtable
supper.print = function(table,name,space)
	name=name or "parent"--this is printed in the first line, to identify the table
	space=space or " "--space is just included for indentation, so each recursive iteration of print is indented by its recursion depth, for readability
	if space==" " then print(name.." table = "..tostring(table)) end--only print parent table name on first iteration (when there is only one space)
	for k,v in pairs(table) do
		print(space..k.." = "..tostring(v))--print the key and value of the entry in the table
		if type(v)=="table" then
			supper.print(v,name,space.." ")--if it is also a table, print it out as well, indented one more space
		end
	end
end

-- Supper:
-- Don't walk for your supper... RUN!

return supper