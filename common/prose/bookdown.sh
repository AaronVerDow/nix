{
while [ ! -f index.Rmd ] && [ -n "$(git rev-parse --show-toplevel 2>/dev/null)" ]; do
  cd ..
done

if [ ! -f index.Rmd ]; then
  echo "Error: index.Rmd not found" >&2
  exit 1
fi

Rscript -e 'library(bookdown); render_book()'

pdf="$( pwd )/_book/_main.pdf"
cmd=evince
if [ -f "$pdf" ]; then
  pgrep -a $cmd | grep -q "$pdf" || $cmd "$pdf" &>> /dev/null &
fi
}
