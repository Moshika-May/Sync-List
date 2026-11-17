# Sync-List (`syncls`)

Pull folders and repos from your other Tailscale machines with arrow-key menus. One bash script on top of `rsync`, `fzf` and `ssh`.

## Install (Arch, Debian, Ubuntu, Fedora)

```sh
git clone git@github.com:Moshika-May/Sync-List.git
cd Sync-List && ./install.sh
```

`install.sh` installs `rsync` and `fzf` with pacman, apt or dnf, copies `syncls` to `~/.local/bin`, and enables an hourly systemd user timer. Make sure `~/.local/bin` is in your `PATH`.

Every machine needs `rsync`, and this machine needs key-based ssh to each of them. `syncls setup` creates a dedicated passphrase-less key (`~/.ssh/id_ed25519_syncls`, used only by syncls so the hourly timer works) and installs it, plus rsync, on the machines you pick. Tailscale must be running.

## Use

```sh
syncls          # menu: pull, jobs, status, doctor
syncls pull     # pick machine, browse its folders, pull one into the current directory
syncls jobs     # run or remove the hourly jobs
syncls status   # last result per folder
syncls setup    # pick machines; for each: ask its username, install a dedicated syncls key, install rsync there
syncls doctor   # check tools and ssh to every online machine
```

**Pull**: run `syncls` inside the folder you want the files in.
- Pick a machine, then browse its home folder. → / Space / Tab opens a folder, ← goes up, ENTER pulls the highlighted folder into the current directory (as `./<folder name>`). The top entry `.` pulls the folder you are inside.
- `●` marks git repos. `✓` means a folder with that name already exists here. The preview shows size and `git status`.
- Files that exist on both sides but differ open in a list with a diff preview. The files you mark with TAB or Space are overwritten by the remote copy, and the rest stay as they are. Overwritten files keep a `*.syncls-bak` copy.
- Nothing is written before you answer "Go? [Y/n]".

**Hourly sync**: after a pull, answer `y` to keep those folders syncing. `syncls --auto` runs from the timer and copies new files only. It never overwrites or deletes. Folders with differing files are flagged in `syncls status` and in a desktop notification when `notify-send` exists. Run `syncls pull` to resolve them.

## Limits

- Pull only, one direction. Deletions on the remote are not mirrored.
- One folder per pull. The browser starts at the remote home folder, not `/`, and skips hidden folders.
- rsync compares size and modification time, so files with the same content but different times show up as differing.
- Filenames with newlines are not supported. The diff preview does not work on filenames with spaces, but picking still works.
- Linux and macOS peers only.

Config lives in `~/.config/syncls/`, the log in `~/.local/state/syncls/log`. Run `syncls --selftest` to check the diff parsing.
