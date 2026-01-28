require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "standardrb" }
local lspconfig = require("lspconfig")

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({})
end

-- read :h vim.lsp.config for changing options of lsp servers 
