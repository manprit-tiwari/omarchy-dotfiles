-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Shared by both machines, so pick settings per hostname.
local f = io.open("/etc/hostname", "r")
local host = f and f:read("*l") or ""
if f then f:close() end

if host == "omarchy-m" then
  -- MacBook Air M1: 2560x1600 HiDPI panel (eDP-1) at 1.6, external monitors auto.
  -- GTK only honors whole numbers for GDK_SCALE, so use the nearest integer to the monitor scale.
  hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
  hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.6 })
  hl.env("GDK_SCALE", "2")
else
  -- bankai: plain 1080p panel, not HiDPI: keep GDK_SCALE and monitor scale both at 1x
  -- (Omarchy's HiDPI-oriented GDK_SCALE=2 default oversizes GTK apps here).
  hl.env("GDK_SCALE", "1")
  hl.monitor({ output = "", mode = "1920x1080@60", position = "auto", scale = 1 })
end

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
