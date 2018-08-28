--[[
LuCI - Lua Configuration Interface

Copyright 2013 M0xf <m0xf@ya.ru>
Copyright 2013 yohimba <yohimba@mail.ru>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: eapol.lua 9866 2013-07-07 11:30:00Z yohimba $
]]--

require("luci.tools.webadmin")

m = Map("eapol",
	translate("Wired 802.1x authentication"),
	translate("Авторизация в сети Крылья ITV"))

function m.on_after_commit(map)
    os.execute('/usr/sbin/eapol_up')
end

local uci = require("luci.model.uci")
local fs = require "nixio.fs"

s = m:section(TypedSection, "eapol")
s.addremove = true
s.anonymous = false

local supplicant = fs.access("/usr/sbin/wpa_supplicant")
local has_eap = (os.execute("wpa_supplicant -veap >/dev/null 2>/dev/null") == 0)

if (supplicant and not has_eap) then
    p_install = s:option(Button, "_install", translate('Support IEEE 802.1x (EAPOL)'), translate('Please install package "wpad"! The package "wpad-mini" does not support IEEE 802.1x (EAPOL).'))
    p_install.inputtitle = translate('Remove package "wpad-mini" and install package "wpad"')
    p_install.inputstyle = "apply"
    function p_install.write()
	return luci.http.redirect(luci.dispatcher.build_url("admin/system/packages") .. "?submit=1&install=wpad")
    end
elseif (not supplicant and not has_eap) then
    p_install = s:option(Button, "_install", translate('Support IEEE 802.1x (EAPOL)'), translate('Please install package "wpad"!'))
    p_install.inputtitle = translate('Install package "wpad"')
    p_install.inputstyle = "apply"
    function p_install.write()
	return luci.http.redirect(luci.dispatcher.build_url("admin/system/packages") .. "?submit=1&install=wpad")
    end
end

en = s:option(Flag, "enabled", translate("Enable"))
en.rmempty = false

at = s:option(ListValue, "type", translate("Type"))
at:value("MD5", "MD5 Challenge")
at:value("PEAP_MSCHAPV2", "PEAP with EAP-MSCHAPv2")

ad = s:option(ListValue, "driver", translate("Driver"))
ad:value("wired","wired")
ad:value("roboswitch","roboswitch")

ai = s:option(ListValue, "interface", translate("Interface"))


local state = uci.cursor_state()
state:load("network")
state:foreach("network", "interface",
    function(section)
	local ifname = state:get(
		"network", section[".name"], "ifname"
	)
	ai:value(ifname,section[".name"] )
    end
)

au = s:option(Value, "username", translate("Username"))
au.rmempty = false
au.optional = false

ap = s:option(Value, "password", translate("Password"))
ap.rmempty = false
ap.optional = false
ap.password = true

return m
