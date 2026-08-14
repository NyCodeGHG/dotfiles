{
  pkgs,
  lib,
  osConfig,
  config,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    lspServers = {
      c = {
        command = lib.getExe' pkgs.clang-tools "clangd";
        extensionToLanguage = {
          ".c" = "c";
          ".h" = "c";
          ".cc" = "cpp";
          ".cpp" = "cpp";
          ".hh" = "cpp";
          ".hpp" = "cpp";
        };
      };
      rust = {
        command = lib.getExe pkgs.rust-analyzer;
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
      typescript = {
        command = lib.getExe pkgs.vtsls;
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
          ".mjs" = "javascript";
          ".cjs" = "javascript";
        };
      };
      go = {
        command = lib.getExe pkgs.gopls;
        args = [ "serve" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
    };
    context = ''
      # General
      - You are running on the machine `${osConfig.networking.hostName}`.
      - This file is the global CLAUDE.md. To change it, edit the `claude.nix` home-manager
        configuration (`config/home-manager/programs/claude.nix` in the dotfiles repo), not
        `~/.claude/CLAUDE.md` - that path is a read-only symlink into the nix store.
      - Default to prototyping and refining ideas rather than building. Do not start
        implementing unless you are told to. When you do implement, do it "the right way"
        rather than hacking something together - the bias toward exploration is about scope,
        not about quality.
      - do not commit, push, open pull requests, or trigger any other kind of interaction with other humans unless explicitly asked to
      - in repositories that use jujutsu, use `jj` rather than `git`. A `.jj/` directory means
        the repo is jj-based, even when it is colocated with git and therefore still looks
        like a plain git repo (`.git/` present, git status reported by the harness). A
        detached HEAD is normal there - start work with `jj new`, not `git checkout -b`.
        jj is a fast moving tool whose CLI still changes, so check `jj help <subcommand>`
        for current usage instead of relying on what you remember.
      - if you're unsure about something, ask instead of guessing
      - prefer pre-approved and configured tooling over ad-hoc shell commands, both to avoid
        unnecessary permission prompts and because it is usually more accurate:
        - the `nixos` MCP server for anything about nixpkgs packages, NixOS / home-manager /
          nix-darwin options, flakes, the binary cache or store paths. It queries live data;
          your own knowledge of nixpkgs lags by months.
        - the `linux` MCP server for read-only inspection of machines (services, journals,
          block devices, processes, files). Every tool takes a `host` argument, so prefer it
          over raw `ssh` when inspecting a remote host.
      - keep changes minimal and focused, don't refactor unless it's required for your task or you're asked to
      - clean up after yourself. Do not leave files lying around, neither on this machine nor
        on any remote host you touched. Remove temporary files, build artifacts and scratch
        directories as soon as they are no longer needed, and remove code you just made
        redundant. Anything you create outside the scratchpad directory is yours to delete
        when you are done with it.
      - never use my home directory for scratchpad work or temporary files. Use the scratchpad
        directory the harness gives you, or `$TMPDIR`.
      - Do not invent useless backwards compatibility when it's not required
      - Do not hesitate to use manpages. Prefer reading them from the local commands over
        fetching the same documentation from a web page - the local ones match the versions
        actually installed. `nix-locate-man` is aliased to `man`, so it transparently fetches
        manpages for commands that are not installed. Run `man` on the local machine even
        when the task is about a remote host over ssh - do not `ssh <host> man ...`.
      - when you need to read or search a codebase, get a local copy and search that, instead
        of fetching individual files on demand. Clone it if it is not too big; some large
        repos are already checked out under `~/projects` (e.g. the Linux kernel, which is far
        too big to clone on demand). If it is a nix package, build its source rather than
        cloning: `nix-build '<nixpkgs>' -A hello.src --no-out-link` prints a store path you
        can then grep.

      # Nix
      - Never search the whole `/nix/store`. Do not run `find`, `fd`, `grep -r`,
        `ls`, or any glob against `/nix/store` itself - it is enormous and the
        scan will hang.
      - Prefer evaluating store paths over building. When you must build, prefer `nix-build`
        where a regular entry point exists (nixpkgs has one); use flake-based `nix build` only
        when required. Pass `--no-link` to avoid leaving result symlinks behind.
      - Use a shell.nix or devShell in flake.nix when available over quick nix-shell/nix shell invocations.
    '';

    settings = {
      permissions.allow = [
        "WebSearch"
        "WebFetch"
        "Bash(nix build:*)"
        "Bash(nix-build:*)"
        "Bash(nix eval:*)"
        "Bash(nix repl:*)"
        "Bash(nix log:*)"
        "Read(/nix/store/**)"
      ]
      # The MCP servers are surfaced to Claude Code as a plugin, and that plugin's name is not
      # derivable from anything we configure here - it has already changed once
      # (`claude-code-home-manager` -> `hm`), which silently invalidated these entries. Allow
      # both spellings so a rename does not break the allowlist again.
      #
      # linux-mcp-server also ships a `run_script` tool that executes arbitrary scripts on the
      # target host. It is not exposed while the server runs with its default `fixed` toolset,
      # but a wildcard here would silently allow it if that ever changed, so the read-only
      # tools are enumerated instead.
      ++ lib.concatMap (plugin: [
        "mcp__plugin_${plugin}_nixos__*"
      ]
      ++ map (tool: "mcp__plugin_${plugin}_linux__${tool}") [
        "get_cpu_information"
        "get_disk_usage"
        "get_hardware_information"
        "get_journal_logs"
        "get_listening_ports"
        "get_memory_information"
        "get_network_connections"
        "get_network_interfaces"
        "get_process_info"
        "get_service_logs"
        "get_service_status"
        "get_system_information"
        "list_block_devices"
        "list_directories"
        "list_files"
        "list_processes"
        "list_services"
        "read_file"
        "read_log_file"
      ]) [
        "hm"
        "claude-code-home-manager"
      ];
    };
  };

  programs.mcp = {
    enable = true;
    servers = {
      nixos = {
        command = lib.getExe pkgs.mcp-nixos;
      };
      github = {
        url = "https://api.githubcopilot.com/mcp/";
      };
      linux = {
        command = lib.getExe pkgs.linux-mcp-server;
      };
      victorialogs = {
        command = lib.getExe pkgs.mcp-victorialogs;
        env = {
          VL_INSTANCE_ENTRYPOINT = "https://logs.artemis.marie.cologne";
        };
      };
      grafana = {
        command = lib.getExe pkgs.mcp-grafana;
        env = {
          GRAFANA_URL = "https://grafana.marie.cologne";
          GRAFANA_SERVICE_ACCOUNT_TOKEN.file = "/run/user/1000/agenix/grafana-mcp-token";
        };
      };
      home-assistant = {
        url = "https://hass.marie.cologne/api/mcp";
        oauth = {
          clientId = "http://localhost:12345";
          callbackPort = 12345;
        };
      };
    };
  };

  age.secrets.grafana-mcp-token.file = ../../../secrets/grafana-mcp-token.age;

  programs.opencode = {
    enable = true;
    context = config.programs.claude-code.context;
    enableMcpIntegration = true;
  };
}
