{ pkgs ? import <nixpkgs> { }, }:
let
  lib = pkgs.lib;

  scripts = let
    git = lib.getExe pkgs.git;
    go = lib.getExe pkgs.go_1_22;
    vault = lib.getExe pkgs.vault;
    gofumpt = lib.getExe pkgs.gofumpt;
    golangci-lint = lib.getExe pkgs.golangci-lint;
  in [
    (pkgs.writeShellScriptBin "rebase" ''
      
              local COMMITS_TO_REBASE="''${1:-1}"
              local HEAD_OFFSET="$((COMMITS_TO_REBASE + 1))"
              local REBASE_COMMIT_MESSAGE="$(git log -n $HEAD_OFFSET --pretty=%B)"
      
              #echo "$COMMITS_TO_REBASE"
              #echo "$HEAD_OFFSET"
              #echo "$REBASE_COMMIT_MESSAGE"
              ${git} reset --soft "HEAD~''${HEAD_OFFSET}"
              ${git} commit --edit -m "$REBASE_COMMIT_MESSAGE"
    '')

    (pkgs.writeShellScriptBin "vaultlogin" ''
      
              . "$BASE_PATH/conf/vault-tsv-provision/login.sh" && ${vault} login -method=oidc && . "$BASE_PATH/conf/nomad-jobs/nomad-setup-env.sh"
    '')

    (pkgs.writeShellScriptBin "goupdate" ''
      
                      ${go} get -u ''${1:-.}/... && ${go} mod tidy
    '')

    (pkgs.writeShellScriptBin "lint" ''
      
              path="''${1:-.}"
              shift
              ${git} -C "$BASE_PATH/conf/jenkins-jcu-lib" pull && ${gofumpt} -w $path && ${golangci-lint} run -c "$BASE_PATH/conf/jenkins-jcu-lib/resources/golang/golangci.yml" $path/... $@
    '')
  ];

  shell = pkgs.mkShell {
    name = "go";
    hardeningDisable = [ "fortify" ];
    nativeBuildInputs = with pkgs;
      [
        # Golang
        go_1_22 # go
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

        # Hashicorp
        vault
        nomad
        consul

        # Database Drivers
        unixODBCDrivers.mariadb
        unixODBCDrivers.msodbcsql17
        unixODBCDrivers.msodbcsql18
        #unixODBCDrivers.mysql
        unixODBCDrivers.psql
        unixODBCDrivers.sqlite

        # Editors
        (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [
          "go"
          "nixidea"
        ])
        # vscode # WSL Handles this
        # neovim

        # Misc
        jq
        yq-go
        git
        direnv

        # Custom nvim
        tnvim
        # Static compilation
        #musl
      ] ++ scripts;

    shellHook = "\n\n";

    CGO_ENABLED = 1;

    #ldflags = [
    #  "-linkmode external"
    #   "-extldflags '-static -L${pkgs.musl}/lib'"
    #];

    buildInputs = with pkgs; [ stdenv go_1_22 glibc gcc libcap ];

    NIX_LD_LIBRARY_PATH =
      pkgs.lib.makeLibraryPath (with pkgs; [ stdenv.cc.cc ]);

    NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };
in shell
