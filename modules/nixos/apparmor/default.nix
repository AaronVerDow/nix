{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    ;
in
{
  imports = [ ./apparmor-d-module.nix ];

  config = mkIf config.security.apparmor.enable {
    services.dbus.apparmor = "enabled";
    security.auditd.enable = true;

    # security.apparmor.enable = lib.mkDefault true;
    security.apparmor.enableCache = true;
    security.apparmor.killUnconfinedConfinables = false;

    environment.systemPackages = with pkgs; [ apparmor-parser ];

    security.audit.backlogLimit = 8192;

    security.apparmor_d = {
      enable = true;
      profiles = {
        # ===============================
        # AppArmor Management Tools
        # ===============================
        aa-enabled = "enforce";
        aa-enforce = "enforce";
        aa-log = "enforce";
        # aa-notify = "enforce";
        # Jun 03 22:24:55 gonix apparmor_parser[53849]: profile has merged rule with conflicting x modifiers
        # Jun 03 22:24:55 gonix apparmor_parser[53849]: ERROR processing regexs for profile editor, failed to load
        aa-status = "enforce";
        aa-teardown = "enforce";
        aa-unconfined = "enforce";
        apparmor_parser = "enforce";

        # ===============================
        # Audio & Media Applications
        # ===============================
        gimp = "enforce";
        mpv = "enforce";
        pipewire = "enforce";
        pipewire-pulse = "enforce";
        pulseaudio = "enforce";
        speech-dispatcher = "enforce";
        vlc = "enforce";
        volumeicon = "enforce";
        wireplumber = "enforce";

        # ===============================
        # Bluetooth & Wireless
        # ===============================
        bluetoothctl = "enforce";
        bluetoothd = "enforce";
        bluemoon = "enforce";
        hciconfig = "enforce";
        obexctl = "enforce";
        obexd = "enforce";
        rfkill = "enforce";
        wavemon = "enforce";

        # ===============================
        # Communication & Social
        # ===============================
        discord = "enforce";

        # ===============================
        # Core System Utilities
        # ===============================
        df = "enforce";
        id = "enforce";
        pidof = "enforce";
        ps = "enforce";
        sync = "enforce";
        top = "enforce";
        uname = "enforce";
        uptime = "enforce";
        w = "enforce";
        who = "enforce";
        whoami = "enforce";

        # ===============================
        # Desktop Environment & Display
        # ===============================
        arandr = "enforce";
        compton = "enforce";
        dconf = "enforce";
        gdm = "enforce";
        gdm-session-worker = "enforce";
        gdm-xsession = "enforce";
        iceauth = "enforce";
        light = "enforce";
        picom = "enforce";
        setvtrgb = "enforce";
        xauth = "enforce";
        xclip = "enforce";
        xinput = "enforce";
        xorg = "enforce";
        xprop = "enforce";
        xrandr = "enforce";
        xrdb = "enforce";
        xset = "enforce";
        xsetroot = "enforce";

        # ===============================
        # Development Tools
        # ===============================
        # git = "complain";
        # git status fails in enforce
        # DENIED  git open owner @{HOME}/git/nix/.git/HEAD comm=git requested_mask=r denied_mask=r

        # git diff fails in complain
        # fatal: cannot exec 'less': Permission denied
        # fatal: unable to execute pager 'less'
        # ALLOWED git exec /nix/store/66ld17ifbjz63firjjv88aydxsc3rcs6-less-668/bin/less info="profile transition not found" comm=git requested_mask=x denied_mask=x error=-13

        ollama = "enforce";
        onefetch = "enforce";
        ssh = "enforce";
        ssh-agent = "enforce";
        ssh-keygen = "enforce";
        sshd = "enforce";

        # ===============================
        # File System & Storage Management
        # ===============================
        badblocks = "enforce";
        blkdeactivate = "enforce";
        blkid = "enforce";
        blockdev = "enforce";
        cfdisk = "enforce";
        dumpe2fs = "enforce";
        e2fsck = "enforce";
        e2image = "enforce";
        e2scrub_all = "enforce";
        eject = "enforce";
        fatlabel = "enforce";
        fdisk = "enforce";
        findmnt = "enforce";
        fstrim = "enforce";
        fusermount = "enforce";
        losetup = "enforce";
        lvm = "enforce";
        lvmconfig = "enforce";
        lvmdump = "enforce";
        mke2fs = "enforce";
        mkswap = "enforce";
        mount = "enforce";
        mtools = "enforce";
        resize2fs = "enforce";
        sfdisk = "enforce";
        swaplabel = "enforce";
        swapon = "enforce";
        tune2fs = "enforce";
        udisksd = "enforce";
        umount = "enforce";
        usb-devices = "enforce";
        uuidd = "enforce";
        uuidgen = "enforce";

        # ===============================
        # Font & Text Processing
        # ===============================
        fc-cache = "enforce";
        fc-list = "enforce";
        install-info = "enforce";
        mandb = "enforce";
        update-mime-database = "enforce";
        whatis = "enforce";
        whereis = "enforce";
        which = "enforce";

        # ===============================
        # Hardware Management
        # ===============================
        acpi = "enforce";
        cpupower = "enforce";
        lscpu = "enforce";
        sensors = "enforce";
        smartctl = "enforce";

        # ===============================
        # Network Management
        # ===============================
        host = "enforce";
        hostname = "enforce";
        hostnamectl = "enforce";
        ifconfig = "enforce";
        ip = "enforce";
        ModemManager = "enforce";
        netstat = "enforce";
        networkctl = "enforce";
        NetworkManager = "enforce";
        nmcli = "enforce";
        nm-online = "enforce";
        resolvconf = "enforce";
        resolvectl = "enforce";
        ss = "enforce";

        # ===============================
        # Package Management
        # ===============================
        packagekitd = "enforce";

        # ===============================
        # Power Management
        # ===============================
        power-profiles-daemon = "enforce";
        systemd-ac-power = "enforce";

        # ===============================
        # Printing
        # ===============================
        cups-browsed = "enforce";
        cups-pk-helper-mechanism = "enforce";
        cupsd = "enforce";

        # ===============================
        # Security & Authentication
        # ===============================
        auditctl = "enforce";
        auditd = "enforce";
        augenrules = "enforce";
        # pkexec = "enforce";
        # Jun 03 22:28:09 gonix apparmor_parser[58254]: profile has merged rule with conflicting x modifiers
        # Jun 03 22:28:09 gonix apparmor_parser[58254]: ERROR processing regexs for profile pkexec, failed to load
        pkttyagent = "enforce";
        polkitd = "enforce";
        rtkitctl = "enforce";

        # ===============================
        # System Boot & Initialization
        # ===============================
        agetty = "enforce";
        bootctl = "enforce";
        kexec = "enforce";
        login = "enforce";
        nologin = "enforce";
        sulogin = "enforce";

        # ===============================
        # System Information & Monitoring
        # ===============================
        btop = "enforce";
        command-not-found = "enforce";
        coredumpctl = "enforce";
        dmesg = "enforce";
        journalctl = "enforce";
        last = "enforce";
        utmpdump = "enforce";

        # ===============================
        # SystemD Services & Tools
        # ===============================
        busctl = "enforce";
        dmsetup = "enforce";
        kmod = "enforce";
        localectl = "enforce";
        loginctl = "enforce";
        sysctl = "enforce";
        systemd-analyze = "enforce";
        systemd-ask-password = "enforce";
        systemd-cat = "enforce";
        systemd-cgls = "enforce";
        systemd-cgtop = "enforce";
        systemd-cryptsetup = "enforce";
        systemd-delta = "enforce";
        systemd-detect-virt = "enforce";
        systemd-dissect = "enforce";
        systemd-escape = "enforce";
        systemd-hwdb = "enforce";
        systemd-id128 = "enforce";
        systemd-inhibit = "enforce";
        systemd-logind = "enforce";
        systemd-machine-id-setup = "enforce";
        systemd-mount = "enforce";
        systemd-networkd = "enforce";
        systemd-notify = "enforce";
        systemd-path = "enforce";
        systemd-resolve = "enforce";
        systemd-resolved = "enforce";
        systemd-sysusers = "enforce";
        systemd-timesyncd = "enforce";
        systemd-tmpfiles = "enforce";
        systemd-tty-ask-password-agent = "enforce";

        # ===============================
        # User & Group Management
        # ===============================
        chage = "enforce";
        chfn = "enforce";
        chpasswd = "enforce";
        chsh = "enforce";
        gpasswd = "enforce";
        groupadd = "enforce";
        groupdel = "enforce";
        groupmod = "enforce";
        groups = "enforce";
        grpck = "enforce";
        homectl = "enforce";
        newgidmap = "enforce";
        newgrp = "enforce";
        newuidmap = "enforce";
        passwd = "enforce";
        pwck = "enforce";
        runuser = "enforce";
        # su = "enforce";
        # Jun 03 22:30:30 gonix apparmor_parser[62466]: profile has merged rule with conflicting x modifiers
        # Jun 03 22:30:30 gonix apparmor_parser[62466]: ERROR processing regexs for profile su, failed to load
        # sudo = "enforce";
        # Jun 03 22:32:55 gonix apparmor_parser[66651]: profile has merged rule with conflicting x modifiers
        # Jun 03 22:32:55 gonix apparmor_parser[66651]: ERROR processing regexs for profile sudo, failed to load
        useradd = "enforce";
        userdbctl = "enforce";
        userdel = "enforce";
        usermod = "enforce";
        users = "enforce";

        # ===============================
        # Utilities & Desktop Tools
        # ===============================
        scrot = "enforce";

        # ===============================
        # Web Browsers
        # ===============================
        "chromium.apparmor.d" = "enforce";
        "firefox.apparmor.d" = "enforce";

        # ===============================
        # XDG & Desktop Integration
        # ===============================
        xdg-desktop-icon = "enforce";
        xdg-desktop-menu = "enforce";
        xdg-desktop-portal = "enforce";
        xdg-desktop-portal-gtk = "enforce";
        xdg-email = "enforce";
        xdg-icon-resource = "enforce";
        xdg-mime = "enforce";
        xdg-open = "enforce";
        xdg-screensaver = "enforce";
        xdg-settings = "enforce";

        # ===============================
        # Other System Tools
        # ===============================
        zramctl = "enforce";

        # ===============================
        # Commented/Disabled Profiles
        # ===============================
        # dbus-session = "enforce"; # failed to parse
      };
    };
  };
}
