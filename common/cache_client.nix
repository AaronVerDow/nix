{ ... }:

{
  nix = {
    settings = {
      substituters = [
        "http://binarycache.verdow.lan"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "binarycache.verdow.lan:PZMtoehVw98z8hP51ibb8Lr3rmT0JBZV6b9xef0+h8o="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # do garbage collection on everything but server
    gc.automatic = true;
    gc.dates = "daily";
    gc.options = "--delete-older-than 5d";
  };
}
