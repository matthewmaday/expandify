-- Expandify Engine
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

-- This is the main scene

display.setStatusBar( display.HiddenStatusBar )

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------
local fileio     = require ("library.core.fileio")
local json       = require "json"

--------------------------------------------------------------------------------------
-- variable declaritions
--------------------------------------------------------------------------------------

local screen       = display.newGroup()
local myObj = {}
local gComponents  = {}

--------------------------------------------------------------------------------------
-- functions
--------------------------------------------------------------------------------------
local function readDataFile(pObject)
	
	local str = pObject:readFile()

	if str == "" then
		print("failed object db load")
		return -1
	else
		return json.decode(str)
	end

end
--------
local function insertObject(num)

	if objectLibray ~= -1 then
		print("Loading object...")
		--gComponents.world:insertObject(myObj[num],display.contentCenterX,display.contentCenterY,900000)

	end

end
--------------------------------------------------------------------------------------
-- INIT scene components
--------------------------------------------------------------------------------------

-- loadStarfield()

local function loadExpandify()

	require "application.views.world"

	local pFile = fileio.new(system.pathForFile( "content/objects/objects.txt", system.pathForFile()))
	local obj   = readDataFile(pFile)
	
	myObj = obj
print("Count of obj",#myObj)
	gComponents[#gComponents+1] = {world=nil}
	gComponents.world  = LoadWorld:new({
		
	})

	gComponents.world:show(300)
	Runtime:addEventListener("enterFrame", function()
	gComponents.world:process(display.contentCenterX,display.contentCenterY)	
	end
	)
end

--------------------------------------------------------------------------------------
-- scene execution
--------------------------------------------------------------------------------------

loadExpandify()
gComponents.world:show()
insertObject(1)

return screen



