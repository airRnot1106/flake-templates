{
  description = "Collection of Nix Flakes templates";

  inputs = {
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.git-hooks.flakeModule
        inputs.devenv.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = import inputs.systems;

      perSystem =
        {
          config,
          lib,
          pkgs,
          system,
          ...
        }:
        {
          devenv.shells.default = {
            packages = with pkgs; [
              git
            ];
            containers = lib.mkForce { };
            languages.nix.enable = true;
            enterShell = ''
              ${config.pre-commit.installationScript}
            '';
          };

          pre-commit = import ./nix/pre-commit { inherit config; };
          treefmt = import ./nix/treefmt;
        };

      flake = {
        templates = {
          bun = {
            path = ./templates/bun;
            description = "Bun project template";
          };
          deno = {
            path = ./templates/deno;
            description = "Deno project template";
          };
          gleam = {
            path = ./templates/gleam;
            description = "Gleam project template";
          };
          nodejs = {
            path = ./templates/nodejs;
            description = "Node.js project template";
          };
          rust = {
            path = ./templates/rust;
            description = "Rust project template";
          };
        };
      };
    };
}
