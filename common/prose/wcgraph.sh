width=40 # default of 50
uncommitted=0

parse_line() {
    file=$2
    num=$1
    echo "$file" | grep -q '/_' && return # auto generated bookdown files
    echo "$file" | grep -q '/zzz' && return # used for appendix
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
    git diff --word-diff=porcelain origin/main "$file" | grep -e "^${delim}[^$delim]" | wc -w || true
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

file_number() {
    basename "$1" | grep -o '^[0-9]*' || echo ""
}

chapter_title() {
    grep -m 1 '^# ' "$1" | sed -s 's/^# //' || echo ""
}

title() {
    file_number=$( file_number "$1" )
    chapter_title=$( chapter_title "$1" )
    if [ -z "$file_number" ]; then
        echo "$chapter_title"
    else
        echo "$file_number $chapter_title"
    fi
}

thousands() { 
    sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'
}

is_valid() {
    ls ./*.Rmd &> /dev/null || return 1
    [ -f ./index.Rmd ] || return 1 # used with bookdown
    git rev-parse --is-inside-work-tree &> /dev/null || return 1
}

bold() {
    printf "\033[1m%s\033[0m" "$*"
}

book_title() {
    grep '^title' index.Rmd | yq '.title' -r
}

is_valid || exit 0

# Pipes make subshells.  Using this method so parse can gather data.
tmp=$( mktemp )
parse > "$tmp"
bold "$( book_title )"
# format displays as integer with commas for thousands
termgraph --width $width --color {red,blue,green} --stacked --format "{:,.0f}" "$tmp"
echo ""
if [ "$uncommitted" -gt 0 ]; then
    echo -n "Uncommitted: "
    echo $uncommitted | thousands
fi
echo -n "      Total: "
find ./ -maxdepth 1 -name '*.Rmd' -not -path './_*' -exec cat {} + | wc -w | thousands
rm "$tmp"
