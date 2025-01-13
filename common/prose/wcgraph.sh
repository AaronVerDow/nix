uncommitted=0

parse_line() {
    file=$2
    num=$1
    echo "$file" | grep -q '^_' && return
    title=$( title "$file" )
    echo "$title" | grep -q '(PART)' && return # ignore parts
    [ -z "$title" ] && return
    added=$( added "$file" )
    uncommitted=$(( uncommitted + added ))
    removed=$( removed "$file" )
    if ! git ls-files --error-unmatch "$file" &> /dev/null; then
        # handle untracked files
        echo "$title,0,0,$num"
        uncommitted=$(( uncommitted + num ))
        return
    fi
    echo "$title,$removed,$(( num - added )),$added"
}

diff_words() {
    delim=$1
    file=$2
    git diff --word-diff=porcelain origin/main "$file" | grep -e "'^'$delim'[^'$delim']'" | wc -w || true
}

added() {
    diff_words "+" "$1"
}

removed() {
    diff_words "-" "$1"
}

parse() {
    while read -r line; do
        # shellcheck disable=SC2086
        parse_line $line
    done < <( wc --total=never -w ./*.Rmd )
}

graph() {
    wc -w ./*.Rmd --total=never | awk '{ print $2 " " $1 }' | termgraph --color blue
    
    echo -n "Total: "
    wc -w ./*.Rmd --total=only
}

title() {
    grep -m 1 '^# ' "$1" | sed -s 's/^# //' || echo ""
}

thousands() {
    sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'
}

is_valid() {
    ls ./*.Rmd &> /dev/null || return 1
    git rev-parse --is-inside-work-tree &> /dev/null || return 1
}

is_valid || exit 0

# Pipes make subshells.  Using this method so parse can gather data.
tmp=$( mktemp )
parse > "$tmp"
# format displays as integer with commas for thousands
termgraph --color {red,blue,green} --stacked --format "{:,.0f}" "$tmp"
echo ""
echo -n "Uncommitted: "
echo $uncommitted | thousands
echo -n "      Total: "
wc -w ./*.Rmd --total=only | thousands
rm "$tmp"

# graph # | lolcat -F 0.2 -t
