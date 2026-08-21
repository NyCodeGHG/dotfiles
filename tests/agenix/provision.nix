let
  ageKey = ''
    # created: 2026-08-21T12:13:25+02:00
    # public key: age1pq1l8595qyjf8yxqqfr5pmjax45p566syxjjheg3w0076k484yr6t7gwg56s0a8sh9j7u4flekgsswznxzqx4ewvsj3fv0pjgxd6dueuvz2ja2szpph22m3hzprp09sr2tkvlathyglgu72y9df4fpsaf7zzsa4f32k8sh24cc53zpxw7z8t5d6z35dzczdvx578qk9mavgn6l2ewjjs438v9qkvs28lkljdzymj3dvksqesfgtxtfhft9zzyp4kzgtcshuly48sc4p0sys99qc5gq9g26ptlq006y8nlfynku6ccuvj7pt796r3prprxzj84gg580gcad66gg3h23m6qe6y3t9g7mqgdawpf2gmgmsuxtjwjyh0q3kas8vyhq9gd9rcsve442htxpavpevsw9682q9sh54068dk5jzfvj3wecy09v5dpmpdv9tyeq6yyre2a27xqshwsgfthjngp2fz3ppggtzmtx9lfgxv0ugpt9vswl2l37q702kzzszcte93ygsexlcscdsplpzkdrrkelkwpdhv274snpe66nuky9g2wwyc0r99wrxef7dxg72u0s2kq6hxvgxqaaljfeknc94yytztkr3486rk37g5xzv5z2e33akkyukcejhpzqx5ucznadfudsr86spqjz5cdsx5m9vfw3j8ac5rgy8yxyz4pgg696644grc3xvpxdepwdygk58pyfajvrjvj699kxvx865yyth67tgkk62pjy984dj0rzs65u0hky5uez2k5ntvxd0037cxdxvlqzxhpf89s3spk735xytr3tsp5uckfwqup9hqw6awztz6pf49u2zchpj9w5c3n3hvn5glwgmypa7mxxxc34v2y73xhp0x6tsl0qygydypws6p56dc0hngr9yas2u4ndcvhtcnennw58aklpqtqprdrqk7mvsrlxj3xa43dh92pq26fz82qgzw45xcsgqlz0p5xyq32shptyrrfm5x8h9zpwegfs7z8xydtezjtpjjuz6xj3tuws4utrkrr8f0qhetz8qqqe6uqzmm7det7myedjz3wxm48y9kc6xecupf7j9gux0dwwtwe0r8mqv693fzran24l7pwac9gpcegemgwt370c439rp9t8dm3h2pq6heymvdz7eky0x5epsjhzuk4ztc09p989zz0dlqsznwj288k5grh7yz4mc89dw4qgcyxujhkvpjmxzap7tgqmgwnq9yqxgpg3300fgfl8f0sdq8t5k630d54ftww2g2dfq3pryxgasgnx26hxd45gpnshux4jsjtr3uyghw5k2v69ex2chc305qhqsk7ez0aayqzszh443ncujkw5kg3ht5xrjam64qwfscyg82pkeja6mt8yjc6rqu833kn3fxfhpz95g9den8fsv7dshfzcvjpv9syzujaj6qae4l8tq8yzx8g4c5z6tl4zd2kmc5kprrjf22ectgyh2hck00smtxudsgntwxa7ywhpna52xhn7tdzpkyzernwp68jh958qcpsdppn3vptwzvf46z9lvs2ydj0stmlh63qgsqf3rk3dsfcswkt29fhk55vtt3vjzrdg9cznfw2f85nw85fxte3aaz2v9puq2m2mnk0yh26jch9r0egjysfx9z7dc9j2gqvj7xwdwuu4ly6uuxht8zjdysppxesjwt90n9udwlvgfyfnnvnxrs6mcq3n6tnrma3aht03q8z69rq0hadrfzqcrtejnrpatg9uwzdy66m9pfd3wr8368l6y27wtqnuncz9373aayxdzgxahg0ndercz25tsdcfp5qkfuqhscp36ryx0gzlp2pe3zg4tpwamc2argwyc0vyjn2z0hsn29h5kxujv5jhka04nme6rxfyxcr3ueymdg9k34mxs7ux8euu07sejt7xzkc7e0wygz9yj9s7kcerf
    AGE-SECRET-KEY-PQ-1KZC7DF5HPPJKG92MD57RGUV66RL5YU7WKX0GFKXU44DGYMXQGU7QE54NY3
  '';
in
{
  name = "agenix-provision";

  containers.machine = {
    imports = [
      ../../config/nixos/system/agenix-keygen.nix
    ];
    uwumarie.agenix = {
      enable = true;
      provisioning.enable = true;
    };
    services.userborn.enable = true;
    virtualisation.credentials."agenix.host_key".text = ageKey;

    age.secrets.example.file = ./secret.age;
  };

  testScript = ''
    import datetime

    with subtest("host key has been provisioned"):
      machine.wait_for_file("/var/lib/agenix/host_key.txt", datetime.timedelta(seconds=10))
      key = machine.succeed("cat /var/lib/agenix/host_key.txt")
      assert """${ageKey}""" == key

    with subtest("example secret has been decrypted"):
      machine.wait_for_file("/run/agenix/example", datetime.timedelta(seconds=10))
      assert "meow" == machine.succeed("cat /run/agenix/example").strip()
  '';
}
