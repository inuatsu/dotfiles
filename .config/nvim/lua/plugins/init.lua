return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require "configs.treesitter"
    end,
  },

  { "max397574/better-escape.nvim", opts = {} },

  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python", --optional
    },
    event = "BufReadPre",
    branch = "regexp", -- This is the regexp branch, use this for the new version
    opts = {
      settings = {
        options = {
          activate_venv_in_terminal = false,
          cached_venv_automatic_activation = false,
          debug = true,
          enable_cached_venvs = false,
          notify_user_on_venv_activation = true,
        },
      },
    },
    keys = {
      { ",v", "<cmd>VenvSelect<cr>" },
    },
  },

  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "DiffviewOpen",
  },

  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    opts = {
      suppress_missing_scope = {
        projects_v2 = true,
      },
    },
  },

  {
    "github/copilot.vim",
    event = "BufReadPost",
    config = function()
      vim.cmd [[
        imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
        let g:copilot_no_tab_map = v:true
      ]]
    end,
  },

  { "echasnovski/mini.nvim", version = false },

  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    opts = {},
  },

  {
    "kevinhwang91/nvim-hlslens",
    event = "BufReadPost",
    opts = {},
  },

  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  {
    "AckslD/nvim-neoclip.lua",
    event = "BufReadPost",
    dependencies = {
      { "kkharji/sqlite.lua", module = "sqlite" },
      { "nvim-telescope/telescope.nvim" },
    },
    opts = {
      enable_persistent_history = true,
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lint"
    end,
  },

  {
    "kndndrj/nvim-dbee",
    cmd = "Dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      require("dbee").install()
    end,
    opts = {},
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "MattiasMTS/cmp-dbee",
        ft = "sql",
        opts = {},
      },
    },
    config = function(_, opts)
      local myopts = {
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "nvim_lua" },
          { name = "path" },
          { name = "cmp-dbee" },
        },
      }

      opts = vim.tbl_deep_extend("force", myopts, opts)
      require("cmp").setup(opts)
    end,
  },

  {
    "Bekaboo/deadcolumn.nvim",
    event = "BufReadPost",
    opts = {
      modes = function(mode)
        return mode:find "^[icntRss\x13]" ~= nil
      end,
    },
  },

  {
    "j-hui/fidget.nvim",
    event = "BufReadPre",
    opts = {
      progress = {
        lsp = {
          log_handler = true,
        },
      },
      notification = {
        poll_rate = 60,
        override_vim_notify = true,
      },
    },
  },

  { "OXY2DEV/markview.nvim", ft = "markdown" },
}
