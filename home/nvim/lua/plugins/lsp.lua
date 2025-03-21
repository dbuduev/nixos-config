return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          -- Use the system-installed nil
          enabled = true,
          cmd = { "nil" },
        },
      },
    },
  },
}
