{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (import ./base.nix { inherit pkgs; }) nativeBuildInputs buildInputs;

  shell = pkgs.mkShell {
    name = "lua";
    hardeningDisable = [ "fortify" ];
    nativeBuildInputs =
      with pkgs;
      [
        lua-language-server
        stylua
        luajitPackages.luacheck
        selene
        lua
        luajit
      ]
      ++ nativeBuildInputs;

    shellHook = ''
      # symlink the .luarc.json generated in the overlay
      ln -fs ${pkgs.nvim-luarc-json} .luarc.json
    '';

    buildInputs =
      with pkgs;
      [
        lua
        luajit
      ]
      ++ buildInputs;
  };
in
shell
