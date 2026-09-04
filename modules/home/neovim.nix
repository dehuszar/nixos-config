# modules/home/neovim.nix
#
# Neovim configuration powered by nixvim.
# Replaces the previous LazyVim + lazy.nvim setup.
{ pkgs, config, lib, inputs, ... }:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Use the same nixpkgs as the rest of the system (suppresses eval warning)
    nixpkgs.source = pkgs.path;

    # Leader key
    globals.mapleader = " ";

    # Vim options — mirror your previous LazyVim defaults
    opts = {
      relativenumber = true;
      number = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      smartindent = true;
      wrap = false;
      swapfile = false;
      smartcase = true;
      ignorecase = true;
      signcolumn = "yes";
      cursorline = true;
      updatetime = 300;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      undofile = true;
    };

    # ── Colourscheme ──────────────────────────────────────────────
    colorscheme = "everforest";
    colorschemes.everforest = {
      enable = true;
      settings = {
        background = "soft";
      };
    };

    # ── Treesitter ────────────────────────────────────────────────
    plugins.treesitter = {
      enable = true;
      nixvimInjections = true;
    };

    # ── LSP servers ───────────────────────────────────────────────
    lsp.servers = {
      # Core language servers for your LazyVim extras
      lua_ls.enable = true;
      pyright.enable = true;
      ts_ls.enable = true;
      jsonls.enable = true;
      yamlls.enable = true;
      taplo.enable = true;              # TOML
      marksman.enable = true;           # Markdown
      ansiblels.enable = true;          # Ansible
      sqls.enable = true;               # SQL
      terraformls.enable = true;        # Terraform
      rust_analyzer.enable = true;      # Rust
      zls.enable = true;                # Zig
      biome.enable = true;              # Biome (TypeScript/JS)
    };

    # ── Formatting via conform.nvim ───────────────────────────────
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          python = [ "black" ];
          terraform = [ "terraform_fmt" ];
          javascript = [ "biome" ];
          typescript = [ "biome" ];
          javascriptreact = [ "biome" ];
          typescriptreact = [ "biome" ];
          json = [ "biome" ];
          yaml = [ "prettierd" ];
          markdown = [ "prettierd" ];
          html = [ "prettierd" ];
          css = [ "prettierd" ];
          nix = [ "nixfmt" ];
          lua = [ "stylua" ];
          rust = [ "rustfmt" ];
          zig = [ "zigfmt" ];
          sql = [ "sqlfluff" ];
          ansible = [ "ansible-lint" ];
          "_" = [ "trim_whitespace" ];
        };
        format_on_save = {
          timeoutMs = 500;
          lspFormat = "fallback";
        };
      };
    };

    # ── Plugins (mapping your LazyVim extras + custom plugins) ────
    plugins = {
      # Editor / file tree
      neo-tree.enable = true;

      # Status line
      lualine.enable = true;

      # Buffer line
      bufferline.enable = true;

      # Fuzzy finder (lazyvim used telescope under the hood)
      telescope.enable = true;

      # Keybindings help
      which-key.enable = true;

      # Mini suite — replaces lazyvim.plugins.extras.coding.mini-surround
      mini = {
        enable = true;
      };

      # Git
      gitsigns.enable = true;

      # Indent guides
      indent-blankline.enable = true;

      # Auto-completion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' })";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          };
        };
      };
      luasnip.enable = true;

      # Trouble (diagnostics list)
      trouble.enable = true;

      # Flash (enhanced motion)
      flash.enable = true;

      # Dressing (better vim.ui)
      dressing.enable = true;

      # Noice (better cmdline/messages)
      noice.enable = true;

      # Notifications
      notify = {
        enable = true;
        settings.backgroundColour = "#00000000";
      };

      # Todo comments
      todo-comments.enable = true;

      # Vim illuminate (highlight word under cursor)
      illuminate.enable = true;

      # Session persistence (replaces LazyVim's persistence)
      persistence.enable = true;

      # Spectre (search & replace across project)
      spectre.enable = true;

      # Commenting
      comment.enable = true;

      # Treesitter autotag
      ts-autotag.enable = true;

      # Treesitter context comment string
      ts-context-commentstring.enable = true;

      # Dashboard
      dashboard.enable = true;

      # Snacks — configure hidden files + disable animated scrolling
      snacks = {
        enable = true;
        settings = {
          picker = {
            sources = {
              files = {
                hidden = true;
              };
            };
          };
          scroll = {
            enabled = false;
          };
        };
      };
    };

    # ── Extra plugins not covered by nixvim built-ins ─────────────
    # TODO: Re-enable once we have the correct commit hash for datastar.nvim.
    # The fetchFromGitHub call below 404'd — check the repo's actual branch/rev.
    # extraPlugins = [
    #   (pkgs.vimUtils.buildVimPlugin {
    #     pname = "datastar-nvim";
    #     version = "unstable-2025-08-31";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "WillEhrendreich";
    #       repo = "datastar.nvim";
    #       rev = "<commit-hash>";  # get from: https://github.com/WillEhrendreich/datastar.nvim/commits/main
    #       hash = "sha256-...";    # nix will tell you the correct hash on first build
    #     };
    #   })
    # ];

    # ── Extra packages (LSP binaries, formatters, tools) ──────────
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
    ];

    # ── Extra Lua config ────────────────────────────────────────────
    extraConfigLuaPost = ''
      -- ── Transparency ──────────────────────────────────────────────
      -- Run on every colourscheme change so highlights stay transparent.
      local function make_transparent(name)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        if ok and hl then
          hl.bg = nil
          vim.api.nvim_set_hl(0, name, hl)
        end
      end

      local transparent_groups = {
        -- Core
        "Normal",
        "NormalFloat",
        "FloatBorder",
        "Pmenu",
        "Terminal",
        "EndOfBuffer",
        "FoldColumn",
        "Folded",
        "SignColumn",
        "LineNr",
        "CursorLineNr",
        "NormalNC",
        "WhichKeyFloat",
        "TelescopeBorder",
        "TelescopeNormal",
        "TelescopePromptBorder",
        "TelescopePromptTitle",
        -- Neo-tree
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeVertSplit",
        "NeoTreeWinSeparator",
        "NeoTreeEndOfBuffer",
        -- nvim-tree
        "NvimTreeNormal",
        "NvimTreeVertSplit",
        "NvimTreeEndOfBuffer",
        -- Notify
        "NotifyINFOBody",
        "NotifyERRORBody",
        "NotifyWARNBody",
        "NotifyTRACEBody",
        "NotifyDEBUGBody",
        "NotifyINFOTitle",
        "NotifyERRORTitle",
        "NotifyWARNTitle",
        "NotifyTRACETitle",
        "NotifyDEBUGTitle",
        "NotifyINFOBorder",
        "NotifyERRORBorder",
        "NotifyWARNBorder",
        "NotifyTRACEBorder",
        "NotifyDEBUGBorder",
      }

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          for _, name in ipairs(transparent_groups) do
            make_transparent(name)
          end
        end,
      })

      -- Apply immediately on first load
      for _, name in ipairs(transparent_groups) do
        make_transparent(name)
      end
    '';
  };

  # Keep gcc and tree-sitter CLI for building native modules
  home.packages = with pkgs; [
    gcc
    tree-sitter
  ];
}
