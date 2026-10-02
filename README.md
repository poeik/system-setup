# System setup

All scripts to get up a working dev environment up and running on macOS and WSL

## Usage

- Put scripts into the matching folder (see below) and make them executable
- Use prefix numbers (`10-git`, `20-neovim`) to control execution order
- execute `./run` (see `./run --help` for help)

`./run` detects the platform and runs `runs/common/*` first, then `runs/macos/*` or `runs/wsl/*`.
Test another platform's selection with `OS_OVERRIDE=wsl ./run dry`.

## Where does a script go?

- Same steps, different package manager -> `runs/common/`, use `pkg_install` from `lib/os.sh`
- Mostly the same with an OS quirk -> `runs/common/`, branch with `is_macos` / `is_wsl`
- Completely different (brew casks, `defaults`, apt repos, wsl.conf) -> `runs/macos/` or `runs/wsl/`

Scripts need no import: `./run` exports `$OS`, `is_macos`, `is_wsl` and `pkg_install` to them (they need a bash shebang and must be started via `./run`).
