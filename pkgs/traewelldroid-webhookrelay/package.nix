{
  lib,
  buildDotnetModule,
  fetchFromGitea,
  dotnet-sdk_9,
  dotnet-aspnetcore_9,
}:

buildDotnetModule {
  pname = "traewelldroid-webhookrelay";
  version = "0.1.0";

  src = fetchFromGitea {
    domain = "git.marie.cologne";
    owner = "traewelldroid";
    repo = "WebhookRelayService";
    rev = "6ec2e15f8b6101ff653e9f36f66f771bbfc49dcc";
    hash = "sha256-jVWPgfXP5Xn/7vYKjHE5e+vYEbMxjyDwibiHNtSOcvg=";
  };

  projectFile = "WebhookRelayService/WebhookRelayService.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnet-sdk_9;
  dotnet-runtime = dotnet-aspnetcore_9;

  meta = {
    description = "Webhook relay server for traewelldroid";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ marie ];
    homepage = "https://git.marie.cologne/traewelldroid/WebhookRelayService";
    mainProgram = "WebhookRelayService";
  };
}
