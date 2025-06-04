# Apparmor on NixOS

Apparmor exists in NixOS, but it the existing policies do very little and other policies cannot be imported without modifications to work with Nix's unique paths.

This document covers getting Apparmor configured to work on NixOS with the policies in apparmor.d, a public repository of over 1,600 Apparmor policies.

The basic requirements are:

* Call `apparmor-d` package. This modifies the upstream apparmor.d repository to work with NixOS paths, and builds the policies. 
  * _Warning:_ The policies in the source repository cannot be used directly.
* Include `apparmor_d` module. This creates a module that makes it easier to include polices from the apparmor.d package.
* Enable apparmor and apparmor_d in `configuration.nix`

## Package

Place `default.nix` and `prebuild.patch` into `apparmor-d` directory.

Include the package using `pkgs.callPackage`:

    apparmor-d = pkgs.callPackage ./apparmor-d { };

(May need elaboration, I do not know common methods for adding custom packages.)

## Module

Download `apparmor_d.nix` module.

Import in `configuration.nix`:

```
  imports = [ ./apparmor_d.nix ];
```

## Enable Modules

Enable and configure apparmor in configuration.nix:

```
  # Required:
  security.apparmor.enable = lib.mkDefault true;
  security.apparmor_d = {
    enable = true;
    profiles = {
      vlc = "enforce";
      dmesg = "enforce";
      btop = "enforce";
    };
  };
  
  # Recommended:  
  services.dbus.apparmor = "enabled";
  security.auditd.enable = true;
  security.audit.backlogLimit = 8192;
  security.apparmor.enableCache = true;
  security.apparmor.killUnconfinedConfinables = false;
  environment.systemPackages = with pkgs; [ apparmor-parser ];
```

## Optional: Create a boot entry without Apparmor

For every generation created this will create a second boot entry with apparmor disabled. This can be helpful for recovery if locked out.

```
  specialisation = {
    no-apparmor = {
      configuration = {
        security.apparmor.enable = lib.mkForce false;
      };
    };
  };
```

## Choose profiles

List available profile names:

    ls $( nix-store --query --requisites /run/current-system | grep apparmor-d )/etc/apparmor.d

One liner to check for profiles that match programs in $PATH:

    for x in $( ls $( nix-store --query --requisites /run/current-system | grep apparmor-d )/etc/apparmor.d ); do which ${x%%[^[:alpha:]]*} &> /dev/null || continue; echo '    '$x' = "enforce";';done

This is not a complete or accurate list, and may include profiles you do not want. It is simply a quick starting point for identifying utilities you may not think about.


# Build

Nix will build and switch with invalid Apparmor configurations always check the Apparmor service after making profile changes:

    systemctl status apparmor.service

To see loaded profiles and enforced processes:

    sudo aa-status
