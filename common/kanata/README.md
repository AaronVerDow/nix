# Kanata Config

This is currently a work in progress.

Paste this in vim for highlighted columns:
```
lua vim.opt.colorcolumn="2,7,12,17,22,27,32,37,42,47,52,57,62,67,72,77,82,87,92,97,102"
```

Discussions:
* [Disable built in keyboard when external connects?](https://github.com/jtroo/kanata/discussions/763)

Features:
* Split config that enables disabling an internal laptop keyboard while still controlling an external bluetooth board.
  * This allows placing the bluetooth keyboard over the internal one.  Internal keyboard is toggled with a chord press.
* Basic vim shortcuts when holding `;` key
* Press both shift keys for caps word
* Auto run
  * Press w four times rapidly and they key will be held
  * Press s to stop

Files:
* `kanata.kbd` - main config file, requires one of the alias files below to be complete
* `internal_alias.kbd` - defines chord that disables internal keyboard
* `external_alias.kbd` - assigns keys that are part of the chord to their original functions
* [`configuration.nix`](../../hosts/gonix/configuration.nix) - example configuration.nix that uses the files above

Issues:
* Config files are being concatenated in configuration.nix
  * Includes only seem to follow relative paths, not sure how to do that with nix.
  * Passing NixOS configFile does not work, even when permissions are fixed.
* Excluding the internal keyboard does not work, that instance does nothing.
  * Currently I am manually including external keyboards.
* Cannot find device ID for bluetooth boards.
* Lenovo IdeaPad doesn't seem capable of a four character chord?
* Missing keycode for stop button

Pages to copy from:
* [Kanata vim-style config](https://github.com/Sairyss/.dotfiles/tree/master/.config/kanata)
* [More pure Kanata vim config](https://github.com/jtroo/kanata/discussions/1482)
