{
  name = "agenix-keygen";

  containers.machine = {
    imports = [
      ../config/nixos/system/agenix-keygen.nix
    ];
    uwumarie.agenix.enable = true;
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_file("/var/lib/agenix/host_key.txt", 3)
    key = machine.succeed("cat /var/lib/agenix/host_key.txt")
    assert "age1pq1" in key
    assert "AGE-SECRET-KEY-PQ-" in key
  '';
}
