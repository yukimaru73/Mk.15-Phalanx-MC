require("Libs.LightMatrix")

---@section FJ 1 FJ
---@param mf LMatrix
---@param mj LMatrix
---@param gX number
---@param gY number
---@param gZ number
---@param tX number
---@param tY number
---@param tZ number
---@param Vx number
---@param Vy number
---@param Vz number
---@param V0 number
---@param d number
---@param L number
---@param pt number
---@param pth number
---@param pp number
---@return LMatrix,LMatrix
function FJ(gX, gY, gZ, tX, tY, tZ, Vx, Vy, Vz, V0, d, L, pt, pth, pp, mf, mj)
	local d1 = 1 - d
	local logD60, dpt1, ptL, sth, cth, sp, cp = 60 * math.log(d1), d1 ^ pt - 1, pt + L, math.sin(pth), math.cos(pth), math.sin(pp), math.cos(pp)
	mf:set(1, 1, ((tY - gY) + Vy * ptL) - (V0 * sth + .5 / d) * dpt1 / logD60 + pt / 120 / d)
	mf:set(2, 1, ((tX - gX) + Vx * ptL) - V0 * cth * cp * dpt1 / logD60)
	mf:set(3, 1, ((tZ - gZ) + Vz * ptL) - V0 * cth * sp * dpt1 / logD60)

	mj:set(1, 1, Vy - (d1 ^ pt * (V0 * sth + 0.5 / d)) / 60 + 1 / 120 / d)
	mj:set(1, 2, -(V0 * dpt1 * cth) / logD60)
	mj:set(2, 1, Vx - (V0 * d1 ^ pt * cth * cp) / 60)
	mj:set(2, 2, (V0 * dpt1 * sth * cp) / logD60)
	mj:set(2, 3, (V0 * dpt1 * cth * sp) / logD60)
	mj:set(3, 1, Vz - (V0 * d1 ^ pt * cth * sp) / 60)
	mj:set(3, 2, (V0 * dpt1 * sth * sp) / logD60)
	mj:set(3, 3, -(V0 * dpt1 * cth * cp) / logD60)
	return mf, mj
end

---@endsection

---@section Balistic 1 Balistic
---@param x LMatrix
---@param gX number
---@param gY number
---@param gZ number
---@param tX number
---@param tY number
---@param tZ number
---@param Vx number
---@param Vy number
---@param Vz number
---@param V0 number
---@param d number
---@param L number
---@param dt number
---@param im number
---@param em number
---@param cont boolean
function Balistic(gX, gY, gZ, tX, tY, tZ, Vx, Vy, Vz, V0, d, L, dt, im, em, cont, x)
	local p0 = LMatrix:new(3, 1)
	local v0 = LMatrix:new(3, 1)
	local f = false
	if cont then
		v0 = x
	else
		local pt = math.sqrt((tX - gX) ^ 2 + (tY - gY) ^ 2 + (tZ - gZ) ^ 2) / (V0 / 60)
		v0:set(1, 1, pt)
		v0:set(2, 1, math.atan(tY - gY + Vy * pt, math.sqrt((tX - gX + Vx * pt) ^ 2 + (tZ - gZ + Vz * pt) ^ 2)))
		v0:set(3, 1, math.atan(tZ - gZ + Vz * pt,tX - gX + Vx * pt))
	end
	local F0 = LMatrix:new(3, 1)
	local J0 = LMatrix:new(3, 3)
	for i = 1, im do
		F0, J0 = FJ(gX, gY, gZ, tX, tY, tZ, Vx, Vy, Vz, V0, d, L, v0:get(1, 1), v0:get(2, 1), v0:get(3, 1), F0, J0)
		local er = 0
		for k = 1, 3 do
			local er2 = math.abs(F0:get(k, 1))
			if er < er2 then
				er = er2
			end
		end
		if er < em then
			f = true
			break
		end

		local Q, R = J0:transpose():qr()
		local srcp = p0:mul(-2):sub(R:transpose():solve(F0))
		local srcx = Q:dot(p0)
		v0, p0 = v0:add(srcx:mul(dt)), p0:add(srcp:mul(dt))
	end
	return v0, f
end
---@endsection

VALMAT, TICK, ELEV, AZIM, FLAG = LMatrix:new(3,1), 0, 0, 0, false
function onTick()
	if not input.getBool(1) then
		FLAG = false
	else
		VALMAT, FLAG = Balistic(0, 0, 0, input.getNumber(1), input.getNumber(2) , input.getNumber(3), input.getNumber(11), input.getNumber(12), input.getNumber(13), property.getNumber("Muzzle Velocity"), property.getNumber("Air Resistance"), property.getNumber("Timelag"), 0.7, 30, 0.01, FLAG, VALMAT)
	end
	if VALMAT:get(1, 1) > 0 and FLAG then
		TICK, ELEV, AZIM = VALMAT:get(1, 1), VALMAT:get(2, 1), VALMAT:get(3, 1)
		output.setBool(1, true)
	else
		output.setBool(1, false)
	end
	output.setNumber(22, ELEV)
	output.setNumber(23, AZIM)
	output.setNumber(24, TICK)

	for i = 1, 4 do
		output.setNumber(i+24,input.getNumber(i+13))
	end

end