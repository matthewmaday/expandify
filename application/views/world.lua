-- Expandify Engine class

LoadWorld = {}

-- definitions for help documentation
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
	local view     = params.view    -- point, line, texture
	
	print("current view is ",view)
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
			self:moveObject(self.models[model],0,0,0)
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
			name        = name,
			facets      = {},
			facetCount  = {},          -- pre-calculating number of facets
			x           = centerX,
			y           = centerY,
			z           = centerZ,
			angle       = angle,
			spin        = spin,
			count       = pFacetCnt}   -- pre-calculating count saved on speed drastically                     


		print("total number of facets for this object",pFacetCnt)
		for facet=1,pFacetCnt,1 do

			local pVerticesCnt = #object[facet]
			local pVertices = object[facet]

			print("Total number of vertices of facet"..facet, pVerticesCnt, facet)

				-- add point images for visual reference (OPTIONAL)
				for i=1,pVerticesCnt,1 do
					pVertices[i][4] = display.newCircle( 0, 0, 1 )
				end

				pNewModel.facets[#pNewModel.facets+1] = pVertices
				pNewModel.facetCount[#pNewModel.facets]  = pVerticesCnt

 		end

 		print("new model contains ",#pNewModel.facets, #pNewModel.facets[1], pNewModel.facets[1][1])

 		self.models[#self.models+1] = pNewModel
 		self:renderObject(self.models[#self.models])

	end
	--------
	function screen:renderObject(object, x,y,z)

		--print(x,y,z)
		local pFacetCnt = object.count

		for facet=1,pFacetCnt,1 do
			local pEnd = object.facetCount[facet]
			-- update point calculations
			for i=1, pEnd, 1 do 
				
				local p = object.facets[facet][i]
				local scalar = object.z/((p[3] * object.z) / object.angle + 1)

				-- speed test option 1 (way too slow)
				--transition.to( p[4], { time=0, alpha=1, x=(p[1] * scalar) + object.x, y=object.y - (p[2] * scalar)} )

				-- speed test option 2 (faster)
				--p[4].x,p[4].y  = (p[1] * scalar) + object.x, object.y - (p[2] * scalar)

				-- local xPos = ((p[1] * scalar) + object.x)
				-- local yPos = (object.y - (p[2] * scalar))
				-- print(xPos,yPos)
				 p[4]:translate(xPos,yPos)

			end

			 -- render lines
			 -- for i=1, pEnd, 1 do 
				--  	local p = object.facets[facet][i]
				--  	  if i>1 then
		  -- 				tmpImgBuffer[#tmpImgBuffer+1] = display.newLine( screen, object.facets[facet][i-1][4].x,object.facets[facet][i-1][4].y, p[4].x,p[4].y )
		  -- 			else
		  -- 				tmpImgBuffer[#tmpImgBuffer+1] = display.newLine( screen, object.facets[facet][pEnd][4].x,object.facets[facet][pEnd][4].y, p[4].x,p[4].y )
		  -- 			 end
		  -- 		end
	  		
		end

	-- draw lines (will later be controlled by view options {dot,lines,textures})
	end
	--------
	function screen:moveObject(object, xChange, yChange, zChange)

		local pFacetCnt = object.count
		local spinx, spiny, spinz = object.spin[1],object.spin[2],object.spin[3] -- maiking them into locals increased speed slightly
		
		for facet=1,pFacetCnt,1 do

			local pEnd = object.facetCount[facet]

	 		for i = 1, pEnd, 1 do
	    
			    local p = object.facets[facet][i]
		 		local x,y,z = p[1]+xChange,p[2]+yChange,p[3]+zChange

			    local ry  = y  * math.cos(spinx) - z  * math.sin(spinx)
				local rz  = z  * math.cos(spinx) + y  * math.sin(spinx)
				local rz2 = rz * math.cos(spiny) - x  * math.sin(spiny)
		 		local rx  = x  * math.cos(spiny) + rz * math.sin(spiny)
		 		local rx2 = rx * math.cos(spinz) - ry * math.sin(spinz)
		 		local ry2 = ry * math.cos(spinz) + rx * math.sin(spinz)

			    p[1], p[2], p[3]  = rx2, ry2, rz2

				screen:renderObject(object, x,y,z)
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
