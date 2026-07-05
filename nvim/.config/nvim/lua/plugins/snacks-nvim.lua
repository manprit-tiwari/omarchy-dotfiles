return {
  "snacks.nvim",
  opts = {
    scroll = {
      enabled = false,
    },
    -- Override the terminal style to float.
    -- `q` in normal mode hides the window (keeps process alive).
    -- Toggle with <leader>ft / <leader>fT — re-opens same terminal session.
    -- Explicit kill: type `exit` inside the terminal or `:bdelete!`.
    styles = {
      terminal = {
        position = "float",
        border = "rounded",
        height = 0.85,
        width = 0.90,
        title_pos = "center",
      },
    },
    terminal = {
      win = { style = "terminal" },
    },
    picker = {
      sources = {
        explorer = {
          auto_close = true,
        },
      },
    },
    dashboard = {
      preset = {
        header = [[
        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗          Z
        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║      Z    
        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║   z       
        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ z         
        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║           
        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝           
 ]],
      },
    },
  },
}
