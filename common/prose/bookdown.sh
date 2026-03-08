Rscript -e 'library(bookdown); render_book()'

cmd=evince
# cmd=fancy-cat
pdf="$( pwd )/_book/_main.pdf"
# html="$( pwd )/_book/index.html"

if [ -f "$pdf" ]; then
    pgrep -a $cmd | grep -q "$pdf" || $cmd "$pdf" &>> /dev/null &
fi
