
require("mason-lspconfig").setup({
  ensure_installed = { "pyright" },
  handlers = {
    function(server_name)
      require("lspconfig")[server_name].setup({})
    end,

    -- Handler spécifique Python
    ["pyright"] = function()
      require("lspconfig").pyright.setup({
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "strict",
            },
          },
        },
      })
    end,
  },
})
