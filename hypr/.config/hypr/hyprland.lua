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
-- Classes verified against each app's installed .desktop StartupWMClass
-- (or, for Chrome webapps, hyprctl clients) after the Omarchy 4 migration —
-- several had drifted from the old Omarchy 3 config (e.g. Postman/OBS/Code/
-- Antigravity casing, Ghostty only routing once it was set as $TERMINAL).
o.window({ class = "google-chrome" }, { workspace = "1" })
o.window({ class = "org.gnome.Nautilus" }, { workspace = "1" })
o.window({ class = "com.mitchellh.ghostty" }, { workspace = "2" })
o.window({ class = "Slack" }, { workspace = "3" }) -- not currently installed; harmless if unused
o.window({ class = "chrome-web.whatsapp.com__-Default" }, { workspace = "3" })
o.window({ class = "chrome-chatgpt.com__-Default" }, { workspace = "4" })
o.window({ class = "MongoDB Compass" }, { workspace = "5" }) -- no StartupWMClass in .desktop; verify against hyprctl clients when open
o.window({ class = "postman" }, { workspace = "6" }) -- was "Postman"; StartupWMClass is lowercase
o.window({ class = "jetbrains-studio" }, { workspace = "9" })
o.window({ class = "Antigravity" }, { workspace = "10" }) -- was "antigravity"; StartupWMClass is capitalized
o.window({ class = "Code" }, { workspace = "10" }) -- was "code"; StartupWMClass is capitalized
o.window({ class = "obs" }, { workspace = "special:scratchpad" }) -- was "com.obsproject.Studio"; StartupWMClass is "obs"
