{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "unifiedpush-common-proxies";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "unifiedpush";
    repo = "common-proxies";
    tag = "v${version}";
    hash = "sha256-JJL600Hkd0K3clUHUGtCguGQj64N6tcC4D/Di1lY15o=";
  };

  vendorHash = "sha256-CJhTZsQ/MjieDR+l7U85DfR4s/bVGuuQZMf7MGnAlw8=";

  meta = with lib; {
    description = "Set of rewrite proxies and gateways for UnifiedPush";
    homepage = "https://github.com/UnifiedPush/common-proxies";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "common-proxies";
  };
}
