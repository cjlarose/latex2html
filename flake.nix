{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
  }; 

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    in {
      devShells = nixpkgs.lib.genAttrs supportedSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              ghostscript
              netpbm
              perl
              poppler_utils
              texliveFull
              # texlive.combined.scheme-basic # doesn't include preview.sty
              # (texliveBasic.withPackages (ps: with ps; [ preview ])) # can't find preview.sty still
              # texlive.combined.scheme-medium # fails on darwin
            ];
          };
        }
      );
    };
}
