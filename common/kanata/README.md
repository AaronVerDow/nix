# Kanata Config

Features:
* Split config that enables disabling an internal laptop keyboard while still controlling an external bluetooth board.
  * This allows placing the bluetooth keyboard over the internal one.  Internal keyboard is toggled with a chord press.
* Basic vim shortcuts when holding `;` key
* Press both shift keys for caps word

Files:
* `monolith.kbd` - main config file, requires one of the alias files below to be complete
* `internal_alias.kbd` - defines chord that disables internal keyboard
* `external_alias.kbd` - assigns keys that are part of the chord to their original functions
* [`configuration.nix`](../../hosts/gonix/configuration.nix) - example configuration.nix that uses the files above
* `fake_vim` - legacy file; keeping this so I have something stable to work with

Issues:
* Config files are being concatenated in configuration.nix
  * Includes only seem to follow relative paths, not sure how to do that with nix.
  * Passing NixOS configFile does not work, even when permissions are fixed.
* Excluding the internal keyboard does not work, that instance does nothing.
  * Currently I am manually including external keyboards.
* Cannot find device ID for bluetooth boards.
* Lenovo IdeaPad doesn't seem capable of a four character chord?
* Missing keycode for stop button
