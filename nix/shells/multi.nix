{
  pkgs ? import <nixpkgs> { },
  shells ? [ ],
  shellOpts ? { },
}:
let
  inherit (pkgs.lib.strings) concatMapStrings;
  inherit (import ./base.nix { inherit pkgs; }) nativeBuildInputs buildInputs;

  mappedShells = map (
    x:
    (
      let
        inherit (import ./.+ "${x}" { inherit pkgs; }) nativeBuildInputs buildInputs shellHook;
      in
      {
        inherit nativeBuildInputs buildInputs shellHook;
      }
    )
  ) shells;

  shell = pkgs.mkShell (
    {
      name = concatMapStrings (x: x + "+") (map (x: x.name) mappedShells);
      nativeBuildInputs = nativeBuildInputs ++ (map (x: x.nativeBuildInputs) mappedShells);
      shellHook = concatMapStrings (x: x + "\n") (map (x: x.shellHook) mappedShells);
      buildInputs = buildInputs ++ (map (x: x.buildInputs) mappedShells);
    }
    // shellOpts
  );
in
shell
