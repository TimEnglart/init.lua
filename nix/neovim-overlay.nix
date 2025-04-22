# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: _:
with final.pkgs.lib;
let
  pkgs = final;

  # Use this to create a plugin from a flake input
  # deadnix: skip
  mkNvimPlugin =
    src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    # plugins from nixpkgs go in here.
    # https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=vimPlugins
    # nvim-treesitter
    nvim-treesitter.withAllGrammars
    luasnip # snippets | https://github.com/l3mon4d3/luasnip/
    # nvim-cmp (autocompletion) and extensions
    nvim-cmp # https://github.com/hrsh7th/nvim-cmp
    cmp_luasnip # snippets autocompletion extension for nvim-cmp | https://github.com/saadparwaiz1/cmp_luasnip/
    lspkind-nvim # vscode-like LSP pictograms | https://github.com/onsails/lspkind.nvim/
    cmp-nvim-lsp # LSP as completion source | https://github.com/hrsh7th/cmp-nvim-lsp/
    cmp-nvim-lsp-signature-help # https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/
    cmp-buffer # current buffer as completion source | https://github.com/hrsh7th/cmp-buffer/
    cmp-path # file paths as completion source | https://github.com/hrsh7th/cmp-path/
    cmp-nvim-lua # neovim lua API as completion source | https://github.com/hrsh7th/cmp-nvim-lua/
    cmp-cmdline # cmp command line suggestions
    cmp-cmdline-history # cmp command line history suggestions
    friendly-snippets
    copilot-cmp
    # ^ nvim-cmp extensions
    # git integration plugins
    diffview-nvim # https://github.com/sindrets/diffview.nvim/
    neogit # https://github.com/TimUntersberger/neogit/
    gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim/
    vim-fugitive # https://github.com/tpope/vim-fugitive/
    # ^ git integration plugins
    # telescope and extensions
    telescope-nvim # https://github.com/nvim-telescope/telescope.nvim/
    telescope-fzy-native-nvim # https://github.com/nvim-telescope/telescope-fzy-native.nvim
    # telescope-smart-history-nvim # https://github.com/nvim-telescope/telescope-smart-history.nvim
    # ^ telescope and extensions
    # UI
    lualine-nvim # Status line | https://github.com/nvim-lualine/lualine.nvim/
    nvim-navic # Add LSP location to lualine | https://github.com/SmiteshP/nvim-navic
    statuscol-nvim # Status column | https://github.com/luukvbaal/statuscol.nvim/
    nvim-treesitter-context # nvim-treesitter-context
    # ^ UI
    # language support
    nvim-lspconfig
    # mason-nvim
    # mason-lspconfig-nvim
    # mason-nvim-dap-nvim
    nvim-dap
    nvim-dap-ui
    nvim-dap-go
    fidget-nvim
    lazydev-nvim
    # ^ language support
    # linting
    nvim-lint
    # ^ linting
    # formatting
    conform-nvim
    # ^ formatting
    # navigation/editing enhancement plugins
    vim-unimpaired # predefined ] and [ navigation keymaps | https://github.com/tpope/vim-unimpaired/
    eyeliner-nvim # Highlights unique characters for f/F and t/T motions | https://github.com/jinh0/eyeliner.nvim
    nvim-surround # https://github.com/kylechui/nvim-surround/
    nvim-treesitter-textobjects # https://github.com/nvim-treesitter/nvim-treesitter-textobjects/
    nvim-ts-context-commentstring # https://github.com/joosepalviste/nvim-ts-context-commentstring/
    # ^ navigation/editing enhancement plugins
    # Useful utilities
    nvim-unception # Prevent nested neovim sessions | nvim-unception
    # ^ Useful utilities
    # libraries that other plugins depend on
    sqlite-lua
    plenary-nvim
    nvim-web-devicons
    mini-icons
    vim-repeat
    # ^ libraries that other plugins depend on
    # bleeding-edge plugins from flake inputs
    # (mkNvimPlugin inputs.wf-nvim "wf.nvim") # (example) keymap hints | https://github.com/Cassin01/wf.nvim
    # ^ bleeding-edge plugins from flake inputs
    which-key-nvim
    neoconf-nvim
    lazy-nvim
    nvim-nio
    vim-fugitive
    vim-rhubarb
    vim-sleuth
    zen-mode-nvim
    undotree
    cloak-nvim
    copilot-lua
    CopilotChat-nvim
    comment-nvim
    harpoon2
    render-markdown-nvim
    # Theme
    rose-pine
    onedark-nvim
    tokyonight-nvim
  ];

  # Language Servers, etc
  extraPackages = with pkgs; [
    # Arduino
    arduino-language-server
    # Bash
    bash-language-server
    # C
    llvmPackages_latest.clang
    # Cmake
    cmake-language-server
    # C#
    csharp-ls
    # Dart
    # dart
    # Deno
    # deno
    # Docker Compose
    docker-compose-language-service
    # Dockerfile
    dockerfile-language-server-nodejs
    # Elixir
    # beamMinimal27Packages.elixir-ls
    # Erlang
    erlang-language-platform
    # Fish
    fish-lsp
    # GitHub Actions
    # gh-actions-language-server
    # Gitlab CI
    gitlab-ci-ls
    # Gleam
    # gleam
    # Golang
    gopls
    delve
    # GraphQL
    # graphql-language-service-cli
    # HTML
    vscode-langservers-extracted
    # HTMX
    htmx-lsp2
    # Jinja
    jinja-lsp
    # JSON
    # vscode-langservers-extracted
    # Kotlin
    kotlin-language-server
    # Lua
    lua-language-server
    stylua
    # Markdown Oxide
    markdown-oxide
    # Nix
    nil # nix LSP
    nixfmt-rfc-style
    # Nomad
    # nomad-lsp
    # Python
    pyright
    # Salt
    # salt-ls
    # Rust
    rust-analyzer
    # SQL
    sqls
    # Systemd
    systemd-language-server
    # Terraform
    terraform-lsp
    # YAML
    yaml-language-server
    yamlfmt
    yq-go
    # Zig
    zls

    # Requirements for plugins
    # Treesitter
    ripgrep
    fd
    gcc
    # Mason
    # unzip
    # wget
    # curl
    # gzip
    # gnutar
    # bash
  ];
in
{
  # This is the neovim derivation
  # returned by the overlay
  tnvim = mkNeovim {
    plugins = all-plugins;
    appName = "tnvim";
    inherit extraPackages;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json { plugins = all-plugins; };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
