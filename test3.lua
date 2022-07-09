-- Author: TAK4129
-- GitHub: https://github.com/yukimaru73
-- Workshop: https://steamcommunity.com/profiles/76561198174258594/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
require("Libs.Quaternion")
--{x,y,z, w}
R=Quaternion:_newRotateQuaternion(-2*((0.1397335678339 + 1.75) % 1 - 0.5)*math.pi,{0,1,0})
v2 = R:_rotateVector({0,0,1})
R2=Quaternion:_newRotateQuaternion(2*0.025932954624295*math.pi,v2):_product(R)
v2 = R2:_rotateVector({1,0,0})
R3=Quaternion:_newRotateQuaternion(2*0.025932939723134*math.pi,v2):_product(R2)
v=R3:_rotateVector({0.75,0,0})


R=Quaternion:createPitchRollYawQuaternion(0.048745542764664,0.048745546489954,-0.15978111326694)
v = {0.75,0,0}
vr = R:_rotateVector(v)
print("A")