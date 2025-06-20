return {
  {
    "dawsers/edit-code-block.nvim",
    config = function()
      require("ecb").setup({
        wincmd = "vsplit",
      })
    end,
  },
}
