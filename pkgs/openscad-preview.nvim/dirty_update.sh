set -x

# Quick script to update package from Jenkins
# Other utilities do not edit file, or do not accept specific commits

file=./default.nix
repo=git@github.com:AaronVerDow/openscad-preview.nvim.git
commit=$1

[ -z "$commit" ] && exit 1

# doesn't support submodules 
hash=$( nurl "$repo" "$commit" --json | jq -r '.args.hash' )

# hash=$( nix-prefetch-git --url https://$repo --rev "$commit" --fetch-submodules --quiet | jq -r '.sha256' )

sed -i "s/rev = \".*\"/rev = \"$commit\"/" "$file"
sed -i "s#sha256 = \".*\"#sha256 = \"$hash\"#" "$file"

# date=$( git --no-pager log -1 --format=%cd --date=short "$commit" )

# assume date is today
date=$( date +%Y-%m-%d )
version="0-unstable-$date"
sed -i "s/version = \".*\"/version = \"$version\"/" "$file"
