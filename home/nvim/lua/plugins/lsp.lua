return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          -- Use the system-installed nil
          cmd = { "nil" },
        },
      },
    },
  },
}
