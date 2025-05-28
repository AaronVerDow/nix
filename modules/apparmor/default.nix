{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.grimmShared) enable tooling;
  inherit (lib) mkIf getExe' getExe;
in
{
  imports = [ ./apparmor-d-module.nix ]; # ./aa-alias-module.nix ];

  config = mkIf (enable && tooling.enable && config.security.apparmor.enable) {
    services.dbus.apparmor = "enabled";
    security.auditd.enable = true;

    security.apparmor.enableCache = true;
    security.apparmor.killUnconfinedConfinables = false;

    security.apparmor.includes."tunables/alias.d/programs" = ''
      # alias / -> /nix/store/*/,
      alias /bin/spotify -> ${pkgs.spotify}/share/spotify/spotify,
      alias /bin/spotify -> ${pkgs.spotify}/share/spotify/.spotify-wrapped,
      alias /bin/firefox -> /nix/store/*/bin/.firefox-wrapped,
    '';

    environment.systemPackages = with pkgs; [ apparmor-parser ];

    #    security.apparmor.aa-alias-manager.enable = false;

    security.audit.backlogLimit = 8192;

    security.apparmor_d = {
      enable = true;
      profiles = {
        vesktop = "enforce";
        speech-dispatcher = "enforce";
        thunderbird-glxtest = "enforce";
        "firefox.apparmor.d" = "enforce";
        pass = "enforce";
        spotify = "enforce";
        "thunderbird.apparmor.d" = "enforce";
        xdg-open = "enforce";
        # child-open-any = "enforce";
        child-open = "enforce";
        firefox-glxtest = "enforce";
        firefox-vaapitest = "enforce";
        gamemoded = "disable";
        # pkexec = "complain";
        xdg-mime = "complain";
        mimetype = "complain";
        # sudo = "complain";
        "unix-chkpwd.apparmor.d" = "complain";
      };
    };

    security.apparmor.includes = {
      "abstractions/base" = ''
        /nix/store/*/bin/** mr,
        /nix/store/*/lib/** mr,
        /nix/store/** r,
        ${getExe' pkgs.coreutils "coreutils"} rix,
        ${getExe' pkgs.coreutils-full "coreutils"} rix,
      '';

      #      "tunables/alias.d/store" = ''
      #        include <tunables/global>
      #        alias /bin -> @{bin},
      #        alias /bin/ -> /nix/store/*/bin/,
      #      '';

      "local/speech-dispatcher" = ''
        @{nix_store}/libexec/speech-dispatcher-modules/* ix,
        @{PROC}/@{pid}/stat r,
        @{bin}/mbrola rix,
      '';

      "local/pass" = ''
        ${getExe' pkgs.pass ".pass-wrapped"} rix,
        @{nix_store}/wl-copy rUx,
        @{nix_store}/wl-paste rUx,
      '';

      "local/pass_gpg" = ''
        @{PROC}/@{pid}/fd/ r,
        /nix/store/*/libexec/keyboxd ix,
        owner /run/user/*/gnupg/S.keyboxd wr,
      '';

      "local/xdg-mime" = ''
        #        include <abstractions/app/bus>
                /bin/grep rix,
                /bin/gawk rix,
        #        /bin/dbus-send Cx -> bus,
                /dev/tty* rw,
      '';

      "abstractions/app/udevadm.d/udevadm_is_exec" = ''
        @{bin}/udevadm mrix,
      '';

      "local/firefox" = ''
        ${pkgs.passff-host}/share/passff-host/passff.py rPx -> passff,
        @{HOME}/.mozilla/firefox/** mr,
      '';

      "local/thunderbird" = ''
        ${getExe' pkgs.thunderbird ".thunderbird-wrapped_"} rix,
        /dev/urandom w,
      '';

      "abstractions/common/electron.d/libexec" = ''
        /nix/store/*/libexec/electron/** rix,
      '';

      "local/pkexec" = ''
        capability sys_ptrace,
      '';

      "local/xdg-open" = ''
        /** r,
      '';

      "local/child-open" = ''
        # include <abstractions/app/bus>
        @{bin}/grep ix,
        /@{PROC}/version r,
        # @{bin}/gdbus Cx -> bus,
        @{bin}/gdbus Ux,
      '';

      "local/vesktop" = ''
        /etc/machine-id r,
        /dev/udmabuf rw,
        /sys/devices/@{pci}/boot_vga r,
        /sys/devices/@{pci}/**/id{Vendor,Product} r,
        /dev/ r,
        # @{bin}/xdg-open rPx,
        /bin/electron rix,
      '';

      "local/sudo" = ''
        /run/wrappers/wrappers.*/unix_chkpwd rPx -> unix-chkpwd,
      '';

      "local/unix-chkpwd" = ''
        capability dac_read_search,
      '';

      #      "local/spotify" = ''
      #        @{bin}/
      #      '';
    };

    security.apparmor.policies = {
      passff = {
        state = "enforce";
        profile = ''
          abi <abi/4.0>,
          include <tunables/global>
          profile passff ${pkgs.passff-host}/share/passff-host/passff.py {
            include <abstractions/base> # read access to /nix/store, basic presets for most apps
            include <abstractions/python>
            @{bin}/pass Px -> pass,
          }
        '';
      };

      swaymux = {
        state = "enforce";
        profile = ''
          abi <abi/4.0>,
          include <tunables/global>
          profile swaymux ${getExe pkgs.swaymux} {
            include <abstractions/base> # read access to /nix/store, basic presets for most apps
            ${pkgs.swaymux}/bin/* rix, # wrapping
            /dev/tty r,
            owner @{user_config_dirs}/** r,
          }
        '';
      };

      #      speech-dispatcher-test = {
      #        profile = ''#
      #
      #abi <abi/4.0>,
      #
      #include <tunables/global>
      #
      #@{exec_path} = @{bin}/speech-dispatcher
      #profile speech-dispatcher ${getExe' pkgs.speechd "speech-dispatcher"} flags=(complain) {
      #  include <abstractions/base>
      #  include <abstractions/audio-client>
      #  include <abstractions/bus-session>
      #  include <abstractions/consoles>
      #  include <abstractions/nameservice-strict>

      #  network inet stream,
      #  network inet6 stream,

      #  @{exec_path} mr,

      #  @{sh_path} ix,
      #  @{lib}/speech-dispatcher/** r,
      #  @{lib}/speech-dispatcher/speech-dispatcher-modules/* ix,

      #  /etc/machine-id r,
      #  /etc/speech-dispatcher/{,**} r,

      #  owner @{run}/user/@{uid}/speech-dispatcher/ rw,
      #  owner @{run}/user/@{uid}/speech-dispatcher/** rwk,

      #  include if exists <local/speech-dispatcher>
      #}        '';
      #      };

      osu-lazer = {
        state = "disable";
        profile = ''
          abi <abi/4.0>,
          include <tunables/global>
          profile osu-lazer @{bin}/osu\! flags=(attach_disconnected) {
            include <abstractions/base> # read access to /nix/store, basic presets for most apps

            include <abstractions/common/bwrap>
            include <abstractions/devices-usb>
            include <abstractions/nameservice-strict>
            include <abstractions/app/udevadm>
            include <abstractions/app/bus>
            include <abstractions/common/game>

            network inet dgram,
            network inet6 dgram,
            network inet stream,
            network inet6 stream,
            network netlink raw,

            owner @{PROC}/@{pid}/net/dev r,
            owner @{PROC}/@{pid}/net/if_inet6 r,
            owner @{PROC}/@{pid}/net/ipv6_route r,
            owner @{PROC}/@{pid}/net/route r,

            capability mknod,

            /dev/tty{@{d},} rw,

            ${pkgs.osu-lazer-bin}/bin/osu? ix,
            ${getExe pkgs.bubblewrap} rix,
            /nix/store/*-osu-lazer-bin-*-bwrap ix,
            /nix/store/*-osu-lazer-bin-*-init ix,
            /nix/store/*-container-init ix,
            /nix/store/*-osu-lazer-bin-*-extracted/** rk,
            /nix/store/*-osu-lazer-bin-*-extracted/AppRun ix,
            /nix/store/*-osu-lazer-bin-*-extracted/usr/bin/** ix,

            @{bin}/ldconfig ix,
            @{bin}/appimage-exec.sh ix,
            @{bin}/rev ix,
            @{bin}/bash ix,
            @{bin}/grep ix,
            @{bin}/lsblk ix,
            @{bin}/awk ix,
            @{bin}/gawk ix,
            
            @{bin}/xdg-mime Px,
            /usr/bin/xdg-mime Px,
            ${getExe' pkgs.gamemode "gamemoderun"} ix,
            
            owner @{HOME}/@{XDG_DATA_DIR}/osu/** rwkm,
            owner @{HOME}/.dotnet/** rwkm,
            owner @{HOME}/@{XDG_DATA_DIR}/Sentry/** rwk,
            owner @{HOME}/@{XDG_CONFIG_DIR}/mimeapps* rwk,
            owner @{HOME}/@{XDG_DATA_DIR}/applications/discord-*.desktop rwk,

            /nix/store/*-etc-os-release rk,
            /nix/store/*/share/zoneinfo/** rk,

            owner /tmp/** rwk,
            /usr/lib/ r,

            owner /var/cache/ldconfig/ rw,
            owner /etc/ld.so* rw,
            
            owner @{PROC}/@{pid}/{maps,stat} rk,
            @{PROC}/sys/kernel/os{type,release} rk,
            
            /dev/snd/** rw,
            /dev/udmabuf wr,
            
            /.host-etc/alsa/conf.d/{,**} r,
            /.host-etc/ssl/certs/{,**} r,
            /.host-etc/resolv.conf rk,
          }
        '';
      };
    };
  };
}
