# Nix Run Desktop

Temporarily run X packages in Nix without keeping a shell open.

* Programs launch and detach from the shell so it can be closed.
* Automatically add desktop files that will install programs as needed using `nix run`

This allows easy access to X programs that are not used frequently. They will be installed as needed and will be removed by garbage collection.

## nix-run-desktop

Usage: `nix-run-desktop PACKAGE`

Builds and runs PACKAGE. A floating shell is launched to show build progress. It closes automatically as soon as the program launches. Programs launch detached from the shell `nix-run-desktop` was called from so the original terminal window can be closed.

`nix-run-desktop` can also be used in desktop files.

## desktop-collector

Builds a Nix package containing `nix-run-desktop` desktop files.

This will iterate over all build inputs and:

* Copy all icons and desktop files to output package
* Rename the files to avoid conflicts
* Modify desktop files to use `nix-run-desktop`

During package build the target program will be used as a build input. It will be built on the system every time the desktop-collector package changes. The packages can then be removed using garbage collection. 

Alternatively, build the desktop-collector packages on a cache server first to avoid needing to build them on the target system.

Putting individual programs into their own packages will reduce the amount of packages that need to be built after a change.

# Todo

* Options for hash and version?
* Add warnings and errors
  * No desktop files or icons
  * No app definition
  * Too many desktop files
* Confirm sync with system flake
* Add unstable option
* Adjustable log timeout
* Handle window actions within desktop files
* Handle translations
* Use generic float and size
* Show icon before log
* Add options for other terminals
* Add links to cache server setup
* Document garbage collection demo
* Record gif
