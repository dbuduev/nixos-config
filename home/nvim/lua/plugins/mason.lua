return {
   {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      
      -- Add tools you want mason to manage here
      vim.list_extend(opts.ensure_installed, {
        -- Add tools that work well with mason on NixOS
      })
    end,
  },
  
  -- Configure mason-tool-installer to not attempt to install tools we provide through Nix
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- Leave this empty or add only tools that work with NixOS
      },
      auto_update = false,
      run_on_start = false,
    },
  },
}
