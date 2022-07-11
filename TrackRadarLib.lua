TrackRadar = {}
TrackRadar.new = function(radar_h_ch, radar_v_ch, fov_ch)
	--[[
		1: signal strength
		2: elevation angle
		3: target distance
	]]
	local obj = {
		radar_h_ch = radar_h_ch,
		radar_v_ch = radar_v_ch,
		fov_ch = fov_ch,
		targetCurrent = {},
		targetLog = {},
		FOV = 0.01,
		facingYaw_H = 0,
		facingYaw_V = 0
	}
	function obj:isTracking()
		return input.getNumber(self.radar_h_ch) ~= 0 or input.getNumber(self.radar_v_ch)
	end
	function obj:update()
		local a = self

		
		output.setNumber(a.radar_h_ch,a.facingYaw_H)
		output.setNumber(a.radar_v_ch,a.facingYaw_V)
		output.setNumber(a.fov_ch, a.FOV)
	end

	function obj:setViewFromPos(x,y,z)
		self:setViewFromAngle(math.atan(x,z),math.atan(y-0.5,math.sqrt(z^2*x^2)))
	end
	function obj:setViewFromAngle(azim, elev)
		self.facingYaw_H = azim
		self.facingYaw_V = elev
	end
	function obj:getPOS()
		if not self:isTracking() then return 0,0,0 end
		local x,y,z,xz
		y,xz=input.getNumber(radar_h_ch+2)*math.sin(input.getNumber(radar_h_ch+1)*2*math.pi), input.getNumber(radar_h_ch+2)*math.cos(input.getNumber(radar_h_ch+1)*2*math.pi)
		x=xz*math.cos(input.getNumber(radar_v_ch+1)*2*math.pi)
		z=xz*math.sin(input.getNumber(radar_v_ch+1)*2*math.pi)
		return x,y,z
	end
	return obj
end
