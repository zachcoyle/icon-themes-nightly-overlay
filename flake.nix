{
  description = "nightly overlay for icon-themes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
      ];

      systems = import inputs.systems;

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        devshells.default = {
          name = "icon-themes-nightly-overlay";
          packages = with pkgs; [
            npins
          ];
        };
      };
      flake = {
        overlays.default = final: prev: let
          pins = import ./npins;
          icon-themes = builtins.attrNames pins;
        in (builtins.listToAttrs map (name: {
            inherit name;
            value = prev.${name}.overrideAttrs {
              src = pins.${name};
              version = "nightly-${pins.${name}.revision}";
            };
          })
          icon-themes);
      };
    };
}
