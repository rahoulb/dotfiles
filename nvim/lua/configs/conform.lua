local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    html = { "htmlbeautifier" },
    eruby = { "htmlbeautifier", "erb_lint" },
    css = { "prettier" },
    javascript = { "prettier" },
  },

  formatters = {
    htmlbeautifier = {
      command = "bundle",
      args = { "exec", "htmlbeautifier", "$FILENAME" },
      stdin = false,
    },
    erb_lint = {
      command = "bundle",
      args = { "exec", "erb_lint", "--config=~/.config/nvim/lua/configs/erb_lint.yml", "$FILENAME" },
      stdin = false,
    },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
