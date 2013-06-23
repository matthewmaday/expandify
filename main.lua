-- Expandify Engine
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

-- This is the main scene

display.setStatusBar( display.HiddenStatusBar )

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
-- variable declaritions
--------------------------------------------------------------------------------------

local screen       = display.newGroup()
local gComponents  = {}

--------------------------------------------------------------------------------------
-- functions
--------------------------------------------------------------------------------------

function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
--------
local function insertModelIntoWorld(object)

		gComponents.world:insertObject(table.deepcopy(object),display.contentCenterX,display.contentCenterY, .5, 900000, "square",{.02, .02,.02})
		gComponents.world:insertObject(table.deepcopy(object),10,10,1, 900000, "square2",{.05, .00,0})
		gComponents.world:insertObject(table.deepcopy(object),200,400,.4, 900000, "square3",{.01, .01,.02})

end
--------------------------------------------------------------------------------------
-- INIT scene components
--------------------------------------------------------------------------------------

-- loadStarfield()

local function loadExpandify()

	require "application.views.world"

	local result = nil
	gComponents[#gComponents+1] = {world=nil}
	gComponents.world  = LoadWorld:new({
		
	})

	-- initialize the textures and models
	gComponents.world.modelLib = gComponents.world:loadModelLib("content/objects/modelLib.txt")
	print("model loaded successfully ",gComponents.world.modelLib )
	result = gComponents.world:loadTextures("toppanel.png", 80, 77, 8,320, 154)
	print("textures loaded successfully ",result)

	print("total number of models = ",#gComponents.world.modelLib)
	local pEnd = #gComponents.world.modelLib
	for i=1,pEnd,1 do
		insertModelIntoWorld(gComponents.world.modelLib[i])
	end
	-- display on the screen
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

return screen



