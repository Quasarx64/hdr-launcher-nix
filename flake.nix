{
  description = "HDR Launcher AppImage wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      
      pname = "hdr-launcher";
      version = "0.7.5";

    in {
      packages.${system} = {
        default = self.packages.${system}.hdr-launcher;
        
        hdr-launcher = pkgs.appimageTools.wrapType2 {
          inherit pname version;

          src = pkgs.fetchurl {
            url = "https://github.com/techyCoder81/hdr-launcher-react/releases/download/v${version}/HDRLauncher-${version}.AppImage";
            sha256 = "sha256-ZXp/7U/XkK8ZPRfGXTJ0VvBRe9EGlZNNGTB71kJEjw0=";
          };

          extraPkgs = pkgs: with pkgs; [
            libsecret
            libappindicator-gtk3
            gtk3
            glib
          ];

          # Install desktop file and icon
          extraInstallCommands = 
            let
              appimageContents = pkgs.appimageTools.extractType2 { inherit pname version; src = self.packages.${system}.hdr-launcher.src; };
            in ''
              # desktop file
              install -m 444 -D ${appimageContents}/hdr-launcher.desktop $out/share/applications/${pname}.desktop
              
              # Install icon
              if [ -f ${appimageContents}/hdr-launcher.png ]; then
                install -m 444 -D ${appimageContents}/hdr-launcher.png $out/share/icons/hicolor/512x512/apps/${pname}.png
              fi
              
              # Fix desktop file paths
              substituteInPlace $out/share/applications/${pname}.desktop \
                --replace 'Exec=AppRun' 'Exec=${pname}' || true
            '';

          meta = with pkgs.lib; {
            description = "HDR Launcher for HewDraw Remix";
            homepage = "https://github.com/techyCoder81/hdr-launcher-react";
            license = licenses.mit;
            platforms = [ "x86_64-linux" ];
            mainProgram = pname;
          };
        };
      };

      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_20
          yarn
          python3
          electron_28
        ];

        shellHook = ''
          export ELECTRON_SKIP_BINARY_DOWNLOAD=1
          echo "HDR Launcher dev shell - run 'yarn install && yarn start'"
        '';
      };
    };
}
