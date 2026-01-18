{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (import ./base.nix { inherit pkgs; }) nativeBuildInputs buildInputs;

  shell = pkgs.mkShell {
    name = "nix";
    nativeBuildInputs =
      with pkgs;
      [
        nil
        nixfmt-rfc-style
        flake-checker
        statix
        deadnix
      ]
      ++ nativeBuildInputs;

    shellHook = "";

    inherit buildInputs;
  };
in
shell
