-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Deep transparency: clear backgrounds on highlight groups not covered by tokyonight's transparent option
local function apply_transparency()
  local groups = {
    "Normal", "NormalFloat", "FloatBorder", "Pmenu",
    "Terminal", "EndOfBuffer", "FoldColumn", "Folded",
    "SignColumn", "LineNr", "CursorLineNr", "NormalNC",
    "TelescopeBorder", "TelescopeNormal", "TelescopePromptBorder", "TelescopePromptTitle",
    "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeVertSplit", "NeoTreeWinSeparator", "NeoTreeEndOfBuffer",
    "NvimTreeNormal", "NvimTreeVertSplit", "NvimTreeEndOfBuffer",
    "NotifyINFOBody", "NotifyERRORBody", "NotifyWARNBody", "NotifyTRACEBody", "NotifyDEBUGBody",
    "NotifyINFOTitle", "NotifyERRORTitle", "NotifyWARNTitle", "NotifyTRACETitle", "NotifyDEBUGTitle",
    "NotifyINFOBorder", "NotifyERRORBorder", "NotifyWARNBorder", "NotifyTRACEBorder", "NotifyDEBUGBorder",
  }
  for _, name in ipairs(groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok then
      hl.bg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("deep_transparency", { clear = true }),
  callback = apply_transparency,
})
-- Apply immediately for the initial colorscheme load
apply_transparency()
