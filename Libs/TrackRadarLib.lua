---@section LIGHTMATRIXBOILERPLATE
-- Author: TAK4129
-- GitHub: https://github.com/yukimaru73
-- Workshop: https://steamcommunity.com/profiles/76561198174258594/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
---@endsection

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
		output.setNumber(self.radar_h_ch,math.atan(x,z))
		output.setNumber(self.radar_v_ch,math.atan(y-0.5,math.sqrt(z^2*x^2)))
	end
	function obj:setFOV(FOV)
		output.setNumber(fov_ch,FOV)
	end
	--[[
	function obj:setViewFromAngle(azim, elev)
		output.setNumber(self.radar_h_ch,azim)
		output.setNumber(self.radar_v_ch,elev)
	end
	]]
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
