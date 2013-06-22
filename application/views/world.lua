-- Expandify Engine class

LoadWorld = {}


function LoadWorld:new(params)

	local screen = display.newGroup()

	------------------------------------------------------------------------------------------
	-- Primary Views
	------------------------------------------------------------------------------------------

	-- initialize()
	-- show()
	-- hide()

	function screen:initialize(params)

		self.state   = 1   -- 0 = idle, 1 = active, 2 = paused
		self.objects = {}
		screen.alpha = 0

		self.visualPoints = {}

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

		local pEnd = #self.objects
		for i=1,pEnd,1 do
			self:moveObject(self.objects[i], .1, .02, centerX, centerY)
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
	function screen:insertObject(object,centerX, centerY, angle)
		print("object = ",object)

		local objectPos         = #self.objects+1
		self.objects[objectPos] = object
		local numObjectPoint    = #object

		-- add point images for visual reference (OPTIONAL)
		for i=1,numObjectPoint,1 do
			self.objects[objectPos][i][4] = display.newImage( screen, "content/images/star.png", 0, 0 )
		 end

		self:renderObject(self.objects[objectPos], centerX, centerY, angle)


	end
	--------
	function screen:renderObject(object, centerX, centerY, angle)
		print("rendering...")

		local pEnd  = #object
		local pList = {}

		--print("Number of points in sprite:",pEnd)
		for i=1, pEnd, 1 do 

			local p = object[i]
			--print(p[1],p[2],p[3],p[4])
			local scalar = 1.0/((p[3] * 1.0) / angle + 1)
			--print(scalar)
  			p[4].x,p[4].y= (p[1] * scalar) + centerX, centerY - (p[2] * scalar)
		 end

	end
	--------
	function screen:moveObject(object, transformX, transformY, centerX, centerY)

	  local pEnd = #object
	  print(pEnd)
	  for i = 1, pEnd, 1 do
	    
	    local p     = object[i]
	    local x,y,z = p[1],p[2],p[3]
	    
	    local tmp = z * math.cos(transformY) - x   * math.sin(transformY)
	    p[1]      = z * math.sin(transformY) + x   * math.cos(transformY)
	    p[3]      = y * math.sin(transformX) + tmp * math.cos(transformX)
	    p[2]      = y * math.cos(transformX) - tmp * math.sin(transformX)
	    
	    p[4].x,p[4].y= p[1]+centerX,p[2]+centerY
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
