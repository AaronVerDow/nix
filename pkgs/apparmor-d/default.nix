{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.grimmShared) enable tooling;
  inherit (lib)
    mkIf
    optionalString
    getExe'
    getExe
    ;
  apparmor-d = pkgs.callPackage ./apparmor-d.nix { };
  allowFingerprinting = true;
in
{
  config = mkIf (enable && tooling.enable) {
    services.dbus.apparmor = "enabled";
    security.auditd.enable = true;

    security.apparmor.packages = [ apparmor-d ];
    security.apparmor.enable = true;

    security.apparmor.includes = {
      "abstractions/base" = ''
        /nix/store/*/bin/** mr,
        /nix/store/*/lib/** mr,
        /nix/store/** r,
      '';

      "local/speech-dispatcher" = ''
        ${pkgs.speechd}/libexec/speech-dispatcher-modules/* rix,
        @{PROC}/@{pid}/stat r,
        @{bin}/mbrola rix,
      '';

      "local/pass" = ''
        ${getExe' pkgs.pass ".pass-wrapped"} rix,
        ${getExe' pkgs.coreutils "coreutils"} rix,
      '';

      "local/firefox" = ''
        ${pkgs.passff-host}/share/** rPx -> passff,
      '';

      "local/thunderbird" = ''
        ${getExe' pkgs.thunderbird ".thunderbird-wrapped_"} rix,
        /dev/urandom w,
      '';

      "local/xdg-open" = ''
        ${getExe' pkgs.coreutils "coreutils"} rix,
        /proc/version r,
      '';

      "local/vesktop" =
        ''
          @{bin}/electron rix,
          /nix/store/*/libexec/electron/** rix,
          @{bin}/speech-dispatcher rPx,
          @{bin}/xdg-open rPx,
        ''
        + (optionalString allowFingerprinting ''
          /etc/machine-id r,
          /dev/udmabuf rw,
          /dev/ r,
          /sys/devices/@{pci}boot_vga r,
          /sys/devices/@{pci}idVendor r,
          /sys/devices/@{pci}idProduct r,
        '');
    };

    security.apparmor.policies = {
      passff = {
        enable = true;
        enforce = true;
        profile = ''
          abi <abi/4.0>,
          include <tunables/global>
          profile passff ${pkgs.passff-host}/share/passff-host/passff.py {
            include <abstractions/base> # read access to /nix/store, basic presets for most apps
            include <abstractions/python>
            ${getExe pkgs.pass} Px,
          }
        '';

      };

      swaymux = {
        enable = true;
        enforce = true;
        profile = ''
          abi <abi/4.0>,
          include <tunables/global>
          profile swaymux ${getExe pkgs.swaymux} {
            include <abstractions/base> # read access to /nix/store, basic presets for most apps
            ${pkgs.swaymux}/bin/* rix, # wrapping
            owner @{user_config_dirs}/Kvantum/** r, # themeing
          }
        '';
      };
      vesktop = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/profiles-s-z/vesktop"
        '';
      };
      speech-dispatcher = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/profiles-s-z/speech-dispatcher"
        '';
      };
      spotify = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/profiles-s-z/spotify"
        '';
      };
      thunderbird = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/profiles-s-z/thunderbird"
        '';
      };
      thunderbird-glxtest = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/profiles-s-z/thunderbird-glxtest"
        '';
      };
      xdg-open = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/groups/freedesktop/xdg-open"
        '';
      };
      child-open-any = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/groups/children/child-open-any"
        '';
      };
      child-open = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/groups/children/child-open"
        '';
      };
      firefox-glxtest = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/groups/browsers/firefox-glxtest"
        '';
      };
      firefox = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/groups/browsers/firefox"
        '';
      };
      pass = {
        enable = true;
        enforce = true;
        profile = ''
          include "${apparmor-d}/etc/apparmor.d/profiles-m-r/pass"
        '';
      };
    };
  };
}
