{
  description = "Tim's NeoVim Derivation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add bleeding-edge plugins here.
    # They can be updated with `nix flake update` (make sure to commit the generated flake.lock)
    # wf-nvim = {
    #   url = "github:Cassin01/wf.nvim";
    #   flake = false;
    # };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      gen-luarc,
      treefmt-nix,
      pre-commit-hooks,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # This is where the Neovim derivation is built.
      neovim-overlay = import ./nix/neovim-overlay.nix { inherit inputs; };
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        importPkgs =
          attrs:
          import nixpkgs (
            {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                # Import the overlay, so that the final Neovim derivation(s) can be accessed via pkgs.<nvim-pkg>
                neovim-overlay
                # This adds a function can be used to generate a .luarc.json
                # containing the Neovim API all plugins in the workspace directory.
                # The generated file can be symlinked in the devShell's shellHook.
                gen-luarc.overlays.default
              ];
            }
            // attrs
          );
        pkgs = importPkgs { };
        # Eval the treefmt modules from ./treefmt.nix
        treefmtEval = treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} (_: {
          # Used to find the project root
          projectRootFile = "flake.nix";
          programs = {
            nixfmt = {
              enable = true;
            };
            stylua.enable = true;
          };
        });
      in
      {
        packages = rec {
          default = nvim;
          nvim = pkgs.tnvim;
        };
        devShells = {
          default = pkgs.mkShell {
            name = "nvim-devShell";
            buildInputs =
              with pkgs;
              [
                # Tools for Lua and Nix development, useful for editing files in this repo
                lua-language-server
                nil
                nixfmt-rfc-style
                stylua
                luajitPackages.luacheck
                tnvim
              ]
              ++ self.checks.${system}.pre-commit-check.enabledPackages;
            shellHook =
              ''
                # symlink the .luarc.json generated in the overlay
                ln -fs ${pkgs.nvim-luarc-json} .luarc.json
              ''
              + self.checks.${system}.pre-commit-check.shellHook;

          };
          go = import ./nix/shells/go.nix { pkgs = importPkgs { config.allowUnfree = true; }; };
        };
        formatter = treefmtEval.config.build.wrapper;

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # Nix
              nixfmt-rfc-style.enable = true;
              flake-checker.enable = true;
              statix.enable = true;
              deadnix.enable = true;
              # Lua
              stylua.enable = true;
              selene.enable = true;
            };
          };
        };
      }
    )
    // {
      # You can add this overlay to your NixOS configuration
      overlays.default = neovim-overlay;
    };
}
