{ pkgs ? import <nixpkgs> { }, }:
let
  lib = pkgs.lib;

  shell = pkgs.mkShell {
    name = "go";
    hardeningDisable = [ "fortify" ];
    nativeBuildInputs = with pkgs; [
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

      # vscode # WSL Handles this
      # neovim

      # Misc
      jq
      yq-go
      git
      direnv

      # Custom nvim
      # tnvim
      # Static compilation
      #musl
    ];

    shellHook = "\n\n";

    CGO_ENABLED = 1;

    #ldflags = [
    #  "-linkmode external"
    #   "-extldflags '-static -L${pkgs.musl}/lib'"
    #];

    buildInputs = with pkgs; [ stdenv go glibc gcc libcap ];

    NIX_LD_LIBRARY_PATH =
      pkgs.lib.makeLibraryPath (with pkgs; [ stdenv.cc.cc ]);

    NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };
in shell
