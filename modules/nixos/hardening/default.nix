{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./apparmor
  ];

  # Enable AppArmor by default when this module is imported
  security.apparmor.enable = lib.mkDefault true;
}
