return {
  "nvim-telescope/telescope.nvim",
  opts = {
    pickers = {
      buffers = {
        initial_mode = "normal",
        mappings = {
          n = {
            ["d"] = "delete_buffer",
            ["h"] = "delete_buffer",
            ["l"] = "select_default",
          },
        },
      },
    },
  },
}
