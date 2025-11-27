{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        buildInputs = with pkgs; [
          typst gnumake xdg-utils
        ];
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            inherit buildInputs;
          };
      }
    );
}
