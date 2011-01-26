" These paths work only if the tests scripts's repos are in the same folder as
" this repo.
let &runtimepath = expand('<sfile>:p:h:h:h').'/runVimTests,'.&rtp
let &runtimepath = expand('<sfile>:p:h:h:h').'/vimtap,'.&rtp
let &runtimepath = expand('<sfile>:p:h:h').','.&rtp
