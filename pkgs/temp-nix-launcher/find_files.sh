set -euo pipefail
set -x
program=$1

find $( find /nix/store -maxdepth 1 | grep $program ) -type f | egrep '(share/applications|share/icon)'
