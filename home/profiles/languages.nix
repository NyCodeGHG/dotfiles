let
  german = "de_DE.utf8";
  english = "en_US.utf8";
in
{
  home.language = {
    base = english;
    address = german;
    messages = german;
    monetary = german;
    name = german;
    numeric = german;
    time = german;
  };
}
