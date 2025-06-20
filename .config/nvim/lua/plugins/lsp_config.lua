return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      tailwindcss = {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                "twc\\.[^`]+`([^`]*)`",
                "twc\\(.*?\\).*?`([^`]*)",
                { "twc\\.[^`]+\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "twc\\(.*?\\).*?\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                "(?:class: ?)(?:'|\"|`)([^\"'`]*)(?:'|\"|`)",
              },
            },
            includeLanguages = { templ = "html" },
          },
        },
        filetypes = { "templ", "javascript", "typescript", "react" },
      },
      tsserver = {},
      html = {
        filetypes = { "html", "templ" },
        init_options = {
          configurationSection = { "html", "javascript" },
          embeddedLanguages = { javascript = true },
        },
        settings = {
          configurationSection = { "html", "css", "javascript" },
          embeddedLanguages = {
            css = true,
            javascript = true,
          },
          provideFormatter = true,
        },
      },
      htmx = {
        filetypes = { "html", "templ" },
      },
    },
  },
}
