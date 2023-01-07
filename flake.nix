{
  description = "Nix Flake template using the 'nixpkgs-unstable' branch and 'flake-utils'";

  inputs = {
    zig.url = "github:mitchellh/zig-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    overlays = [(final: prev: {zigpkgs = inputs.zig.packages.${prev.system};})];
    systems = builtins.attrNames inputs.zig.packages;
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit overlays system;};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            coreutils
            moreutils
            jq
            zigpkgs.master
            alejandra
          ];
        };
      }
    );
}
