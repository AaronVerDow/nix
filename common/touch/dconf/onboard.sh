# run this to update Onboard settings

# system-theme-associations is a datatype currently not handled by dconf2nix
# replace /nix/store paths with ~/.nix-profile for portability

root=org/onboard
dconf dump "/${root}/" | crudini --del - / system-theme-associations | dconf2nix --root "$root" | sed 's#/nix/store/[^/]*#$HOME/.nix-profile#' > onboard.nix
