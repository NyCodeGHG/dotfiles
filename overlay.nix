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

  victoriametrics = prev.victoriametrics.overrideAttrs (prev: {
    patches = (prev.patches or [ ]) ++ [
      (final.fetchpatch {
        url = "https://github.com/victoriaMetrics/victoriaMetrics/commit/150004c2ab.patch";
        revert = true;
        includes = [
          "lib/encoding/encoding.go"
          "lib/encoding/encoding_test.go"
        ];
        hash = "sha256-gIGEd0A7iIuPZC3j7U+1iKHcrKFJZYptBC7ird1DOjk=";
      })
    ];
  });
}
