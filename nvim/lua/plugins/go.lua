return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure Go parsers are installed
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "go",
        "gomod",
        "gosum",
        "gowork",
      })
    end,
  },
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        treesitter = {
          install_parsers = true,
        },
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod", "gosum", "gowork" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
}
