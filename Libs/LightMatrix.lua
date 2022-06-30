---@section LIGHTMATRIXBOILERPLATE
-- Author: TAK4129
-- GitHub: https://github.com/yukimaru73
-- Workshop: https://steamcommunity.com/profiles/76561198174258594/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
---@endsection

require("LifeBoatAPI.Utils.LBCopy")

---@section LMatrix 1 LMATRIX
---@class LMatrix
---@field row number
---@field clm number
---@field mat table
LMatrix = {

	---@param cls LMatrix
	---@param row number row of matrix
	---@param clm number column of matrix
	---@return LMatrix
	new = function(cls, row, clm)
		local matmat = {}
		for i = 1, row do
			matmat[i] = {}
			for j = 1, clm do
				matmat[i][j] = 0
			end
		end
		local mat = LifeBoatAPI.lb_copy(cls, { row = row, clm = clm, mat = matmat })
		return mat
	end;

	---@section get
	---@param self LMatrix
	---@param row number
	---@param clm number
	---@return number
	get = function(self, row, clm)
		return self.mat[row][clm]
	end;
	---@endsection

	---@section set
	---@param self LMatrix
	---@param row number
	---@param clm number
	---@param value number
	set = function(self, row, clm, value)
		self.mat[row][clm] = value
	end;
	---@endsection

	---@section eye
	---@param self LMatrix
	---@return LMatrix
	eye = function(self)
		for i = 1, self.row do
			self:set(i, i, 1)
		end
		return self
	end;
	---@endsection

	---@section copy
	---@param self LMatrix
	copy = function(self)
		local a = self
		local m = LMatrix:new(a.row, a.clm)
		for i = 1, a.row do
			for j = 1, a.clm do
				m:set(i, j, a:get(i, j))
			end
		end
		return m
	end;
	---@endsection

	---@section add
	--- Calculate addition of 2 matrix. Both Matrix are must be same shape.
	---@param self LMatrix
	---@param mat LMatrix
	---@return LMatrix
	add = function(self, mat)
		local a = self
		local amat = LMatrix:new(a.row, a.clm)
		for ir = 1, a.row do
			for ic = 1, a.clm do
				amat:set(ir, ic, a:get(ir, ic) + mat:get(ir, ic))
			end
		end
		return amat
	end;
	---@endsection

	---@section sub
	--- Calculate subtraction of 2 matrix. Both Matrix are must be same shape.
	---@param self LMatrix
	---@param mat LMatrix
	---@return LMatrix
	sub = function(self, mat)
		local a = self
		local amat = LMatrix:new(a.row, a.clm)
		for ir = 1, a.row do
			for ic = 1, a.clm do
				amat:set(ir, ic, a:get(ir, ic) - mat:get(ir, ic))
			end
		end
		return amat
	end;
	---@endsection

	---@section mat
	--- Calculate dot product of 2 matrix.
	---@param self LMatrix
	---@param scalar number
	---@return LMatrix
	mul = function(self, scalar)
		local m = self:copy()
		for i = 1, m.row do
			for j = 1, m.clm do
				m:set(i, j, m:get(i, j) * scalar)
			end
		end
		return m
	end;
	---@endsection

	---@section mat
	--- Calculate dot product of 2 matrix(A・B). B column must be equals to A row.
	---@param self LMatrix
	---@param mat LMatrix
	---@return LMatrix
	dot = function(self, mat)
		local a = self
		local mmat = LMatrix:new(a.row, mat.clm)
		for ir = 1, a.row do
			for ic = 1, mat.clm do
				for ic2 = 1, a.clm do
					mmat:set(ir, ic, mmat:get(ir, ic) + a:get(ir, ic2) * mat:get(ic2, ic))
				end
			end
		end
		return mmat
	end;
	---@endsection

	---@section det
	--- Calculate determinant of the Matrix. Matrix must be square.
	---@param self LMatrix
	---@return number
	det = function(self)
		local n = self.row
		local bmat = LMatrix:new(n, n)
		for ir = 1, n do
			for ic = 1, n do
				bmat:set(ir, ic, self:get(ir, ic))
			end
		end
		local det, buf = 1, 0
		for ic = 1, n do
			for ir = 1, n do
				if ic < ir then
					buf = bmat:get(ir, ic) / bmat:get(ic, ic)
					for i = 1, n do
						bmat:set(ir, i, bmat:get(ir, i) - bmat:get(ic, i) * buf)
					end
				end
			end
		end
		for i = 1, n do
			det = det * bmat:get(i, i)
		end
		return det
	end;
	---@endsection

	---@section inv
	--- Calculate inverse of the Matrix (A^-1). Matrix must be a regular matrix(det(A) not equals to 0).
	---@param self LMatrix
	---@return LMatrix
	inv = function(self)
		local n = self.row
		local inv = LMatrix:new(n, n)
		local sweep = LMatrix:new(n, n * 2)
		local a = 0
		for i = 1, n do
			for j = 1, n do
				sweep:set(i, j, self:get(i, j))
				if i == j then
					sweep:set(i, n + j, 1)
				else
					sweep:set(i, n + j, 0)
				end
			end
		end
		for k = 1, n do
			local max = math.abs(sweep:get(k, k))
			local max_i = k
			for i = k + 1, n do
				local b = math.abs(sweep:get(i, k))
				if b > max then
					max = b
					max_i = i
				end
			end
			if k ~= max_i then
				for j = 1, n * 2 do
					local tmp = sweep:get(max_i, j)
					sweep:set(max_i, j, sweep:get(k, j))
					sweep:set(k, j, tmp)
				end
			end
			a = 1 / sweep:get(k, k)
			for j = 1, n * 2 do
				sweep:set(k, j, sweep:get(k, j) * a)
			end
			for i = 1, n do
				if i ~= k then
					a = -sweep:get(i, k)
					for j = 1, n * 2 do
						sweep:set(i, j, sweep:get(i, j) + sweep:get(k, j) * a)
					end
				end
			end
		end
		for i = 1, n do
			for j = 1, n do
				inv:set(i, j, sweep:get(i, n + j))
			end
		end
		return inv
	end;
	---@endsection

	---@section transpose
	--- Calculate transpose of the Matrix (A^T).
	---@param self LMatrix
	---@return LMatrix
	transpose = function(self)
		local row, clm = self.row, self.clm
		local t = LMatrix:new(clm, row)
		for i = 1, row do
			for j = 1, clm do
				t:set(j, i, self:get(i, j))
			end
		end
		return t
	end;
	---@endsection

	---@section solve
	--- Solve AX=Y for X with LU decomposition.
	--- A(n x n), X(n x 1), Y(n x 1)
	---@param self LMatrix
	---@param y LMatrix
	---@return LMatrix
	solve = function(self, y)
		local a = self:copy()
		local p, n = { 0, 0 }, a.row
		for i = 1, n do
			p[i - 1] = i - 1
		end
		for k = 1, n - 1 do
			local pivot, amax = k - 1, math.abs(a:get(k, k))
			for i = k + 1, n do
				if math.abs(a:get(i, k)) > amax then
					pivot = i - 1
					amax = math.abs(a:get(k, k))
				end
			end
			if pivot + 1 ~= k then
				for i = 1, n do
					local tmp = a:get(k, i)
					a:set(k, i, a:get(pivot + 1, i))
					a:set(pivot + 1, i, tmp)
					tmp = p[k - 1]
					p[k - 1] = p[pivot]
					p[pivot] = tmp
				end
			end
			for i = k + 1, n do
				a:set(i, k, a:get(i, k) / a:get(k, k))
				for j = k + 1, n do
					a:set(i, j, a:get(i, j) - a:get(i, k) * a:get(k, j))
				end
			end
		end
		local x = LMatrix:new(n, 1)
		for i = 1, n do
			x:set(i, 1, y:get(p[i - 1] + 1, 1))
		end
		for i = 2, n do
			for j = 1, i - 1 do
				x:set(i, 1, x:get(i, 1) - a:get(i, j) * x:get(j, 1))
			end
		end
		for i = n, 1, -1 do
			for j = i + 1, n do
				x:set(i, 1, (x:get(i, 1) - a:get(i, j) * x:get(j, 1)))
			end
			x:set(i, 1, x:get(i, 1) / a:get(i, i))
		end
		return x
	end;
	---@endsection

	---@section qr
	--- Do QR decomposition.
	---@param self LMatrix
	---@return LMatrix,LMatrix
	qr = function(self)
		local sign = function(x)
			if x >= 0 then
				return 1
			else
				return -1
			end
		end
		local n = self.row
		local r = self:copy()
		local q = LMatrix:new(n, n):eye()
		local u = LMatrix:new(1, n)
		for k = 1, n - 1 do
			local absx = 0
			for i = k, n do
				absx = absx + r:get(i, k) ^ 2
			end
			absx = math.sqrt(absx)
			if absx ~= 0 then
				u:set(1, k, r:get(k, k) + sign(r:get(k, k)) * absx)
				local absu = u:get(1, k) ^ 2
				for i = k + 1, n do
					u:set(1, i, r:get(i, k))
					absu = absu + u:get(1, i) ^ 2
				end
				local h = LMatrix:new(n, n):eye()
				for i = k, n do
					for j = k, n do
						h:set(i, j, h:get(i, j) - 2 * u:get(1, i) * u:get(1, j) / absu)
					end
				end
				r = h:dot(r)
				q = q:dot(h)
			end
		end
		return q, r
	end;
	---@endsection

	---@section newRotateMatrix
	---@param self LMatrix
	---@param roll number
	---@param pitch number
	---@param yaw number
	---@return LMatrix
	newRotateMatrix = function(self, roll, pitch, yaw)
		pitch = pitch * math.pi * 2
		yaw = -yaw % 1 * math.pi * 2
		roll = math.asin(math.sin(roll * 2 * math.pi) / math.cos(pitch))
		local sx, sy, sz, cx, cy, cz = math.sin(pitch), math.sin(yaw), math.sin(roll), math.cos(pitch), math.cos(yaw),math.cos(roll)
		local rx = LMatrix:new(3, 3)
		local ry = LMatrix:new(3, 3)
		local rz = LMatrix:new(3, 3)
		rx:set(1, 1, 1)
		rx:set(2, 2, cx)
		rx:set(2, 3, sx)
		rx:set(3, 2, -sx)
		rx:set(3, 3, cx)
	
		ry:set(1, 1, cy)
		ry:set(1, 3, sy)
		ry:set(2, 2, 1)
		ry:set(3, 1, -sy)
		ry:set(3, 3, cy)
	
		rz:set(1, 1, cz)
		rz:set(1, 2, -sz)
		rz:set(2, 1, sz)
		rz:set(2, 2, cz)
		rz:set(3, 3, 1)
		return ry:dot(rx:dot(rz))
	end;
	---@endsection
}
---@endsection LMatrix 1 LMATRIX
