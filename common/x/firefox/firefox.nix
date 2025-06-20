# TODO: define profile and copy mozilla dotfiles
{ config, pkgs, ... }:
  # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
  let
    lock-false = {
      Value = false;
      Status = "locked";
    };
    lock-true = {
      Value = true;
      Status = "locked";
    };
    userChrome = builtins.readFile ./userChrome.css;
    userContent = builtins.readFile ./userContent.css;
  in
{
  programs = {
    firefox = {
      enable = true;
      # languagePacks = [ "en-US" ];

      profiles = {
        my_profile = {
          name = "my_profile";
          isDefault = true;
          userChrome = userChrome;
          userContent = userContent;
        };
      };

      /* ---- POLICIES ---- */
      # Check about:policies#documentation for options.
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"

        /* ---- EXTENSIONS ---- */
        # Check about:support for extension/add-on ID strings.
        # Valid strings for installation_mode are "allowed", "blocked",
        # "force_installed" and "normal_installed".
        # Get key: curl -s "https://addons.mozilla.org/api/v5/addons/addon/grammarly-1/" | jq '.guid'
        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Privacy Badger:
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          # Grammarly:
          "87677a2c52b84ad3a151a4a72f5bd3c4@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/grammarly-1/latest.xpi";
            installation_mode = "force_installed";
          };
        };
  
        /* ---- PREFERENCES ---- */
        # Check about:config for options.
        Preferences = { 
          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          "browser.formfill.enable" = lock-false;
          "browser.search.suggest.enabled" = lock-false;
          "browser.search.suggest.enabled.private" = lock-false;
          "browser.urlbar.suggest.searches" = lock-false;
          "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;

          # disable pinch zoom on touchsreen, too sensitive and causes chaos
          apz.allow_zooming = lock-false;

          # Used for CSS
          # https://github.com/Nishantdd/miniFox
          "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;
          "layers.acceleration.force-enabled" = lock-true;
          "gfx.webrender.all" = lock-true;
          "svg.context-properties.content.enabled" = lock-true;

          # more for transparency
          # https://github.com/Filip-Sutkowy/blurclean-firefox-theme
          "gfx.webrender.enable" = lock-true;
          "layout.css.backdrop-filter.enabled" = lock-true;

          # allows new tab page to be transparent but may break some websites
          # add background to userContent.css to fix individual sites
          # "browser.tabs.allow_transparent_browser" = lock-true;
        };
      };
    };
  };
}
