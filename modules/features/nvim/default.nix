{ self, inputs, ... }: {
  flake = {
    nixosModules.nvim =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        options.programs.nvim.profile = lib.mkOption {
          type = lib.types.enum [
            "full"
            "minimal"
          ];
          default = "full";
          description = "Which nvim config to use (full LazyVim or minimal lazy.nvim).";
        };

        config.environment.systemPackages = with pkgs; [ neovim ];
      };

    homeManagerModules.nvim =
      {
        config,
        pkgs,
        lib,
        systemTheme,
        nvimProfile,
        ...
      }:
      let
        colorschemes = {
          nord = {
            repo = "shaunsingh/nord.nvim";
            module = "nord";
            priority = 1000;
            colorscheme = "nord";
            chad = "nord";
          };
          catppuccin-mocha = {
            repo = "catppuccin/nvim";
            module = "catppuccin";
            name = "catppuccin";
            priority = 1000;
            colorscheme = "catppuccin-mocha";
            chad = "catppuccin";
          };
          tokyo-night = {
            repo = "folke/tokyonight.nvim";
            module = "tokyonight";
            opts = {
              style = "night";
            };
            colorscheme = "tokyonight";
            chad = "tokyonight";
          };
          rose-pine = {
            repo = "rose-pine/neovim";
            module = "rose-pine";
            name = "rose-pine";
            priority = 1000;
            colorscheme = "rose-pine";
            chad = "rosepine";
          };
          minimalist = {
            repo = "nendix/zen.nvim";
            module = "zen";
            priority = 1000;
            opts = {
              variant = "dark";
              transparent = true;
            };
            colorscheme = "zen";
            chad = "";
          };
        };
        selected = colorschemes.${systemTheme} or colorschemes.nord;
        toLua =
          value:
          if builtins.isString value then
            "\"${value}\""
          else if builtins.isBool value then
            (if value then "true" else "false")
          else if builtins.isInt value then
            toString value
          else if builtins.isAttrs value then
            "{ " + lib.concatStringsSep ", " (lib.mapAttrsToList (k: v: "${k} = ${toLua v}") value) + " }"
          else
            abort "unsupported value for nvim colorscheme opts";
        renderPlugin =
          c: extra:
          let
            parts = [
              ''"${c.repo}"''
            ]
            ++ lib.optional (c ? name) ''name = "${c.name}"''
            ++ lib.optional (c ? priority) "priority = ${toString c.priority}"
            ++ lib.optional (c ? opts) "opts = ${toLua c.opts}"
            ++ extra;
          in
          "{ ${lib.concatStringsSep ", " parts} }";
        colorschemeLua =
          if nvimProfile == "full" then
            ''
              return "${selected.chad}"
            ''
          else
            let
              setupLua =
                "local ok, mod = pcall(require, \"${selected.module}\"); "
                + "if ok and type(mod.setup) == \"function\" then mod.setup(opts) end; "
                + "vim.cmd.colorscheme(\"${selected.colorscheme}\")";
            in
            ''
              return {
                ${renderPlugin selected [ "config = function(_, opts) ${setupLua} end" ]},
              }
            '';
        active = if nvimProfile == "minimal" then ./config-min else ./config;
        activePath =
          "/home/grae/nixos/modules/features/nvim"
          + (if nvimProfile == "minimal" then "/config-min" else "/config");
        listFiles =
          dir:
          let
            entries = builtins.readDir dir;
          in
          lib.concatLists (
            lib.mapAttrsToList (
              name: type:
              if type == "directory" then
                map (f: "${name}/${f}") (listFiles "${toString dir}/${name}")
              else if type == "regular" then
                [ name ]
              else
                [ ]
            ) entries
          );
        configFiles = builtins.listToAttrs (
          map (f: {
            name = "nvim/${f}";
            value.source = config.lib.file.mkOutOfStoreSymlink "${activePath}/${f}";
            value.recursive = true; 
	  }) (listFiles active)
        );
      in
      {
        home.packages = with pkgs; [ neovim ];
        home.sessionVariables.EDITOR = "nvim";

        xdg.configFile =
          if nvimProfile != "full" then
            configFiles
            // {
              "nvim/lua/plugins/colorscheme.lua" = {
                force = true;
                text = colorschemeLua;
              };
            }
          else
            configFiles
            // {
              "nvim/lua/configs/colorscheme.lua" = {
                force = true;
                text = colorschemeLua;
              };
            };
      };
  };
}
