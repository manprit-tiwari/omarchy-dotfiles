return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- Ensure event_handlers exists
    opts.event_handlers = opts.event_handlers or {}
    -- Append the file_opened event handler
    table.insert(opts.event_handlers, {
      event = "file_opened",
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end,
    })
  end,
}
