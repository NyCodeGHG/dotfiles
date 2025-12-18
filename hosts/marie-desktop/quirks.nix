{
  boot.extraModprobeConfig = ''
    options usbcore quirks=0x1b1c:0x0a6b:k
  '';
}
