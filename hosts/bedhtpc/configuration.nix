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

  system.stateVersion = "23.05"; # Did you read the comment?
}
