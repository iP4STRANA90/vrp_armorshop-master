--[[
    FiveM Scripts
    Copyright C 2018  Sighmir

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    at your option any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
--[[
vRPas = {}
Tunnel.bindInterface("vrp_armorshop",vRPas)
ASserver = Tunnel.getInterface("vrp_armorshop","vrp_armorshop")
]]

Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP() 

local Weaponshop = class("Weaponshop", vRP.Extension)

function Weaponshop:setArmour(armour,vest)
  local player = GetPlayerPed(-1)
  if vest then
  if(GetEntityModel(player) == GetHashKey("mp_m_freemode_01")) then
    SetPedComponentVariation(player, 9, 4, 1, 2)  --Bulletproof Vest
  else 
    if(GetEntityModel(player) == GetHashKey("mp_f_freemode_01")) then
      SetPedComponentVariation(player, 9, 6, 1, 2)
    end
  end
  end
  local n = math.floor(armour)
  SetPedArmour(player,n)
end

Weaponshop.tunnel = {}
Weaponshop.tunnel.setArmour = Weaponshop.setArmour

vRP:registerExtension(Weaponshop)
