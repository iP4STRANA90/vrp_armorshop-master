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
-- a basic gunshop implementation
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPas = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_armorshop")
ASclient = Tunnel.getInterface("vrp_armorshop","vrp_armorshop")
Tunnel.bindInterface("vrp_armorshop",vRPas)

local Lang = module("vrp", "lib/Lang")
local lcfg = module("vrp", "cfg/base")
local lang = Lang.new(module("vrp", "cfg/lang/"..lcfg.lang) or {})
]]

local lang = vRP.lang
local Luang = module("vrp", "lib/Luang")
local htmlEntities = module("vrp", "lib/htmlEntities")

local Weaponshop = class("Weaponshop", vRP.Extension)

function Weaponshop:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp_armorshop", "cfg/gunshops")

  -- load lang
  self.luang = Luang()
  self.luang:loadLocale(vRP.cfg.lang, module("vrp_armorshop", "cfg/lang/"..vRP.cfg.lang))
  self.lang = self.luang.lang[vRP.cfg.lang]

  local function m_buy(menu,choice)
    local user = menu.user
    local weapon = menu.data.weapons[choice]
    local price = weapon[2]
    local price_ammo = weapon[3]
    local tuser = vRP.EXT.PlayerState.remote.getWeapons(user.source)
    if choice then
      if choice == "ARMOR" then-- get player weapons to not rebuy the body
        if user ~= nil and user:tryPayment(price) then
          self.remote._setArmour(user.source, 100, true)
          vRP.EXT.Base.remote._notify(user.source,lang.money.paid({price}))
        else
          vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
        end
      else
        -- get player weapons to not rebuy the body
        local tuser = vRP.EXT.PlayerState.remote.getWeapons(user.source)
        -- prompt amount
        local amount = parseInt(user:prompt(self.lang.weaponshop.prompt(),""))
        if amount >= 1 then
          local total = math.ceil(price_ammo*amount)
          if tuser[string.upper(choice)] == nil then -- add body price if not already owned
            total = price+price_ammo*amount
          end
          -- payment
          if user ~= nil and user:tryPayment(total) then
            local weapons = {}
            weapons[choice] = {ammo = amount}
            vRP.EXT.PlayerState.remote._giveWeapons(user.source, weapons)
            vRP.EXT.Base.remote._notify(user.source,lang.money.paid({total}))
          else
            vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
          end
        else
          vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
        end
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("weapons_main", function(menu)
    local user = menu.user
    menu.title = self.lang.weaponshop.title()
    menu.css.header_color = "rgba(255,0,0,0.75)"
    for k,v in pairs(menu.data.weapons) do
      if k ~= "_config" then
        menu:addOption(v[1], m_buy, self.lang.weaponshop.info({htmlEntities.encode(v[2]),htmlEntities.encode(v[3]),htmlEntities.encode(v[4])}), k)
      end
    end
  end)
end


Weaponshop.event = {}
function Weaponshop.event:playerSpawn(user,first_spawn)
  if first_spawn then
    for k,v in pairs(self.cfg.shops) do
      local shop,x,y,z = table.unpack(v)
      local group = self.cfg.weapons[shop]

      if group then
        local gcfg = group._config

        local function enter(user)
          if user:hasPermissions(gcfg.permissions or {}) then
            menu = user:openMenu("weapons_main",{type = shop, weapons = group})
          end
        end

        local function leave(user)
          if menu then
            user:closeMenu(menu)
          end
        end
        local ment = clone(gcfg.map_entity)
        ment[2].title = self.lang.weaponshop.title()
        ment[2].pos = {x,y,z-1}
        vRP.EXT.Map.remote._addEntity(user.source,ment[1], ment[2])

        user:setArea("vRP:weaponshop"..k,x,y,z,1,1.5,enter,leave)
      end
    end
  end
end


vRP:registerExtension(Weaponshop)
