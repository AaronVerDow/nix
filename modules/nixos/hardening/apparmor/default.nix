{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    getExe'
    getExe
    optional
    ;
in
{
  imports = [ ./apparmor-d-module.nix ];

  config = mkIf config.security.apparmor.enable {
    services.dbus.apparmor = "enabled";
    security.auditd.enable = true;

    security.apparmor.enableCache = true;
    security.apparmor.killUnconfinedConfinables = false;

    environment.systemPackages = with pkgs; [ apparmor-parser ];

    security.audit.backlogLimit = 8192;

    security.apparmor_d = {
      enable = true;
      profiles = {
        # Communication & Social
        discord = "enforce";

        # Web Browsers (using .apparmor.d files for main browsers)
        "firefox.apparmor.d" = "enforce";
        "chromium.apparmor.d" = "enforce";

        # Development Tools
        # git = "complain";

        # git status fails in enforce
        # DENIED  git open owner @{HOME}/git/nix/.git/HEAD comm=git requested_mask=r denied_mask=r

        # git diff fails in complain
        # fatal: cannot exec 'less': Permission denied
        # fatal: unable to execute pager 'less'
        # ALLOWED git exec /nix/store/66ld17ifbjz63firjjv88aydxsc3rcs6-less-668/bin/less info="profile transition not found" comm=git requested_mask=x denied_mask=x error=-13

        ssh = "enforce";

        # Media Applications
        vlc = "enforce";
        mpv = "enforce";
        gimp = "enforce";

        # System Services
        # dbus-session = "enforce"; # failed to parse
        systemd-networkd = "enforce";
        pipewire = "enforce";
        bluetoothd = "enforce";

        # Hardware Management
        smartctl = "enforce";
        sensors = "enforce";

        # Terminal & SSH
        sshd = "enforce";
        ssh-agent = "enforce";

        # File System & Storage
        udisksd = "enforce";

        # Graphics & Display
        xorg = "enforce";

        # Audio
        pulseaudio = "enforce";

        # Power Management
        power-profiles-daemon = "enforce";

        # Printing
        cupsd = "enforce";
        cups-browsed = "enforce";
        cups-pk-helper-mechanism = "enforce";

        # Display Manager (GDM)
        gdm = "enforce";
        gdm-session-worker = "enforce";
        gdm-xsession = "enforce";

        # Additional System Services
        polkitd = "enforce";
        NetworkManager = "enforce";
        systemd-logind = "enforce";
        systemd-resolved = "enforce";
        systemd-timesyncd = "enforce";
        packagekitd = "enforce";

        # Desktop Utilities
        arandr = "enforce";
        scrot = "enforce";
        picom = "enforce";
        btop = "enforce";

        # XDG and Desktop Integration
        xdg-desktop-portal = "enforce";
        xdg-desktop-portal-gtk = "enforce";
        xdg-open = "enforce";
      };
    };

    security.apparmor.includes = {
      "abstractions/base" = ''
        /nix/store/*/bin/** mr,
        /nix/store/*/lib/** mr,
        /nix/store/** r,
      '';
    };
  };
}
