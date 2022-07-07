function onTick()
	if not input.getBool(1) then
		return
	end
	debug.log("TST/ ,"..input.getNumber(1)..","..input.getNumber(1)..","..input.getNumber(1)..","..input.getNumber(1)..",")

	output.setNumber(1,(math.random()-0.5)*2)
end