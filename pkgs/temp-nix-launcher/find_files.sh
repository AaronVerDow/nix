set -exuo pipefail
program=$1

# automatically copy and modify desktop files and icons

store=$( nix path-info "nixpkgs#$program" )
tmp=$( mktemp -d )

rsync -vrL "$store/share/icons" share/
rsync -vrL "$store/share/applications" "$tmp"
chmod -R +w share/ "$tmp"

while read -r file; do
    sed -i '/\[/d' "$file" # strip translations
    sed -i 's/^Name=/Name=Nix Run /' "$file"
    sed -i "s/^Exec=.*/Exec=temp-nix-launcher $program/" "$file"
    sed -i '/TryExec/d' "$file"
done < <( find "$tmp" -type f -name '*desktop' )

rsync -vrL "$tmp/applications" share/
