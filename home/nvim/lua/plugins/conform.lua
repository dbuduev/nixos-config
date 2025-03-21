return {
   -- Configure the formatter to use the system-installed stylua
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      
      -- Configure formatters to use the system path
      opts.formatters.stylua = {
        command = "stylua",
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      }
      opts.formatters_by_ft = {
        nix = { "alejandra" },
      }
      
      return opts
    end,
  }
}
