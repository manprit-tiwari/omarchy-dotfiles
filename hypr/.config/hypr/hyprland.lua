-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.

-- Workspace auto routing
o.window({ class = "google-chrome" }, { workspace = "1" })
o.window({ class = "org.gnome.Nautilus" }, { workspace = "1" })
o.window({ class = "com.mitchellh.ghostty" }, { workspace = "2" })
o.window({ class = "Slack" }, { workspace = "3" })
o.window({ class = "chrome-web.whatsapp.com__-Default" }, { workspace = "3" })
o.window({ class = "chrome-chatgpt.com__-Default" }, { workspace = "4" })
o.window({ class = "MongoDB Compass" }, { workspace = "5" })
o.window({ class = "Postman" }, { workspace = "6" })
o.window({ class = "jetbrains-studio" }, { workspace = "9" })
o.window({ class = "antigravity" }, { workspace = "10" })
o.window({ class = "code" }, { workspace = "10" })
o.window({ class = "com.obsproject.Studio" }, { workspace = "special:scratchpad" })
