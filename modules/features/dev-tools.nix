{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.dev-tools = { pkgs, ... }: {
    environment.variables = {
      MANPAGER = "nvim -c 'Man!' -";
      MANWIDTH = "100";
    };

    environment.systemPackages = with pkgs; [

      # Languages
      odin
      
      cargo
      rustc
      clippy
      
      go
      bun
      (python3.withPackages (ps: [ ps.debugpy ]))
      zig
      clang
      sqlite

      # LSP servers
      nixd
      typescript-language-server
      tailwindcss-language-server
      vscode-langservers-extracted
      emmet-language-server
      lua-language-server
      gopls
      golangci-lint
      rust-analyzer
      lldb
      delve
      basedpyright
      ruff
      clang-tools
      eslint
      svelte-language-server
      astro-language-server
      vue-language-server
      dockerfile-language-server
      docker-compose-language-service
      yaml-language-server
      taplo
      bash-language-server
      cmake-language-server
      ols
      zls

      # Formatters
      alejandra
      nixfmt-rfc-style
      prettier
      prettierd
      stylua
      shfmt
      yamlfmt
      black
      rustfmt

      # Build / treesitter deps
      gcc
      gnumake
      nodejs

      # Dev tools
      ripgrep
      fd
      git
      lazygit
      tree-sitter
      tmux
      curl
      fzf
      direnv
      git-lfs
      nix-output-monitor
      fastfetch
      man-pages
      ollama

      # Keyboards
      qmk
    ];
  };
}
