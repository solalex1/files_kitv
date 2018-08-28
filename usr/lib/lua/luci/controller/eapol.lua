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

module("luci.controller.eapol", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/eapol") then
		return
	end

	local page

	page = entry({"admin", "network", "eapol"}, cbi("eapol"), _("IEEE 802.1x"), 90)
	page.dependent = true
end
