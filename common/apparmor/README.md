# AppArmor on NixOS

AppArmor exists in NixOS, but the policies do very little, and any external policies cannot be imported without modifications to work with Nix's unique paths. This document covers getting AppArmor configured to work on NixOS with the policies in [apparmor.d](https://github.com/roddhjav/apparmor.d), a publicly maintained repository of over 1,500 AppArmor profiles.

AppArmor on NixOS is currently undergoing development. Most of this work is copied from [Grimmauld](https://github.com/LordGrimmauld):
* [AppArmor on NixOS Roadmap](https://discourse.nixos.org/t/apparmor-on-nixos-roadmap/57217/1)
* [AppArmor and apparmor.d on NixOS](https://hedgedoc.grimmauld.de/s/hWcvJEniW#)
* [The Glob is dead, long live the alias! - AppArmor on NixOS Part 2](https://hedgedoc.grimmauld.de/s/03eJUe0X3#)

This configuration has been organized to be as simple to implement as possible and does not assume any existing organization for modules or packages.

## Installation

Place `apparmor_d_module.nix` and `apparmor-d_package.nix` in the directory with `configuration.nix`

Add the following to `configuration.nix`:

```
  # Import apparmor_d module for easier profile definitions
  imports = [
    ./apparmor_d_module.nix
  ];

  # Include apparmor-d package in nixpkgs
  nixpkgs = {
    overlays = [
      (final: prev: {
        apparmor-d = final.callPackage ./apparmor-d_package.nix { };
      })
    ];
  };

  # Enable apparmor service
  security.apparmor.enable = lib.mkDefault true;

  # Add additional profiles using apparmor_d module
  security.apparmor_d = {
    enable = true;
    profiles = {
      "firefox.apparmor.d" = "enforce";
      vlc = "enforce";
      dmesg = "enforce";
      btop = "enforce";
    };
  };
  
  # Add boot entry with AppArmor disabled in case of lockout
  # STRONGLY recommended
  specialisation = {
    no-apparmor = {
      configuration = {
        security.apparmor.enable = lib.mkForce false;
      };
    };
  };

  # Other recommended settings, may be optional:  

  # Adds aa-log, which is useful for debugging
  # May do other things in this context I'm not aware of
  environment.systemPackages = with pkgs; [ apparmor-parser ];
  
  # Kill existing processes if they can be confined
  security.apparmor.killUnconfinedConfinables = false;

  services.dbus.apparmor = "enabled";
  security.apparmor.enableCache = true;

  # Additional logging
  security.auditd.enable = true;
  security.audit.backlogLimit = 8192;
```

## Choosing Profiles

Browse the [source repository](https://github.com/roddhjav/apparmor.d/tree/main/apparmor.d). Some names, especially those with multiple profiles, may be different.

List available profile names:

    ls $( nix-store --query --requisites /run/current-system | grep apparmor-d )/etc/apparmor.d

## Build and Test

Nix currently will not catch configuration issues with AppArmor, so always check the service after making profile changes:

    systemctl status apparmor.service

To see loaded profiles and enforced processes:

    sudo aa-status

Configuration syntax errors will leave the entire service in the stopped state. Some profile errors will allow AppArmor to run with the already loaded profiles, but the remaining profiles will be skipped.

Reboot the system to make sure it can start properly.

## Use

Summary of denied actions:

    sudo aa-log

