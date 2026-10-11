final: prev: {
  discord = (
    prev.discord.override {
      # withOpenASAR = true;
      withVencord = true;
    }
  );

  kdePackages = prev.kdePackages.overrideScope (
    kdeFinal: kdePrev: {
      spectacle = kdePrev.spectacle.override {
        tesseractLanguages = [
          "eng"
          "deu"
        ];
      };
      inherit (final) kiot;
    }
  );

  proxyt = prev.proxyt.overrideAttrs (prev: {
    patches = (prev.patches or [ ]) ++ [
      ./patches/0001-don-t-error-on-missing-home-directory.patch
    ];
  });
}
