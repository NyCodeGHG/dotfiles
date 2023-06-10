{ stdenvNoCC, imagemagick, symlinkJoin, fetchurl }:
let
  mkBackground = { name, url, sha256 }: stdenvNoCC.mkDerivation {
    inherit name;
    src = fetchurl {
      inherit url sha256;
    };

    dontUnpack = true;
    dontFixup = true;

    buildPhase = ''
      mkdir -p $out
      ${imagemagick}/bin/magick $src -resize 1920x1080 -quality 50 -strip $out/${name}.webp
    '';
  };
  backgrounds = [
    (mkBackground {
      name = "anime-girl-city-street";
      url = "https://images2.alphacoders.com/102/1028709.jpg";
      sha256 = "1ip146g1ncbqpv39nmk270y3xi7khqavqhqzf9pvrgnbjpipjng3";
    })
    (mkBackground {
      name = "cat-ear-girl";
      url = "https://images5.alphacoders.com/131/1316292.jpeg";
      sha256 = "1c4jma1nc7b1ara9zkfx0qv0a61r5rav5a1zg242z8rvqcjd4yjf";
    })
  ];
in
symlinkJoin {
  name = "backgrounds";
  paths = backgrounds;
}
