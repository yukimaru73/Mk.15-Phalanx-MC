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

	
	---@section _getConjugateQuaternion
	---@param self Quaternion
	---@return Quaternion
	_getConjugateQuaternion = function(self)
		local c = self:_new()
			for i = 1, 3 do
				c.Q[i] = -self.Q[i]
			end
			c.Q[4] = -self.Q[4]
		return c
	end;
	---@endsection

	---@section _product calculate A⊗B
	---@param self Quaternion A
	---@param target Quaternion B
	---@return Quaternion
	_product = function(self, target)
		local a = self
		local result = Quaternion:_new()
		for i = 1, 4 do
			for j = 1, 4 do
				
			end
		end
		return result
	end;
	---@endsection

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


	--[[
	---@section rotateVector
	---@param self Quaternion
	---@param vector table
	---@return table
	rotateVector = function(self, vector)

	end;
	---@endsection
	]]
}