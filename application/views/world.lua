-- Expandify Engine class

LoadWorld = {}

-- definitions for help
--    vertices : points of a geometric shape
--    facets   : flat faces on geometric shapes
--    model    : a collection of facets to create a single 3d object

-- modelLib => 
-- models => facets => vertices

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------
local fileio     	= require ("library.core.fileio")
local json       	= require ("json")
local modelLib   	= {}
local tmpImgBuffer  = {}

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

		-- clean up images used to draw the lines
		local pEnd = #tmpImgBuffer
		for i = 1, pEnd, 1 do
			tmpImgBuffer[i]:removeSelf()
			tmpImgBuffer[i] = nil
		end

		-- refresh the position of the models within the world
		pEnd = #self.models
		for model=1,pEnd,1 do
			self:moveObject(self.models[model])
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
			--print("error loading texture map"..file)
			return -1
		else 
			--print(file.." texture map has been successfully loaded")
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
			--print("failed to load the model library "..file)
			return -1
		else
			--print(file.." model library has been successfully loaded")
			return json.decode( str)
		end

	end

	--------
	function screen:insertObject(object, centerX, centerY, centerZ, angle, name, spin)

		local pFacetCnt = #object                -- determine the number of facets for the model
		local pNewModel = {
			name   = name,
			facets = {},
			x      = centerX,
			y      = centerY,
			z      = centerZ,
			angle  = angle,
			spin   = spin}                        -- initializing a new local variable to use while constructing the model


		print("total number of facets for this object",pFacetCnt)
		for facet=1,pFacetCnt,1 do

			local pVerticesCnt = #object[facet]
			local pVertices = object[facet]

			print("Total number of vertices of facet"..facet, pVerticesCnt, facet)

				-- add point images for visual reference (OPTIONAL)
				for i=1,pVerticesCnt,1 do
					pVertices[i][4] = display.newImage( screen, "content/images/star.png", 0, 0 )
				end

				pNewModel.facets[#pNewModel.facets+1] = pVertices
 		end

 		print("new model contains ",#pNewModel.facets, #pNewModel.facets[1], pNewModel.facets[1][1])

 		self.models[#self.models+1] = pNewModel

 		self:renderObject(self.models[#self.models])

	end
	--------
	function screen:renderObject(object)

		local pFacetCnt = #object.facets

		for facet=1,pFacetCnt,1 do

			local pEnd = #object.facets[facet]

			-- update point calculations
			for i=1, pEnd, 1 do 
				
				local p = object.facets[facet][i]
				local scalar = object.z/((p[3] * object.z) / object.angle + 1)
				p[4].x,p[4].y= (p[1] * scalar) + object.x, object.y - (p[2] * scalar)
			end

			 -- render lines
			for i=1, pEnd, 1 do 
			 	local p = object.facets[facet][i]
			 	  if i>1 then
	  				tmpImgBuffer[#tmpImgBuffer+1] = display.newLine( screen, object.facets[facet][i-1][4].x,object.facets[facet][i-1][4].y, p[4].x,p[4].y )
	  			else
	  				tmpImgBuffer[#tmpImgBuffer+1] = display.newLine( screen, object.facets[facet][pEnd][4].x,object.facets[facet][pEnd][4].y, p[4].x,p[4].y )
	  			 end
	  		end
		end

	-- draw lines (will later be controlled by view options {dot,lines,textures})
	end
	--------
	function screen:moveObject(object)

		local pFacetCnt = #object.facets
		
		for facet=1,pFacetCnt,1 do

			local pEnd = #object.facets[facet]

	 		for i = 1, pEnd, 1 do
	    
			    local p = object.facets[facet][i]
		 		local x,y,z = p[1],p[2],p[3]
			    local ry  = y  * math.cos(object.spin[1]) - z  * math.sin(object.spin[1])
				local rz  = z  * math.cos(object.spin[1]) + y  * math.sin(object.spin[1])
				local rz2 = rz * math.cos(object.spin[2]) - x  * math.sin(object.spin[2])
		 		local rx  = x  * math.cos(object.spin[2]) + rz * math.sin(object.spin[2])
		 		local rx2 = rx * math.cos(object.spin[3]) - ry * math.sin(object.spin[3])
		 		local ry2 = ry * math.cos(object.spin[3]) + rx * math.sin(object.spin[3])

			    p[1], p[2], p[3]  = rx2, ry2, rz2

				screen:renderObject(object)
			end
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
