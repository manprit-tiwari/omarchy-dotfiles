-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

----------------------------------------------------------------------------
-- Terminal / Tmux: swap the defaults so bare Return opens tmux
----------------------------------------------------------------------------
hl.unbind("SUPER + RETURN")
hl.unbind("SUPER + ALT + RETURN")
o.bind("SUPER + RETURN", "Tmux", { omarchy = "terminal-tmux" })
o.bind("SUPER + ALT + RETURN", "Terminal", { omarchy = "terminal" })

----------------------------------------------------------------------------
-- Screenshot to clipboard (default v4 puts Google Maps on SUPER+SHIFT+S)
----------------------------------------------------------------------------
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot to clipboard", "omarchy-capture-screenshot smart copy")

----------------------------------------------------------------------------
-- Show keybindings cheat sheet
----------------------------------------------------------------------------
o.bind("CTRL + ALT + B", "Show key bindings", "omarchy-menu-keybindings")

----------------------------------------------------------------------------
-- Vim-style H/J/K/L window navigation
-- (default v4 puts "toggle split" on SUPER+J and "toggle workspace layout"
-- on SUPER+L, so both need to be freed first)
----------------------------------------------------------------------------
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
hl.unbind("SUPER + L")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K") -- default: opens the keybindings menu; kept on CTRL+ALT+B below

-- H/L move focus left/right by screen position (spatial, always predictable)
o.bind("SUPER + H", "Focus left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus right window", hl.dsp.focus({ direction = "r" }))
-- K/J move focus up/down within a column (tiled only)
o.bind("SUPER + K", "Move window focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + J", "Move window focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + PERIOD", "Toggle window split", hl.dsp.layout("togglesplit"))

o.bind("SUPER + D", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

----------------------------------------------------------------------------
-- Move workspaces to other monitors (vim keys instead of arrows)
----------------------------------------------------------------------------
hl.unbind("SUPER + SHIFT + ALT + LEFT")
hl.unbind("SUPER + SHIFT + ALT + RIGHT")
hl.unbind("SUPER + SHIFT + ALT + UP")
hl.unbind("SUPER + SHIFT + ALT + DOWN")
o.bind("SUPER + SHIFT + ALT + H", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + ALT + L", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
o.bind("SUPER + SHIFT + ALT + K", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + ALT + J", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))

----------------------------------------------------------------------------
-- Swap active window with the one next to it (vim keys, additive to arrows)
----------------------------------------------------------------------------
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

----------------------------------------------------------------------------
-- Workspace TAB cycling (SUPER+TAB = former, CTRL adds next/previous)
----------------------------------------------------------------------------
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("SUPER + CTRL + TAB")
o.bind("SUPER + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("SUPER + CTRL + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + CTRL + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
