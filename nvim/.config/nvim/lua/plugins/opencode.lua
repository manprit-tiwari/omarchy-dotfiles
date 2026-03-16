-- lua/plugins/opencode.lua
-- Intuitive Opencode Integration for LazyVim

return {
  "nickvandyke/opencode.nvim",
  version = "*",

  -- `init` runs BEFORE the plugin loads so vim.g.opencode_opts is available
  -- when opencode.config deep-merges it with the built-in defaults.
  init = function()
    vim.g.opencode_opts = {
      provider = {
        enabled = "snacks",
        snacks = {
          win = {
            position = "float",
            border = "rounded",
            height = 0.85,
            width = 0.90,
            title = " OpenCode ",
            title_pos = "center",
            enter = true, -- auto-focus the float when it opens
          },
        },
      },
    }
  end,

  dependencies = {
    {
      ---@module "snacks"
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {},
        picker = {
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
        terminal = {},
      },
    },
  },

  config = function()
    local oc = require("opencode")
    vim.o.autoread = true

    ----------------------------------------------------------------
    -- Focus-aware toggle
    --   • Opening  → saves the current editor window, opens the float,
    --                enter=true moves focus there automatically.
    --   • Closing  → hides the float, restores the saved editor window.
    ----------------------------------------------------------------
    local _prev_win = nil
    -- Captured when the opencode terminal buffer is first created (FileType
    -- autocmd below).  Stored here so VimLeavePre can kill the process even
    -- after the terminal window has been hidden / the snacks registry entry
    -- has been GC'd (snacks uses __mode = "v" weak-value tables).
    local _oc_job_id = nil

    local function toggle_opencode()
      local oc_config = require("opencode.config")
      local provider = oc_config.provider
      if not provider then return end

      local terminal = provider:get()
      local oc_win = terminal and terminal.win
      local is_visible = oc_win and vim.api.nvim_win_is_valid(oc_win)

      if is_visible then
        -- Hide the float and jump back to the editor window we came from.
        oc.toggle()
        vim.schedule(function()
          if _prev_win and vim.api.nvim_win_is_valid(_prev_win) then
            vim.api.nvim_set_current_win(_prev_win)
          end
        end)
      else
        -- Remember where we are so we can return on close.
        _prev_win = vim.api.nvim_get_current_win()
        oc.toggle() -- enter=true in win opts moves focus to the float
      end
    end

    ----------------------------------------------------------------
    -- Global keymaps  <leader>a*
    -- "n" + "t" so they fire whether focus is in the editor OR the float.
    ----------------------------------------------------------------

    vim.keymap.set({ "n", "t" }, "<leader>at", toggle_opencode, {
      desc = "AI Toggle Opencode",
    })

    -- Ask / prompt
    vim.keymap.set({ "n", "v" }, "<leader>aa", function()
      oc.ask("@this", { submit = true })
    end, { desc = "AI Ask about code" })

    vim.keymap.set("v", "<leader>as", oc.select, {
      desc = "AI Send selection",
    })

    vim.keymap.set("n", "<leader>af", function()
      oc.ask("@file", { submit = true })
    end, { desc = "AI Ask about file" })

    -- Scroll from the editor (normal mode)
    vim.keymap.set("n", "<leader>aj", function()
      oc.command("session.half.page.down")
    end, { desc = "AI Scroll down" })

    vim.keymap.set("n", "<leader>ak", function()
      oc.command("session.half.page.up")
    end, { desc = "AI Scroll up" })

    -- Operator motion
    vim.keymap.set("n", "gA", function()
      return oc.operator("@this")
    end, { expr = true, desc = "AI Add range" })

    ----------------------------------------------------------------
    -- Kill opencode when Neovim exits.
    --
    -- opencode handles "/exit" typed at its prompt as a clean shutdown.
    -- We replicate that by writing "/exit\n" directly to the PTY via
    -- chansend (identical to the user typing it), then wait up to 2 s
    -- for the process to exit on its own.  If it doesn't, force-kill.
    ----------------------------------------------------------------
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        if _oc_job_id then
          -- Type "/exit" + Enter into the opencode terminal.
          pcall(vim.fn.chansend, _oc_job_id, "/exit\n")
          -- Block until the process exits or the 2 s timeout fires.
          -- jobwait returns -1 on timeout, >= 0 on clean exit.
          local result = vim.fn.jobwait({ _oc_job_id }, 2000)
          if result[1] == -1 then
            -- Timed out — escalate to SIGTERM.
            local ok, pid = pcall(vim.fn.jobpid, _oc_job_id)
            if ok and type(pid) == "number" and pid > 0 then
              vim.fn.system("kill -TERM " .. pid)
            end
            pcall(vim.fn.jobstop, _oc_job_id)
          end
        end
        -- Let the plugin clean up its window and SSE curl job.
        pcall(oc.stop)
      end,
    })

    ----------------------------------------------------------------
    -- Buffer-local keymaps applied when inside the opencode terminal.
    -- The filetype "opencode_terminal" is set by the snacks provider.
    --
    -- Why an autocmd instead of on_buf:
    --   vim.g cannot store Lua functions, so on_buf can't be overridden
    --   via vim.g.opencode_opts. The FileType event fires after the buffer
    --   option is set, giving us a clean place to attach keymaps.
    ----------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "opencode_terminal",
      callback = function(args)
        local buf = args.buf
        local o = { buffer = buf }

        -- Capture the job ID for VimLeavePre.  Use vim.schedule because
        -- snacks may call on_buf (which sets the filetype) before it calls
        -- termopen/jobstart, so terminal_job_id might not be written yet.
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            _oc_job_id = vim.b[buf].terminal_job_id
          end
        end)

        -- Scroll while in terminal-insert mode (buffer-local so it doesn't
        -- bleed into other terminal windows like <leader>ft).
        vim.keymap.set("t", "<leader>aj", function()
          require("opencode").command("session.half.page.down")
        end, vim.tbl_extend("force", o, { desc = "AI Scroll down" }))

        vim.keymap.set("t", "<leader>ak", function()
          require("opencode").command("session.half.page.up")
        end, vim.tbl_extend("force", o, { desc = "AI Scroll up" }))

        -- Double-<Esc> → Neovim normal mode.
        -- Once in normal mode the keymaps set by opencode's keymaps.lua fire:
        --   <C-u> / <C-d>  half-page scroll
        --   gg / G         first / last message
        --   <Esc>          interrupt current session
        vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>",
          vim.tbl_extend("force", o, { desc = "Enter normal mode (opencode)" }))
      end,
    })

    ----------------------------------------------------------------
    -- WhichKey integration
    ----------------------------------------------------------------
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.register({
        a = {
          name = "AI / Opencode",
          t = "Toggle Window",
          a = "Ask About Code",
          s = "Send Selection",
          f = "Ask About File",
          j = "Scroll Down",
          k = "Scroll Up",
        },
      }, { prefix = "<leader>" })
    end
  end,
}
