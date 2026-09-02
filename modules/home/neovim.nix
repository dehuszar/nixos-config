# modules/home/neovim.nix
#
# Neovim is installed as a plain package. The full config tree (LazyVim) is
# managed via the out-of-store symlink below; using programs.neovim would
# conflict by writing its own .config/nvim/init.lua.
{ pkgs, config, ... }:
{
  home.packages = [ pkgs.neovim pkgs.tree-sitter pkgs.gcc ];

  # Recursive directory link: ~/.config/nvim is a real directory with per-file
  # symlinks into the Nix store. lazy.nvim can write lazy-lock.json into the
  # real directory alongside the symlinked config files.
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
