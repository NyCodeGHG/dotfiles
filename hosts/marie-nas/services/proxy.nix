{
  ...
}:

{
  services.g3proxy = {
    enable = true;
    settings = {
      server = [
        {
          name = "default";
          escaper = "default";
          type = "socks_proxy";
          listen = {
            address = "[::]:8888";
          };
        }
      ];
      resolver = [
        {
          name = "default";
          type = "c-ares";
        }
      ];
      escaper = [
        {
          name = "default";
          type = "direct_fixed";
          no_ipv6 = false;
          resolver = "default";
          resolve_strategy = "ipv6_first";
        }
      ];
    };
  };
}
