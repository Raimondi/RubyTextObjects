" File:        ftplugin/ruby/rubytextobjects.vim
" Version:     0.1a
" Modified:    2011-00-00
" Description: This ftplugin provides new text objects for Ruby files.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      The new text objects are 'ir' and 'ar'. Place this file in
"              'ftplugin/ruby/' inside $HOME/.vim or somewhere else in your
"              runtimepath.
"              :let testing_RubyTextObjects = 1 to allow reloading of the
"              plugin without closing Vim.
" Pending:     - Use Visual mode instead of Line Visual mode.
"              - Optionally, first ar goes to do..end, second gets the rest of
"                the line.
"              - Ignore multiple statements per line.
" ============================================================================

" Allow users to disable ftplugins
if exists('no_plugin_maps') || exists('no_ruby_maps')
  " User doesn't want this functionality.
  finish
endif

" Mappings {{{1
if !exists('testing_RubyTextObjects')
  " Be nice with existing mappings

  onoremap <silent> <buffer> <expr> <Plug>RubyTextObjectsAll <SID>RubyTextObjectsAll(0)
  if !hasmapto('<Plug>RubyTextObjectsAll', 'o')
    omap <unique> <buffer> ar <Plug>RubyTextObjectsAll
  endif

  onoremap <silent> <buffer> <expr> <Plug>RubyTextObjectsInner <SID>RubyTextObjectsInner(0)
  if !hasmapto('<Plug>RubyTextObjectsInner', 'o')
    omap <unique> <buffer> ir <Plug>RubyTextObjectsInner
  endif

  vnoremap <silent> <buffer> <Plug>RubyTextObjectsAll :call <SID>RubyTextObjectsAll(1)<CR><Esc>gv
  if !hasmapto('<Plug>RubyTextObjectsAll', 'v')
    vmap <unique> <buffer> ar <Plug>RubyTextObjectsAll
  endif

  vnoremap <silent> <buffer> <Plug>RubyTextObjectsInner :call <SID>RubyTextObjectsInner(1)<CR><Esc>gv
  if !hasmapto('<Plug>RubyTextObjectsInner', 'v')
    vmap <unique> <buffer> ir <Plug>RubyTextObjectsInner
  endif
else
  " Unless we are testing, be merciless in this case
  silent! ounmap <buffer> ar
  silent! ounmap <buffer> ir
  silent! vunmap <buffer> ar
  silent! vunmap <buffer> ir
  onoremap <silent> <buffer> <expr> ar <SID>RubyTextObjectsAll(0)
  onoremap <silent> <buffer> <expr> ir <SID>RubyTextObjectsInner(0)
  vnoremap <silent> <buffer> ar :call <SID>RubyTextObjectsAll(1)<CR><Esc>gv
  vnoremap <silent> <buffer> ir :call <SID>RubyTextObjectsInner(1)<CR><Esc>gv
endif

" }}}1

" Variables {{{1
" Lines where this expression returns 1 will be skipped
let s:skip_e  = 'getline(''.'') =~ ''^\s*#'' || synIDattr(synID(line("."), col("."), 0), "name") =~? ''\%(string\)\|\%(comment\)'''

" List of words that start a block at the beginning of the line
let s:beg_words = '<def>|<module>|<class>|<case>|<if>|<unless>|<begin>|<for>|<until>|<while>|<catch>'

" Start of the block matches this
let s:start_p = '\C\v^\s*\zs%('.s:beg_words.')|%(%('.s:beg_words.').*)@<!<do>'

" Middle of the block matches this
let s:middle_p= '\C\v^\s*\zs%(<els%(e|if)>|<rescue>|<ensure>|<when>)'

" End of the block matches this
let s:end_p   = '\C\v^\s*\zs<end>'

" Don't wrap or move the cursor
let s:flags = 'Wn'

" }}}1

" Functions {{{1
" Load guard {{{2
if exists('loaded_RubyTextObjects') && !exists('testing_RubyTextObjects')
  " No need to beyond this twice, unless testing.
  finish
elseif exists('testing_RubyTextObjects')
  echom '----Loaded on: '.strftime("%Y %b %d %X")

  function! Test(test,...) range
    if a:test == 1
      return s:Match(a:firstline, s:start_p).', '.s:Match(a:firstline, s:middle_p).', '.s:Match(a:firstline, s:end_p)
    elseif a:test == 2
      return s:FindTextObject([a:firstline,0], [a:lastline,0], s:middle_p)
    elseif a:test == 3
      return searchpairpos(s:start_p, s:middle_p, s:end_p, a:1, s:skip_e)
    elseif a:test == 4
      return match(getline('.'), 'bWn')
    elseif a:test == 5
      return searchpos(s:start_p,'bn')
    else
      throw 'Ooops!'
    endif
  endfunction
  command! -bar -range -buffer -nargs=+ Test echom string(Test(<f-args>))

endif
let loaded_RubyTextObjects = '0.1a'
 "}}}2

function! s:RubyTextObjectsAll(visual) range "{{{2
  let lastline      = line('$')
  let start         = [0,0]
  let middle_p      = ''
  let end           = [-1,0]
  let count1        = v:count1 < 1 ? 1 : v:count1

  let t_start = [a:firstline + 1, 0]
  let t_end   = [a:lastline  - 1, 0]
  let passes  = 0

  let match_both_outer = (
        \ s:Match(t_start[0] - 1, s:start_p) &&
        \ s:Match(t_end[0] + 1, s:end_p))
  while  count1 > 0 &&
        \ (!(count1 > 1) || (t_start[0] - 1 > 1 && t_end[0] + 1 < lastline))
    let passes  += 1

    " Let's get some luv
    let [t_start, t_end] = s:FindTextObject([t_start[0] - 1, 0], [t_end[0] + 1, 0], middle_p)

    "echom string(t_start).';'.string(t_end).':'.passes
    if t_start[0] > 0 && t_end[0] > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    " Repeat if necessary
    if match_both_outer && passes == 1 &&
          \ start[0] == a:firstline && end[0] == a:lastline
      continue
    endif
    let count1  -= 1
  endwhile

  if a:visual
    if end[0] >= start[0] && start[0] >= 1 && end[0] >= 1
      " Do visual magic
      exec "normal! \<Esc>"
      call cursor(start)
      exec "normal! v".end[0]."G$h"
      "echom string(start).';'.string(end).':'.passes
    endif
  else
    if end[0] >= start[0] && start[0] >= 1 && end[0] >= 1
      " Do operator pending magic
      "echom getline(start[0])[:start[1] - 2]
      if start[1] <= 1 || getline(start[0])[:start[1] - 2] =~ '^\s*$'
        " Delete whole lines
        let to_eol   = '$'
        let from_bol = '0'
      else
        " Don't delete text behind start of block and leave one <CR>
        let to_eol   = '$h'
        let from_bol = ''
      endif
      return ':call cursor('.string(start).')|exec "normal! '.from_bol.'v'.end[0]."G".to_eol."\"\<CR>"
    else
      " No pair found, do nothing
      return "\<Esc>"
    endif
  endif

endfunction " }}}2

function! s:RubyTextObjectsInner(visual) range "{{{2
  let lastline      = line('$')
  let start         = [0,0]
  let middle_p      = s:middle_p
  let end           = [-1,0]
  let count1        = v:count1 < 1 ? 1 : v:count1
  let initial       = [a:firstline, a:lastline]

  " If called from visual mode, find out if it looks like a recursive ir and
  " if a whole block is selected
  let is_rec      = 0
  let is_block    = 0
  let first_TO = s:FindTextObject([a:firstline, 0],[a:lastline, 0], middle_p)
  if [[a:firstline, first_TO[0][1]],[a:lastline, first_TO[1][1]]] == first_TO
    " It is a whole block
    let is_block = 1
  endif
  if getpos("'<")[2] == 1 &&
        \ getpos("'>")[2] == len(getline(getpos("'>")[1])) + 1 &&
        \ visualmode() == 'v'
    " It looks recursive
    if is_block
      " It is recursive, with a whole block
      let is_rec = 2
    elseif [[a:firstline - 1, first_TO[0][1]],[a:lastline + 1, first_TO[1][1]]] == first_TO
      " It is recursive, with an inner block
      let is_rec = 1
    endif
  endif

  let [t_start, t_end] = first_TO
  let [start, end] = first_TO
  let passes  = 0

  let one_more = ((is_block && [start[0], end[0]] == initial) || is_rec) && a:visual
  if one_more && is_rec == 2
    let t_start[0] -= 1
    let t_end[0]   += 1
  endif
  "echom '[is_rec, is_block]: ['.is_rec.', '.is_block.'], t_start, t_end: '.t_start[0].', '.t_end[0] .', first_TO: '.string(first_TO).', one_more: '.one_more
  while  (count1 > 1 || one_more) && first_TO != [[0,0],[0,0]] &&
        \ (!(count1 > 1) || (t_start[0] - 1 >= 1 && t_end[0] + 1 < lastline))

    let passes  += 1
    let [t_start, t_end] = s:FindTextObject([t_start[0] - 1, 0], [t_end[0] + 1, 0], s:middle_p)
    "echom 't_start, t_end: '.string(t_start).','.string(t_end).':'.passes

    "echom string(t_start).';'.string(t_end).':'.passes
    if t_start[0] > 0 && t_end[0] > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    "echom 'initial: '.string(initial).', final: ['.(start[0]).', '.(end[0]).']'
    if one_more
      let one_more = 0
      continue
    endif
    let count1  -= 1
  endwhile

  if a:visual
    if end[0] >= start[0] && start[0] >= 1 && end[0] >= 1 && end[0] - start[0] > 1
      " Do visual magic
      exec "normal! \<Esc>".(start[0] + 1).'G'
      exec "normal! 0v".(end[0] - 1)."G$"
      "echom string(start).';'.string(end).':'.passes
    endif
  else
    if end[0] >= start[0] && start[0] >= 1 && end[0] >= 1 && end[0] - start[0] > 1
      " Do operator pending magic
      return ':exec "normal! '.(start[0] + 1).'G0v'.(end[0] - 1)."G$\"\<CR>"
    else
      " No pair found, do nothing
      return "\<Esc>"
    endif
  endif

endfunction " }}}2

function! s:FindTextObject(first, last, middle) "{{{2

  let first = {'start':[0,0], 'end':[0,0], 'range':0}
  let last  = {'start':[0,0], 'end':[0,0], 'range':0}

  if a:first[0] == a:last[0] " Range is the current line {{{3
    " searchpair() starts looking at the cursor position. Find out where that
    " should be. Also determine if the current line should be searched.
    if s:Match(a:first[0], s:end_p)
      let spos   = 1
      let sflags = s:flags.'b'
    else
      let spos   = 9999
      let sflags = s:flags.'bc'
    endif

    " Let's see where they are
    call cursor(a:first[0], spos)
    let first.start  = searchpairpos(s:start_p,a:middle,s:end_p,sflags,s:skip_e)

    if s:Match(a:first[0], s:start_p)
      let epos   = 9999
      let eflags = s:flags
    else
      let epos   = 1
      let eflags = s:flags.'c'
    endif

    " Let's see where they are
    call cursor(a:first[0], epos)
    let first.end    = searchpairpos(s:start_p,a:middle,s:end_p,eflags,s:skip_e)

    let result = [first.start, first.end]

  else " Range is not the current line {{{3

    " Let's find a set with the first line of the range
    if s:Match(a:first[0], s:end_p)
      let spos   = 1
      let sflags = s:flags.'b'
    else
      let spos   = 9999
      let sflags = s:flags.'bc'
    endif

    if s:Match(a:first[0], s:start_p)
      let epos   = 9999
      let eflags = s:flags
    else
      let epos   = 1
      let eflags = s:flags.'c'
    endif

    call cursor(a:first[0], spos)
    let first.start  = searchpairpos(s:start_p,a:middle,s:end_p,sflags,s:skip_e)
    call cursor(a:first[0], epos)
    let first.end    = searchpairpos(s:start_p,a:middle,s:end_p,eflags,s:skip_e)
    let first.range  = first.end[0] - first.start[0]

    " Let's find the second set with the last line of the range
    if s:Match(a:last[0], s:end_p)
      let spos   = 1
      let sflags = s:flags.'b'
    else
      let spos   = 9999
      let sflags = s:flags.'bc'
    endif

    if s:Match(a:last[0], s:start_p)
      let epos   = 9999
      let eflags = s:flags
    else
      let epos   = 1
      let eflags = s:flags.'c'
    endif

    call cursor(a:last[0], spos)
    let last.start  = searchpairpos(s:start_p,a:middle,s:end_p,sflags,s:skip_e)
    call cursor(a:last[0], epos)
    let last.end    = searchpairpos(s:start_p,a:middle,s:end_p,eflags,s:skip_e)
    let last.range  = last.end[0] - last.start[0]

    " Now, decide what to return
    if first.range > last.range
      if first.start[0] <= last.start[0] && first.end[0] >= last.end[0]
        " last is inside first
        let result = [first.start, first.end]
      elseif last.range == 0
        " Last is null
        let result = [first.start, first.end]
      else
        " Something is wrong, last is not inside first
        let result = [[0,0],[0,0]]
      endif
    elseif first.range < last.range
      if first.start[0] >= last.start[0] && first.end[0] <= last.end[0]
        " first is inside last
        let result = [last.start, last.end]
      elseif first.range == 0
        " first is null
        let result = [last.start, last.end]
      else
        " Something is wrong, first is not inside last
        let result = [[0,0],[0,0]]
      endif
    else
      if first.start[0] == last.start[0]
        " first and last are the same
        let result = [first.start, first.end]
      else
        " first and last are not the same
        let result = [a:first, a:last]
      endif
    endif
  endif "}}}3

  "echom string(result) . ', first: ' . string(first) . ', last' .
  "      \ string(last) . ', epos: ' . epos . ', spos: ' . spos .
  "      \ ', sflags: ' . sflags . ', eflags: ' . eflags

  return result

endfunction "}}}2

function! s:Match(line, part) " {{{2
  call cursor(a:line, 1)
  let result = search(a:part, 'cW', a:line) > 0 && !eval(s:skip_e)
  "echom result
  return result
endfunction " }}}2
