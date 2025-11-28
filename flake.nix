{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
      ];
      systems = [ 
        "x86_64-linux" 
        "aarch64-linux" 
        "aarch64-darwin" 
        "x86_64-darwin" 
      ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "blog";
          src = ./.;
          buildInputs = with pkgs; [ 
            git 
            hugo 
          ];
          buildPhase = ''
            mkdir $out
            hugo
            cp -r ./public $out
          '';
        };
        devshells.default = {
            commands = [
              {
                help = "run dev server";
                name = "start-dev";
                command = "hugo server -D";
              }
            ];
            packages = with pkgs; [
              git
              hugo
            ];
          };
      };
    };
}
