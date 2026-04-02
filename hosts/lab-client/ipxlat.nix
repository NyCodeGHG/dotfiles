{ pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.buildLinux {
      version = "7.0.0-rc3";

      src = pkgs.fetchFromGitea {
        domain = "codeberg.org";
        owner = "IPv6-Monostack";
        repo = "ipxlat-net-next";
        rev = "c1858962918b32156a4d157b779faf7e62180ff6";
        hash = "sha256-slIC+0up0b1SnclpXn/CyNL1FCBV8gh5xyUP9/T4SPs=";
      };
      
      structuredExtraConfig = with lib.kernel; {
        IPXLAT = yes;
      };
    }
  );
}
