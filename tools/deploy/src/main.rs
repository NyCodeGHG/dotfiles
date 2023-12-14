use anyhow::{bail, Context};
use clap::Parser;
use std::{
    char,
    fmt::Display,
    io::Read,
    path::{Path, PathBuf},
    process::Command,
};

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    let rebuild_script =
        which::which("nixos-rebuild").context("Couldn't find nix binary in path.")?;

    if !cli.no_confirm {
        eprintln!("[Deploy] Dry activating system {}", cli.host);
        let args = create_rebuild_args(
            RebuildOption::DryActivate,
            cli.remote_build,
            &cli.flake,
            &cli.host,
        );
        let command = Command::new(rebuild_script.display().to_string())
            .args(args)
            .status()
            .context("Failed to run dry activation.")?;
        if !command.success() {
            bail!("dry-activation exited with non zero error code!");
        }

        eprint!("[Deploy] Do you want to switch to the new configuration? [y/N]: ");
        loop {
            let c = std::io::stdin()
                .bytes()
                .next()
                .and_then(|result| result.ok())
                .map(|value| value as char);
            match c {
                Some('Y' | 'y' | 'z' | 'Z') => break,
                Some('N' | 'n') => {
                    eprintln!("[Deploy] Cancelled activation!");
                    return Ok(());
                }
                Some(_) => continue,
                None => bail!("Failed to read char!"),
            }
        }
    }

    eprintln!("[Deploy] Activating system {}", cli.host);
    let args = create_rebuild_args(
        RebuildOption::Switch,
        cli.remote_build,
        &cli.flake,
        &cli.host,
    );
    let command = Command::new(rebuild_script.display().to_string())
        .args(args)
        .status()
        .context("Failed to run activation.")?;
    if !command.success() {
        bail!("activation exited with non zero error code!");
    }

    eprintln!(
        "[Deploy] Sucessfully activated new generation on {}",
        cli.host
    );

    Ok(())
}

fn create_rebuild_args(
    action: RebuildOption,
    remote_build: bool,
    flake_path: &Path,
    host: &str,
) -> Vec<String> {
    let mut command = vec![
        action.to_string(),
        "--fast".to_string(),
        "--target-host".to_string(),
        host.to_string(),
        "--flake".to_string(),
        format!("{}#{}", flake_path.display(), host),
        "--use-remote-sudo".to_string(),
    ];
    if remote_build {
        command.push("--build-host".to_string());
        command.push(host.to_string());
    }
    command
}

#[derive(Debug, Clone, Copy)]
enum RebuildOption {
    DryActivate,
    Switch,
}

impl Display for RebuildOption {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let action = match self {
            RebuildOption::DryActivate => "dry-activate",
            RebuildOption::Switch => "switch",
        };
        f.write_str(action)
    }
}

#[derive(Parser)]
struct Cli {
    /// The host to deploy.
    /// Expects a nixosConfigurations.<host> in the current flake
    host: String,
    /// Path to the flake to deploy.
    #[arg(long, default_value = ".")]
    flake: PathBuf,
    /// Don't confirm the deploy before activation the generation.
    #[arg(long, default_value_t = false)]
    no_confirm: bool,
    #[arg(long, default_value_t = true)]
    remote_build: bool,
}
