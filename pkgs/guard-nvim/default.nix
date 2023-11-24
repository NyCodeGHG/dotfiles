{ vimUtils
, fetchFromGitHub
}: vimUtils.buildVimPlugin {
  name = "guard-nvim";
  src = fetchFromGitHub {
    owner = "nvimdev";
    repo = "guard.nvim";
    rev = "a5f6fb9869d9b9b8b31314313ba0f557de2d1100";
    hash = "sha256-RbR9l3I5Qvxo7QyMAiS1zB9u2+K/UXQt9jrl0SCRqi8=";
  };
}
