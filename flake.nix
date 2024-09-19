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
            ];
          };
        }
      );

      packages = nixpkgs.lib.genAttrs supportedSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.stdenv.mkDerivation {
            pname = "latex2html";
            version = "2024";
            src = ./.;
            buildInputs = with pkgs; [
              ghostscript
              netpbm
              perl
              poppler_utils
              texliveFull
            ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            configurePhase = ''
              ./configure \
                --prefix="$out" \
                --without-mktexlsr \
                --with-texpath=$out/share/texmf/tex/latex/html
            '';
            postInstall = ''
              for p in $out/bin/{latex2html,pstoimg}; do \
                wrapProgram $p --add-flags '--tmp="''${TMPDIR:-/tmp}"'
              done
            '';
          };
        }
      );
    };
}
