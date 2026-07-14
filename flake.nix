{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    zmk-nix,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "chamomile";
        src = nixpkgs.lib.sourceFilesBySuffices self [
          ".board"
          ".cmake"
          ".conf"
          ".defconfig"
          "_defconfig"
          ".dts"
          ".dtsi"
          ".json"
          ".keymap"
          ".overlay"
          ".shield"
          ".yml"
          ".yaml"
          ".h"
        ];
        board = "xiao_ble";
        shield = "chamomile_%PART%";
        zephyrDepsHash = "sha256-F03oJNHWmHlpFc1JHyvqX02WL+Pg6ZcNWpCaiDfJANA=";
        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override {inherit firmware;};
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        inputsFrom = [zmk-nix.devShells.${system}.default.override];

        packages = with pkgs; [
          evtest
          minicom
        ];
      };
    });
  };
}
