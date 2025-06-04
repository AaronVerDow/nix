# Apparmor on NixOS

Apparmor exists in NixOS, but the policies do very little, and any external policies cannot be imported without modifications to work with Nix's unique paths. This document covers getting Apparmor configured to work on NixOS with the policies in apparmor.d, a public maintained repository of over 1,600 Apparmor policies.

Apparmor on NixOS is currently undergoing development.

This configuration has been organized to be as simple to implement as possible and does not assume any existing organization for modules or packages.

Most of this work is copied from xx; please see his thread here.

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
  
  # Add boot entry with Apparmor disabled in case of lockout
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

Browse source repository.

List available profile names:

    ls $( nix-store --query --requisites /run/current-system | grep apparmor-d )/etc/apparmor.d

One liner to check for profiles that match programs in $PATH:

    for x in $( ls $( nix-store --query --requisites /run/current-system | grep apparmor-d )/etc/apparmor.d ); do which ${x%%[^[:alpha:]]*} &> /dev/null || continue; echo '    '$x' = "enforce";';done

This is not a complete or accurate list, and may include profiles you do not want. It is simply a quick starting point for identifying utilities you may not think about.


## Build and Test

Nix currently will not catch configuration issues with Apparmor, so always check the Apparmor service after making profile changes:

    systemctl status apparmor.service

To see loaded profiles and enforced processes:

    sudo aa-status

Configuration syntax errors will leave the entire service in the stopped state. Some profile errors will allow Apparmor to run with the already loaded profiles, but the remaining profiles will be skipped.

## Use

Summary of denied actions:

    sudo aa-log

