# run this to update Onboard settings

# system-theme-associations is a datatype currently not handled by dconf2nix

root=org/onboard
dconf dump "/${root}/" | crudini --del - / system-theme-associations | dconf2nix --root "$root" > onboard.nix
