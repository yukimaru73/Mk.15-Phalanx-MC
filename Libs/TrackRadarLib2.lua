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
	new = function(cls,ch_in_h, ch_in_v, ch_out_h, ch_out_v, ch_out_fov)
		local obj = LifeBoatAPI.lb_copy(cls,
		{ch_in_h=ch_in_h,
		ch_in_v=ch_in_v,
		ch_out_h=ch_out_h,
		ch_out_v=ch_out_v,
		ch_out_fov=ch_out_fov})
		return obj
	end;

	---@section isTracking
	---@param self TrackingRadar
	---@return boolean horizontal, boolean vertical
	isTracking = function(self)
		return input.getNumber(self.ch_in_h)~=0, input.getNumber(self.ch_in_v)~=0
	end;
	---@endsection

	---@section setViewFromPos
	---@param self TrackingRadar
	---@param x number
	---@param y number
	---@param z number
	setViewFromPos = function(self, x,y,z)
		output.setNumber(self.ch_out_h,math.atan(x,z))
		output.setNumber(self.ch_out_v,math.atan(y-0.5,math.sqrt(z^2*x^2)))
	end;
	---@endsection

	---@section setViewFromAngle
	---@param self TrackingRadar
	---@param elevation number
	---@param azimuth number
	setViewFromAngle = function(self, azimuth, elevation)
		output.setNumber(self.ch_out_h,azimuth)
		output.setNumber(self.ch_out_v,elevation)
	end;
	---@endsection

	---@section getPOS
	---@param self TrackingRadar
	getPos=function(self)
		if not self:isTracking() then return 0,0,0 end
		local x,y,z,xz
		y,xz=input.getNumber(self.ch_in_h+2)*math.sin(input.getNumber(self.ch_in_h+1)*2*math.pi), input.getNumber(self.ch_in_h+2)*math.cos(input.getNumber(self.ch_in_h+1)*2*math.pi)
		x=xz*math.cos(input.getNumber(self.ch_in_v+1)*2*math.pi)
		z=xz*math.sin(input.getNumber(self.ch_in_v+1)*2*math.pi)
		return x,y,z
	end
	---@endsection
}
---@endsection