{ self, ... }:
{
  imports = [
    self.inputs.unlock-ssh-keys.homeManagerModules.default
  ];
  programs.unlock-ssh-keys = {
    enable = true;
    settings.folder = "SSH Keys";
  };
}
