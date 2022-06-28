Matrix = {}

Matrix = {}
Matrix.new = function(r, c)
	local obj = {
		mat = {},
		row = r,
		clm = c
	}
	for ir = 1, r do
		obj.mat[ir] = {}
		for ic = 1, c do
			obj.mat[ir][ic] = 0
		end
	end
	obj.get = function(self, row, clm)
		return self.mat[row][clm]
	end
	obj.set = function(self, row, clm, val)
		self.mat[row][clm] = val
	end
	obj.copy = function(self)
		local mat = Matrix.new(self.row, self.clm)
		for i = 1, mat.row do
			for j = 1, mat.clm do
				mat:set(i, j, self:get(i, j))
			end
		end
		return mat
	end
	obj.eye = function(self)
		for i = 1, self.row do
			self:set(i, i, 1)
		end
		return self
	end
	obj.add = function(self, mat)
		if self.clm ~= mat.clm or self.row ~= mat.row then
			return nil
		end
		local amat = Matrix.new(self.row, self.clm)
		for ir = 1, self.row do
			for ic = 1, self.clm do
				amat:set(ir, ic, self:get(ir, ic) + mat:get(ir, ic))
			end
		end
		return amat
	end
	obj.sub = function(self, mat)
		if self.clm ~= mat.clm or self.row ~= mat.row then
			return nil
		end
		local amat = Matrix.new(self.row, self.clm)
		for ir = 1, self.row do
			for ic = 1, self.clm do
				amat:set(ir, ic, self:get(ir, ic) - mat:get(ir, ic))
			end
		end
		return amat
	end
	obj.mul = function(self, v)
		local m = self:copy()
		for i = 1, m.row do
			for j = 1, m.clm do
				m:set(i, j, m:get(i, j) * v)
			end
		end
		return m
	end
	obj.dot = function(self, mat)
		if self.clm ~= mat.row then
			return nil
		end
		local mmat = Matrix.new(self.row, mat.clm)
		for ir = 1, self.row do
			for ic = 1, mat.clm do
				for ic2 = 1, self.clm do
					mmat:set(ir, ic, mmat:get(ir, ic) + self:get(ir, ic2) * mat:get(ic2, ic))
				end
			end
		end
		return mmat
	end
	obj.transpose = function(self)
		local row, clm = self.row, self.clm
		local t = Matrix.new(clm, row)
		for i = 1, row do
			for j = 1, clm do
				t:set(j, i, self:get(i, j))
			end
		end
		return t
	end
	obj.solve = function(self, y)
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
		local x = Matrix.new(1, 3)
		for i = 1, n do
			x:set(1, i, y:get(1, p[i - 1] + 1))
		end
		for i = 2, n do
			for j = 1, i - 1 do
				x:set(1, i, x:get(1, i) - a:get(i, j) * x:get(1, j))
			end
		end
		for i = n, 1, -1 do
			for j = i + 1, n do
				x:set(1, i, (x:get(1, i) - a:get(i, j) * x:get(1, j)))
			end
			x:set(1, i, x:get(1, i) / a:get(i, i))
		end
		return x
	end
	obj.qr = function(self)
		local sign = function(x)
			if x >= 0 then
				return 1
			else
				return -1
			end
		end
		local n = self.row
		local r = self:copy()
		local q = Matrix.new(n, n):eye()
		local u = Matrix.new(1, n)
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
				local h = Matrix.new(n, n):eye()
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
	end
	obj.r = function(self, roll, pitch, yaw)
		local x, y, z = self:get(1, 1), self:get(2, 1), self:get(3, 1)
		roll = math.asin(math.sin(roll) / math.cos(pitch))
		yaw = -yaw % 1 * math.pi * 2
		local sx, sy, sz, cx, cy, cz = math.sin(pitch), math.sin(yaw), math.sin(roll), math.cos(pitch), math.cos(yaw), math.cos(roll)
		local rx, ry, rz = Matrix.new(3, 3), Matrix.new(3, 3), Matrix.new(3, 3)
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
		return ry:dot(rx:dot(rz:dot(self)))
	end
	return obj
end
Matrix.rm = function(roll, pitch, yaw)
	roll = roll*2*math.pi
	pitch = pitch*2*math.pi
	yaw = -yaw % 1 * math.pi * 2
	roll = math.asin(math.sin(roll) / math.cos(pitch))
	local sx, sy, sz, cx, cy, cz = math.sin(pitch), math.sin(yaw), math.sin(roll), math.cos(pitch), math.cos(yaw),math.cos(roll)
	local rx, ry, rz = Matrix.new(3, 3), Matrix.new(3, 3), Matrix.new(3, 3)
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
end