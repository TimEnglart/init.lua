{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (import ./base.nix { inherit pkgs; }) nativeBuildInputs buildInputs;

  shell = pkgs.mkShell {
    name = "go";
    hardeningDisable = [ "fortify" ];
    nativeBuildInputs =
      with pkgs;
      [
        # Golang
        go # go
        gopls
        go-tools
        golangci-lint
        delve
        gofumpt
        go-mockery
        # GRPC
        grpcui
        protobuf
        go-protobuf

        # Misc
        jq
        yq-go

        # Static compilation
        #musl
      ]
      ++ nativeBuildInputs;

    shellHook = "\n\n";

    CGO_ENABLED = 1;

    #ldflags = [
    #  "-linkmode external"
    #   "-extldflags '-static -L${pkgs.musl}/lib'"
    #];

    buildInputs =
      with pkgs;
      [
        go
      ]
      ++ buildInputs;

    NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [ stdenv.cc.cc ]);

    NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };
in
shell
