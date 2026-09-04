# modules/home/neovim.nix
#
# Neovim powered by nixvim + LazyVim as the distribution layer.
#
# nixvim manages: nvim binary, LSP/formatter binaries, treesitter grammars,
#                 plugin installation (via pkgs.vimPlugins).
# LazyVim manages: plugin configuration, keymaps, defaults, colourscheme.
#
# Based on: https://github.com/azuwis/lazyvim-nixvim
{ pkgs, config, lib, inputs, ... }:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Use the same nixpkgs as the rest of the system
    nixpkgs.source = pkgs.path;

    # ── Leader key & base opts (LazyVim overrides most, but these are safe) ──
    globals.mapleader = " ";

    opts = {
      relativenumber = true;
      number = true;
    };

    # ── lazy.nvim (installed by nixvim, configured by LazyVim) ──────────
    plugins.lazy.enable = true;

    # ── Treesitter (nixvim installs grammars; LazyVim configures the plugin) ──
    plugins.treesitter = {
      enable = true;
      nixvimInjections = true;
    };

    # ── LazyVim + extras via lazy.nvim spec ─────────────────────────────
    extraConfigLuaPre = ''
      require("lazy").setup({
        spec = {
          -- LazyVim distribution
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },

          -- LazyVim extras (your previous lazyvim.json extras)
          { import = "lazyvim.plugins.extras.coding.mini-surround" },
          { import = "lazyvim.plugins.extras.editor.neo-tree" },
          { import = "lazyvim.plugins.extras.formatting.prettier" },
          { import = "lazyvim.plugins.extras.lang.typescript.biome" },
          { import = "lazyvim.plugins.extras.lang.ansible" },
          { import = "lazyvim.plugins.extras.lang.json" },
          { import = "lazyvim.plugins.extras.lang.markdown" },
          { import = "lazyvim.plugins.extras.lang.python" },
          { import = "lazyvim.plugins.extras.lang.rust" },
          { import = "lazyvim.plugins.extras.lang.sql" },
          { import = "lazyvim.plugins.extras.lang.terraform" },
          { import = "lazyvim.plugins.extras.lang.toml" },
          { import = "lazyvim.plugins.extras.lang.yaml" },
          { import = "lazyvim.plugins.extras.lang.zig" },

          -- Your custom plugin overrides
          -- Colourscheme
          { "neanias/everforest-nvim" },
          {
            "LazyVim/LazyVim",
            opts = {
              colorscheme = "everforest",
              background = "soft",
            },
          },

          -- All theme plugins available for hot-reloading (lazy-loaded)
          { "ribru17/bamboo.nvim", lazy = true, priority = 1000 },
          { "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 1000 },
          { "sainnhe/everforest", lazy = true, priority = 1000 },
          { "kepano/flexoki-neovim", lazy = true, priority = 1000 },
          { "ellisonleao/gruvbox.nvim", lazy = true, priority = 1000 },
          { "rebelot/kanagawa.nvim", lazy = true, priority = 1000 },
          { "tahayvr/matteblack.nvim", lazy = true, priority = 1000 },
          { "loctvl842/monokai-pro.nvim", lazy = true, priority = 1000 },
          { "shaunsingh/nord.nvim", lazy = true, priority = 1000 },
          { "rose-pine/neovim", name = "rose-pine", lazy = true, priority = 1000 },
          { "folke/tokyonight.nvim", lazy = true, priority = 1000 },

          -- datastar.nvim
          {
            "WillEhrendreich/datastar.nvim",
            ft = { "html" },
            opts = {},
          },

          -- Snacks: show hidden files in picker
          {
            "folke/snacks.nvim",
            opts = {
              picker = {
                hidden = true,
                sources = {
                  files = {
                    hidden = true,
                  },
                },
              },
            },
          },

          -- Snacks: disable animated scrolling
          {
            "folke/snacks.nvim",
            opts = {
              scroll = {
                enabled = false,
              },
            },
          },

          -- Disable LazyVim news alerts
          {
            "LazyVim/LazyVim",
            opts = {
              news = {
                lazyvim = false,
                neovim = false,
              },
            },
          },
        },

        -- Write lockfile to state dir (nix store is read-only)
        lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",

        defaults = {
          lazy = false,
          version = false,
        },

        install = {
          colorscheme = { "tokyonight", "habamax" },
        },

        checker = {
          enabled = true,
          notify = false,
        },

        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
    '';

    # ── Transparency autocmd (runs after LazyVim sets colourscheme) ─────
    extraConfigLuaPost = ''
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          local make_transparent = function(name)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and hl then
              hl.bg = nil
              vim.api.nvim_set_hl(0, name, hl)
            end
          end

          local groups = {
            "Normal", "NormalFloat", "FloatBorder", "Pmenu", "Terminal",
            "EndOfBuffer", "FoldColumn", "Folded", "SignColumn", "LineNr",
            "CursorLineNr", "NormalNC", "WhichKeyFloat", "TelescopeBorder",
            "TelescopeNormal", "TelescopePromptBorder", "TelescopePromptTitle",
            "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeVertSplit",
            "NeoTreeWinSeparator", "NeoTreeEndOfBuffer",
            "NvimTreeNormal", "NvimTreeVertSplit", "NvimTreeEndOfBuffer",
            "NotifyINFOBody", "NotifyERRORBody", "NotifyWARNBody",
            "NotifyTRACEBody", "NotifyDEBUGBody", "NotifyINFOTitle",
            "NotifyERRORTitle", "NotifyWARNTitle", "NotifyTRACETitle",
            "NotifyDEBUGTitle", "NotifyINFOBorder", "NotifyERRORBorder",
            "NotifyWARNBorder", "NotifyTRACEBorder", "NotifyDEBUGBorder",
          }

          for _, name in ipairs(groups) do
            make_transparent(name)
          end
        end,
      })

      -- Apply immediately on first load
      vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
    '';

    # ── Extra packages (LSP binaries, formatters, tools) ────────────────
    extraPackages = with pkgs; [
      # LSP
      lua-language-server
      pyright
      typescript-language-server
      vscode-json-languageserver
      yaml-language-server
      taplo
      marksman
      ansible-language-server
      sqls
      terraform-ls
      rust-analyzer
      zls
      biome
      nil

      # Formatters
      stylua
      black
      prettierd
      nixfmt
      rustfmt
      terraform
      zig
      sqlfluff
      ansible-lint

      # Tools
      ripgrep
      fd
      lazygit
    ];
  };

  # gcc for building native modules, tree-sitter CLI
  home.packages = with pkgs; [
    gcc
    tree-sitter
  ];
}
