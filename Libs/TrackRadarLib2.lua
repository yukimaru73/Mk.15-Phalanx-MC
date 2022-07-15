-- Author: TAK4129
-- GitHub: https://github.com/yukimaru73
-- Workshop: https://steamcommunity.com/profiles/76561198174258594/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require("LifeBoatAPI.Utils.LBCopy")

---@section TrackingRadar 1 TrackingRadar
---@class TrackingRadar
---@field ch_in_h number
---@field ch_in_v number
---@field ch_out_h number
---@field ch_out_v number
---@field ch_out_fov number
TrackingRadar = {

	---@param cls TrackingRadar
	---@param ch_in_h number
	---@param ch_in_v number
	---@param ch_out_h number
	---@param ch_out_v number
	---@param ch_out_fov number
	---@return TrackingRadar
	new = function(cls, ch_in_h, ch_in_v, ch_out_h, ch_out_v, ch_out_fov)
		return LifeBoatAPI.lb_copy(cls,
			{ ch_in_h = ch_in_h,
				ch_in_v = ch_in_v,
				ch_out_h = ch_out_h,
				ch_out_v = ch_out_v,
				ch_out_fov = ch_out_fov })
	end;

	---@section isTracking
	---@param self TrackingRadar
	---@return boolean horizontal, boolean vertical, boolean same, number mass
	isTracking = function(self)
		local mass_h =input.getNumber(self.ch_in_h)*input.getNumber(self.ch_in_h+2)
		local mass_v =input.getNumber(self.ch_in_v)*input.getNumber(self.ch_in_v+2)

		return input.getNumber(self.ch_in_h) ~= 0, input.getNumber(self.ch_in_v) ~= 0, (mass_v-mass_h)<0.25 , mass_h
	end;
	---@endsection

	---@section setViewFromPos
	---@param self TrackingRadar
	---@param x number
	---@param y number
	---@param z number
	setViewFromPos = function(self, x, y, z)
		output.setNumber(self.ch_out_h, math.atan(z, x)/2/math.pi)
		output.setNumber(self.ch_out_v, math.atan(y - 0.5, math.sqrt(x ^ 2 + z ^ 2))/2/math.pi)
	end;
	---@endsection

	---@section setViewFromAngle
	---@param self TrackingRadar
	---@param elevation number
	---@param azimuth number
	setViewFromAngle = function(self, azimuth, elevation)
		output.setNumber(self.ch_out_h, azimuth)
		output.setNumber(self.ch_out_v, elevation)
	end;
	---@endsection

	---@section getPos
	---@param self TrackingRadar
	---@return table
	getPos = function(self)
		local x, y, z, xz, a, ith, itv
		a = self
		ith, itv = a:isTracking()
		if not (ith and itv) then return { 0, 0, 0 } end
		y = input.getNumber(a.ch_in_h + 2) * math.sin(input.getNumber(a.ch_in_h + 1) * 2 * math.pi)
		xz = input.getNumber(a.ch_in_h + 2) * math.cos(input.getNumber(a.ch_in_h + 1) * 2 * math.pi)
		x = xz * math.cos(input.getNumber(a.ch_in_v + 1) * 2 * math.pi)
		z = xz * math.sin(input.getNumber(a.ch_in_v + 1) * 2 * math.pi)
		return { x, y, z }
	end;
	---@endsection

	---@section trackingUpdate
	---@param self TrackingRadar
	trackingUpdate = function(self)
		local azim, elev, dist_h, dist_v, a
		a = self
		azim = input.getNumber(a.ch_in_v + 1)
		elev = input.getNumber(a.ch_in_h + 1)
		dist_h = input.getNumber(a.ch_in_h + 2)
		dist_v = input.getNumber(a.ch_in_v + 2)
		if input.getNumber(a.ch_in_v) ~= 0 then
			output.setNumber(a.ch_out_h, -azim)
			a:setFOV(dist_v)
		end
		if input.getNumber(a.ch_in_h) ~= 0 then
			output.setNumber(a.ch_out_v,
				math.atan(dist_h * math.sin(elev * 2 * math.pi) - 0.5, dist_h * math.cos(elev * 2 * math.pi)) / 2 / math.pi)
			a:setFOV(dist_h)
		end
	end;
	---@endsection

	---@section setFOV
	---@param self TrackingRadar
	---@param dist number
	setFOV = function(self, dist)
		output.setNumber(self.ch_out_fov, math.atan(40, dist) / 2 / math.pi)
	end;
	---@endsection
}
---@endsection
