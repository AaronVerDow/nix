# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/onboard" = {
      current-settings-page = 0;
      layout = "/home/averdow/.local/share/onboard/layouts/full.onboard";
      schema-version = "2.3";
      show-status-icon = true;
      show-tooltips = false;
      snippets = [ "0:Onboard\\\\nHome:https\\://launchpad.net/onboard" "1:Example:Create your macros here." ];
      start-minimized = true;
      theme = "/home/averdow/.local/share/onboard/themes/Nightshade.theme";
      use-system-defaults = false;
      xembed-onboard = false;
    };

    "org/onboard/auto-show" = {
      enabled = false;
    };

    "org/onboard/keyboard" = {
      audio-feedback-enabled = false;
      touch-feedback-size = 0;
    };

    "org/onboard/theme-settings" = {
      background-gradient = 0.0;
      color-scheme = "$HOME/.nix-profile/share/onboard/themes/Charcoal.colors";
      key-fill-gradient = 8.0;
      key-gradient-direction = 12.0;
      key-label-font = "";
      key-shadow-size = 0.0;
      key-shadow-strength = 0.0;
      key-size = 100.0;
      key-stroke-gradient = 8.0;
      key-stroke-width = 0.0;
      key-style = "flat";
      roundrect-radius = 28.0;
    };

    "org/onboard/typing-assistance" = {
      auto-capitalization = false;
    };

    "org/onboard/window" = {
      background-transparency = 0.0;
      docking-aspect-change-range = [ 0.0 100.0 ];
      docking-edge = "top";
      docking-shrink-workarea = false;
      enable-inactive-transparency = false;
      inactive-transparency = 70.0;
      inactive-transparency-delay = 10.0;
      transparency = 0.0;
      transparent-background = false;
    };

    "org/onboard/window/landscape" = {
      dock-expand = false;
      dock-height = 389;
      dock-width = 1497;
    };

    "org/onboard/window/portrait" = {
      dock-expand = true;
      dock-height = 310;
      dock-width = 1125;
    };

  };
}
