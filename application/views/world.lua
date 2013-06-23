-- Expandify Engine class

LoadWorld = {}

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------
local fileio     = require ("library.core.fileio")
local json       = require ("json")
local modelLib   = {}

function LoadWorld:new(params)

	local screen   = display.newGroup()
	local textures = {}
	

	------------------------------------------------------------------------------------------
	-- Primary Views
	------------------------------------------------------------------------------------------

	-- initialize()
	-- show()
	-- hide()

	function screen:initialize(params)

		self.state        = 1   -- 0 = idle, 1 = active, 2 = paused
		self.objects      = {}
		self.visualPoints = {}
		self.models       = {}
		screen.alpha      = 0
	
	end
	--------
	function screen:loadTextures(file, width, height, numFrames,sheetContentWidth, sheetContentHeight)

		local options = {
			width=width,                              -- width of one frame
			height=height,                            -- height of one frame
			numFrames=numFrames,                      -- total number of frames in spritesheet
		    sheetContentWidth = sheetContentWidth,    -- width of original 1x size of entire sheet
    		sheetContentHeight = sheetContentHeight   -- height of original 1x size of entire sheet
		}

		textures[#textures+1] = graphics.newImageSheet("content/images/"..file, options)

		if textures[#textures] == nil then
			print("error loading texture map"..file)
			return -1
		else 
			print(file.." texture map has been successfully loaded")
			return 0
		end
	end
	--------
	function screen:loadModelLib(file)

		local pPath = system.pathForFile( "content/objects/modelLib.txt", system.pathForFile )
		local pFile = fileio:new(pPath) 		
		result      = io.open( pPath, "r" )
		str         = result:read( "*a" )

		io.close( result )

		if result == nil then
			print("failed to load the model library "..file)
			return -1
		else
			print(file.." model library has been successfully loaded")
			return json.decode( str)
		end

	end
	--------
	function screen:show(time)
		transition.to(self, {time = time, alpha = 1, onComplete = function()
			screen.state = 0
		end
		})
	end
	--------
	function screen:hide(time)

		transition.to(self, {time = time, alpha = 0, onComplete = function()
			screen.state = 0
		end
		})
	end	
	--------
	function screen:process(centerX, centerY, angle)


		local pEnd = #self.models
		-- print("objects to spin",pEnd)
		for i=1,pEnd,1 do
		self:moveObject(self.models[i])
		 end
   end
	--------
	function screen:pause()

		if self.state == 0 then
			self.state = 2
		elseif self.state == 2 then
			self.state = 0
		end 

	end	
	--------
	function screen:destory()

	end	
	--------
	function screen:insertObject(object, centerX, centerY, centerZ, angle, name, spin)

		--print("object = ",object, centerX, centerY, angle, name, spin)

		local pos = #self.models+1
		local verticiesNum = #object

		self.models[pos] = {
			name  = name,
			model = table.copy(object),
			spin  = spin,
			x     = centerX,
			y     = centerY,
			z     = centerZ,
			angle = angle
		}

print("object = ",self.models[pos].model, self.models[pos].x, self.models[pos].y, self.models[pos].angle, self.models[pos].name, self.models[pos].spin)


		-- add point images for visual reference (OPTIONAL)
		for i=1,verticiesNum,1 do
			self.models[pos].model[i][4] = display.newImage( screen, "content/images/star.png", 0, 0 )
		 end

		 print("rendering :",pos)
		self:renderObject(self.models[pos])


	end
	--------
	function screen:renderObject(object)
		print("rendering...")

		local pEnd  = #object.model
		local pList = {}

		for i=1, pEnd, 1 do 

			local p = object.model[i]
			--print(p[1],p[2],p[3],p[4])
			local scalar = 1.0/((p[3] * 1.0) / object.angle + 1)
			--print(scalar)
  			p[4].x,p[4].y= (p[1] * scalar) + object.x, object.y - (p[2] * scalar)
		 end

	end
	--------
	function screen:moveObject(object)

	  local pEnd = #object.model

	  for i = 1, pEnd, 1 do
	    
	    local p     = object.model[i]
	    local x,y,z = p[1],p[2],p[3]
	    
	    local tmp = z * math.cos(object.spin[2]) - x   * math.sin(object.spin[2])
	    p[1]      = z * math.sin(object.spin[2]) + x   * math.cos(object.spin[2])
	    p[3]      = y * math.sin(object.spin[1]) + tmp * math.cos(object.spin[1])
	    p[2]      = y * math.cos(object.spin[1]) - tmp * math.sin(object.spin[1])
	    
	    p[4].x,p[4].y= p[1]+object.x,p[2]+object.y
	  end
	  
	end	

	screen:initialize(params)
	return screen

end

return LoadWorld


-- on drawGroups startSN, pQuadList
  
--   pEnd  = gPoints.count
--   zlocs = []
--   xlocs = []
--   ylocs = []
  
--   -- get points
--   repeat with i = 1 to pEnd
--     append zlocs, gPoints[i].zpos
--   end repeat
  
--   -- add values for each side
--   side1 = zlocs[1] + zlocs[2] + zlocs[3] + zlocs[4]
--   side2 = zlocs[5] + zlocs[6] + zlocs[8] + zlocs[7]
--   side3 = zlocs[6] + zlocs[2] + zlocs[4] + zlocs[8]
--   side4 = zlocs[1] + zlocs[5] + zlocs[7] + zlocs[3]
--   side5 = zlocs[1] + zlocs[2] + zlocs[6] + zlocs[5]
--   side6 = zlocs[3] + zlocs[4] + zlocs[8] + zlocs[7]

  
--   -- z sort
--   pList    = sortNumbers([side1, side2, side3, side4, side5, side6])
  

--   repeat with i = 1 to 6
--     sprite(startSN + pList[i] - 1).locz = i
--   end repeat
  
--   sprite(startSN).quad   = [point(pQuadList[1][1],pQuadList[1][2]),point(pQuadList[2][1],pQuadList[2][2]),point(pQuadList[4][1],pQuadList[4][2]),point(pQuadList[3][1],pQuadList[3][2])]      -- 1
--   sprite(startSN+1).quad = [point(pQuadList[5][1],pQuadList[5][2]),point(pQuadList[6][1],pQuadList[6][2]),point(pQuadList[8][1],pQuadList[8][2]),point(pQuadList[7][1],pQuadList[7][2])]      -- 2
--   sprite(startSN+2).quad = [point(pQuadList[2][1],pQuadList[2][2]),point(pQuadList[6][1],pQuadList[6][2]),point(pQuadList[8][1],pQuadList[8][2]),point(pQuadList[4][1],pQuadList[4][2])]      -- 3
--   sprite(startSN+3).quad = [point(pQuadList[1][1],pQuadList[1][2]),point(pQuadList[5][1],pQuadList[5][2]),point(pQuadList[7][1],pQuadList[7][2]),point(pQuadList[3][1],pQuadList[3][2])]      -- 4
--   sprite(startSN+4).quad = [point(pQuadList[1][1],pQuadList[1][2]),point(pQuadList[2][1],pQuadList[2][2]),point(pQuadList[6][1],pQuadList[6][2]),point(pQuadList[5][1],pQuadList[5][2])]      -- 5
--   sprite(startSN+5).quad = [point(pQuadList[4][1],pQuadList[4][2]),point(pQuadList[8][1],pQuadList[8][2]),point(pQuadList[7][1],pQuadList[7][2]),point(pQuadList[3][1],pQuadList[3][2])]      -- 6
  
-- end
