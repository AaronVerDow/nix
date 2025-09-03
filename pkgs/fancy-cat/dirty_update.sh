set -x

# Quick script to update package from Jenkins
# Other utilities do not edit file, or do not accept specific commits

file=./default.nix
repo=github.com:AaronVerDow/fancy-cat.git
commit=$1

hash=$( nurl "$repo" "$commit" --json | jq -r '.args.hash' )

sed -i "s/rev = \".*\"/rev = \"$commit\"/" "$file"
sed -i "s#hash = \".*\"#hash = \"$hash\"#" "$file"

# date=$( git --no-pager log -1 --format=%cd --date=short "$commit" )

# assume date is today
date=$( date +%Y-%m-%d )
version="0-unstable-$date"
sed -i "s/version = \".*\"/version = \"$version\"/" "$file"
