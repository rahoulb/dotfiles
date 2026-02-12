require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "standardrb" }

for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {})
end

vim.lsp.enable(servers)
