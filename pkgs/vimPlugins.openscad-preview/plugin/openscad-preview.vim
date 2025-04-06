let s:cachedir = stdpath('cache') . '/openscad'
if !isdirectory(s:cachedir)
    call mkdir(s:cachedir, 'p')
endif

let $OPENSCAD_CACHE = s:cachedir
let $VIM_PID = getpid()

let s:plugin_root = expand('<sfile>:p:h:h')  " Goes up two levels from current script
let s:bin_path = s:plugin_root . '/bin/openscad-preview'

" Open preview windows on open
au BufRead *.scad silent exec "!" . s:bin_path . " <afile> > /dev/null 2>&1 &"

" Close preview windows when quitting
au VimLeave *.scad silent exec "!" . s:bin_path . " --kill <afile> > /dev/null 2>&1 &"
