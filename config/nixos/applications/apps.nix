{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.uwumarie.profiles.apps = lib.mkEnableOption "Standard apps";
  config = lib.mkIf config.uwumarie.profiles.apps {
    environment.systemPackages =
      (with pkgs; [
        # Graphical
        qpwgraph
        vlc
        (lib.hiPrio (
          pkgs.runCommand "vlc-desktop-fix" { } ''
            mkdir -p $out/share/applications
            cp ${pkgs.vlc}/share/applications/vlc.desktop $out/share/applications
            sed -i '/X-KDE-Protocols/ s/,smb//' $out/share/applications/vlc.desktop
          ''
        ))
        mpv
        gimp3
        libreoffice-qt6-fresh
        signal-desktop
        vscodium
        github-cli
      ])
      ++ (with pkgs.kdePackages; [
        isoimagewriter
        partitionmanager
        filelight
        sddm-kcm
        krdc
        kcolorchooser
      ])

      ++ (with pkgs; [
        # Command line
        ffmpeg-full
        openssl
        bashInteractive
        p7zip
        fend
        lm_sensors
        man-pages
        man-pages-posix
        smartmontools
        jq
        yq-go
        wl-clipboard-rs
        config.boot.kernelPackages.cpupower
        age
        android-tools
        zip
        unzip
        asciinema
        qemu
        distrobox
        whois
        comma

        # Programming
        python3
        rust-analyzer
        nixfmt
        gopls
        editorconfig-core-c
        clojure-lsp
        nixd
        nix-diff
        lix-diff
        nix-tree
        lixPackageSets.latest.nixpkgs-review
        nix-output-monitor
        gdb
        clojure
        leiningen
        tokei
        clang-tools

        # Networking
        wireguard-tools
        sshfs
        iperf3
        magic-wormhole
        yt-dlp
        restic
        rclone

        # Browsers
        (chromium.override { enableWideVine = true; })
      ]);

    programs.direnv = {
      enable = true;
      nix-direnv.package = pkgs.lixPackageSets.latest.nix-direnv;
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    };

    programs.firefox.enable = true;
    programs.thunderbird.enable = true;
  };
}
