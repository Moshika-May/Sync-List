# Sync-List (`syncls`)

Pull folders and repos from your other Tailscale machines with arrow-key menus. One bash script on top of `rsync`, `fzf` and `ssh`.

## Install (Arch, Debian, Ubuntu, Fedora)

```sh
git clone git@github.com:Moshika-May/Sync-List.git
cd Sync-List && ./install.sh
```

`install.sh` installs `rsync` and `fzf` with pacman, apt or dnf, copies `syncls` to `~/.local/bin`, and enables an hourly systemd user timer. Make sure `~/.local/bin` is in your `PATH`.

Every machine needs `rsync`, and this machine needs key-based ssh to each of them. Run `syncls setup` once and it does both for every online machine. Tailscale must be running.

## Use

```sh
syncls          # menu: pull, jobs, status, doctor
syncls pull     # pick machine, then folders, then files to overwrite
syncls jobs     # run or remove the hourly jobs
syncls status   # last result per folder
syncls setup    # for each online machine: ask its username, copy your ssh key, install rsync there
syncls doctor   # check tools and ssh to every online machine
```

**Pull**: arrows move, TAB selects several, ENTER confirms.
- Folders marked `●` are git repos. `✓` means the folder is already on this machine.
- Files that exist on both sides but differ open in a list with a diff preview. The files you mark with TAB are overwritten by the remote copy, and the rest stay as they are. Overwritten files keep a `*.syncls-bak` copy.
- Nothing is written before you answer "Go? [Y/n]".

**Hourly sync**: after a pull, answer `y` to keep those folders syncing. `syncls --auto` runs from the timer and copies new files only. It never overwrites or deletes. Folders with differing files are flagged in `syncls status` and in a desktop notification when `notify-send` exists. Run `syncls pull` to resolve them.

## Limits

- Pull only, one direction. Deletions on the remote are not mirrored.
- Both machines use the same path under `$HOME`. The default root is `Workspace/Coding`; edit `~/.config/syncls/roots` (one path per line).
- rsync compares size and modification time, so files with the same content but different times show up as differing.
- Filenames with newlines are not supported. The diff preview does not work on filenames with spaces, but picking still works.
- Linux and macOS peers only.

Config lives in `~/.config/syncls/`, the log in `~/.local/state/syncls/log`. Run `syncls --selftest` to check the diff parsing.
