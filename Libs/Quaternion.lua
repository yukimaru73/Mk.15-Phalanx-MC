require("LifeBoatAPI.Utils.LBCopy")

---@section Quaternion 1 Quaternion
---@class Quaternion
---@field Q table
Quaternion = {

	---@param cls Quaternion
	---@return Quaternion
	_new = function(cls)
		local q ={0,0,0,0}
		return LifeBoatAPI.lb_copy(cls,{Q=q})
	end;

	---@section newRotateQuaternion
	---@param cls Quaternion
	---@param angle number Turn(0 to 1, correspond to 0 to 2π)
	---@param vector table {x, y, z}
	---@return Quaternion
	newRotateQuaternion = function(cls, angle, vector)
		angle = math.pi * angle
		local r = cls:_new()
		for i = 1, 3 do
			r.Q[i] = vector[i] * math.sin(angle)
		end
		r.Q[4]=math.cos(angle)
		return r
	end;
	---@endsection


	---@section rotateVector
	---@param self Quaternion
	---@param vector table
	---@return table
	rotateVector = function(self, vector)

	end
	---@endsection
}