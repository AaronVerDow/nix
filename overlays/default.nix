# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: let
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  in {
    unstable =
      unstable
      // {
        # NeoWall spawns an nvidia-smi polling thread even when no shader uses
        # the NVIDIA-reactive uniforms. On 0.7.x that child inherits NeoWall's
        # blocked SIGTERM mask, so session shutdown waits 90s before SIGKILL.
        neowall = unstable.neowall.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              substituteInPlace src/shader/reactive.c \
                --replace-fail \
                  'static void *nv_thread_fn(void *arg) {' \
                  $'static void *nv_thread_fn(void *arg) {\n    (void)arg;\n    atomic_store(&g_nv_live, false);\n    return NULL;'
            '';
        });
      };
  };
}
