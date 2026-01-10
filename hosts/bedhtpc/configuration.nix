{
  inputs,
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common/configuration.nix
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };

  services.cage = {
    enable = true;
    program = "${pkgs.plex-htpc}/bin/plex-htpc";
    user = "averdow";
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
