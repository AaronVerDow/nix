Rscript -e 'library(bookdown); render_book()'

cmd=evince
file="$( pwd )/_book/_main.pdf"

[ -f "$file" ] || return 1

pgrep -a $cmd | grep -q "$file" || $cmd "$file" &>> /dev/null &
