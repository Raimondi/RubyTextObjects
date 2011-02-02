" File:        ftplugin/ruby/rubytextobjects.vim
" Version:     0.1a
" Modified:    2011-00-00
" Description: This ftplugin provides new text objects for Ruby files.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      The new text objects are 'ir' and 'ar'. Place this file in
"              'ftplugin/ruby/' inside $HOME/.vim or somewhere else in your
"              runtimepath.
"
"              :let testing_RubyTextObjects = 1 to allow reloading of the
"              plugin without closing Vim.
"
"              Multiple sentences on a single line are not handled by this
"              plugin, the text objects might not work or work in an
"              unexpected way.
"
" Pending:     - Optionally, first ar goes to do..end, second gets the rest of
"                the start of the block, if any.
" ============================================================================

" Allow users to disable ftplugins
if exists('no_plugin_maps') || exists('no_ruby_maps')
  " User doesn't want this functionality.
  finish
endif

" Mappings {{{1

let s:undo_ftplugin =
      \ 'sil! ounmap <buffer> ar|sil! ounmap <buffer> ir|'.
      \ 'sil! vunmap <buffer> ar|sil! vunmap <buffer> ir'
if exists('b:undo_ftplugin') && b:undo_ftplugin !~ 'vunmap <buffer> ar'
  if b:undo_ftplugin =~ '^\s*$'
    let b:undo_ftplugin = s:undo_ftplugin
  else
    let b:undo_ftplugin = s:undo_ftplugin.'|'.b:undo_ftplugin
  endif
elseif !exists('b:undo_ftplugin')
  let b:undo_ftplugin = s:undo_ftplugin
endif

onoremap <silent> <buffer> <expr> <Plug>RubyTextObjectsAll
      \ <SID>RubyTextObjectsAll(0)
onoremap <silent> <buffer> <expr> <Plug>RubyTextObjectsInner
      \ <SID>RubyTextObjectsInner(0)
vnoremap <silent> <buffer> <Plug>RubyTextObjectsAll :call
      \ <SID>RubyTextObjectsAll(1)<CR><Esc>gv
vnoremap <silent> <buffer> <Plug>RubyTextObjectsInner :call
      \ <SID>RubyTextObjectsInner(1)<CR><Esc>gv

if !exists('testing_RubyTextObjects')
  " Be nice with existing mappings

  if !hasmapto('<Plug>RubyTextObjectsAll', 'o')
    omap <unique> <buffer> ar <Plug>RubyTextObjectsAll
  endif

  if !hasmapto('<Plug>RubyTextObjectsInner', 'o')
    omap <unique> <buffer> ir <Plug>RubyTextObjectsInner
  endif

  if !hasmapto('<Plug>RubyTextObjectsAll', 'v')
    vmap <unique> <buffer> ar <Plug>RubyTextObjectsAll
  endif

  if !hasmapto('<Plug>RubyTextObjectsInner', 'v')
    vmap <unique> <buffer> ir <Plug>RubyTextObjectsInner
  endif
else
  " Unless we are testing, be merciless in this case
  silent! ounmap <buffer> ar
  silent! ounmap <buffer> ir
  silent! vunmap <buffer> ar
  silent! vunmap <buffer> ir
  omap <silent> <buffer> ar <Plug>RubyTextObjectsAll
  omap <silent> <buffer> ir <Plug>RubyTextObjectsInner
  vmap <silent> <buffer> ar <Plug>RubyTextObjectsAll
  vmap <silent> <buffer> ir <Plug>RubyTextObjectsInner
endif

" }}}1

" Variables {{{1
" Lines where this expression returns 1 will be skipped
" Expression borrowed from default ruby ftplugin
let s:skip_e =
      \ "synIDattr(synID(line('.'),col('.'),0),'name') =~ '"            .
      \ "\\<ruby\\%(String\\|StringDelimiter\\|ASCIICode\\|Escape\\|"   .
      \ "Interpolation\\|NoInterpolation\\|Comment\\|Documentation\\|"  .
      \ "ConditionalModifier\\|RepeatModifier\\|OptionalDo\\|"          .
      \ "Function\\|BlockArgument\\|KeywordAsMethod\\|ClassVariable\\|" .
      \ "InstanceVariable\\|GlobalVariable\\|Symbol\\)\\>'"

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

  function! Test(first, last, test,...)
    if a:test == 1
      return s:Match(a:first, s:start_p).', '.s:Match(a:first, s:middle_p).', '.s:Match(a:first, s:end_p)
    elseif a:test == 2
      return s:FindTextObject([a:first,0], [a:last,0], s:middle_p)
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
  command! -bar -range -buffer -nargs=+ Test echom string(Test(<line1>, <line2>, <f-args>))
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

function! s:RubyTextObjectsInner(visual, ...) range "{{{2
  " Recursing?
  if a:0
    let firstline = a:1
    let lastline  = a:2
    let count1    = a:3 - 1
    let original  = [[firstline, 1], [lastline, len(getline(lastline)) + 1]]
  else
    let firstline = a:firstline
    let lastline  = a:lastline
    let count1    = v:count1 < 1 ? 1 : v:count1
    let original  = [getpos("'<")[1:2], getpos("'>")[1:2]]
  endif
  let line_eof    = line('$')
  let current     = {'start': [firstline,0], 'end': [lastline,0]}
  let middle_p    = s:middle_p
  let l:count     = 0
  let d_start     = 0
  let d_end       = 0
  let i           = 0

  while i <= 2 && (current.start[0] + d_start) > 0 && (current.end[0] + d_end) <= line_eof
    let i += 1
    " Get a text object
    let [current.start, current.end] = s:FindTextObject(
          \ [current.start[0] + d_start, 0], [current.end[0] + d_end, 0], middle_p)
    "echom 'Current: '.string(current).', count: '.i
    " If it's null, stop looking
    if [current.start, current.end] == [[0,0],[0,0]]
      break
    endif
    let is_block = 0
    if [firstline, lastline] == [current.start[0], current.end[0]]
      " The original selection's range is the same as the one from the text
      " object.
      " It is a whole block
      let is_block = 1
    endif
    let is_repeat = 0
    " Find out what to do {{{
    " If:
    " - Is visual? AND
    "   - Is repeated? OR
    "   - Is the selection a previously selected text block?
    if a:visual
          \ && (a:0
          \     || (original[0][1] == 1
          \         && original[1][1] >= len(getline(getpos("'>")[1])) + 1))

      " Determine what is selected
      if getline(firstline - 1) =~ s:middle_p ||
            \ getline(lastline + 1) =~ s:middle_p
        " The line over and/or under matches a s:middle_p
        if !is_block
          " It is repeated with an inner middle block
          let is_repeat = 4
          let middle_p = ''
          let d_start  = 0
          let d_end    = 0
        else
          " It is repeated with an inner middle block and a whole block
          let is_repeat = 3
          let middle_p = ''
          let d_start  = -1
          let d_end    = 1
        endif
      elseif [firstline - 1, lastline + 1] == [current.start[0], current.end[0]]
        " The text object limits are just over and under the original
        " selection
        " It is repeated, with an inner block
        let is_repeat = 2
        let d_start  = -1
        let d_end    = 1
      elseif is_block
        " It is repeated, with a whole block
        let is_repeat = 1
        let d_start  = -1
        let d_end    = 1
      endif
    endif "}}}
    "echom 'is_repeat: '.is_repeat.', is_block: '.is_block

    if is_repeat == 0
      " No need to loop
      break
    endif
  endwhile

  "echom 'Current: '.string(current).', count1: '.count1
  if count1 > 1
    " Let's recurse
    let current = s:RubyTextObjectsInner(a:visual, current.start[0] + 1, current.end[0] - 1, count1)
  endif
  if a:0
    return current
  endif
  if a:visual
    if current.end[0] >= current.start[0] && current.start[0] >= 1 && current.end[0] >= 1 && current.end[0] - current.start[0] > 1
      " Do visual magic
      exec "normal! \<Esc>".(current.start[0] + 1).'G'
      exec "normal! 0v".(current.end[0] - 1)."G$"
    endif
  else
    if current.end[0] >= current.start[0] && current.start[0] >= 1 && current.end[0] >= 1 && current.end[0] - current.start[0] > 1
      " Do operator pending magic
      return ':exec "normal! '.(current.start[0] + 1)
            \ .'G0v'.(current.end[0] - 1)."G$\"\<CR>"
    else
      " No pair found, do nothing
      return "\<Esc>"
    endif
  endif
endfunction "}}}2

function! s:FindTextObject(first, last, middle, ...) "{{{2
  if a:0
    let l:count = a:1 + 1
  else
    let l:count = 1
  endif
  "echom 'FTO count: '.l:count
  if a:first[0] > a:last[0]
    throw 'Muy mal... a:first > a:last'
  endif
  "echom 'Range : '.string([a:first, a:last])

  let first = {'start':[0,0], 'end':[0,0], 'range':0}
  let last  = {'start':[0,0], 'end':[0,0], 'range':0}

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

  if a:middle == ''
    let s_match = s:Match(a:first[0], s:start_p)
  else
    let s_match = s:Match(a:first[0], s:start_p) || s:Match(a:first[0], a:middle)
  endif
  if s_match
    let epos   = 9999
    let eflags = s:flags
  else
    let epos   = 1
    let eflags = s:flags.'c'
  endif

  " Let's see where they are
  call cursor(a:first[0], epos)
  let first.end    = searchpairpos(s:start_p,a:middle,s:end_p,eflags,s:skip_e)

  "echom 'First : '.string([first.start, first.end])
  if a:first == a:last
    let result = [first.start, first.end]
  else
    let [last.start, last.end] = s:FindTextObject(a:last, a:last, a:middle, l:count)
    "echom 'Last  : '.string([last.start, last.end])

    let first.range  = first.end[0] - first.start[0]
    let last.range   = last.end[0] - last.start[0]
    if first.end[0] <= last.start[0] &&
          \ (getline(first.end[0])  =~ s:middle_p && first.range > 0) &&
          \ (getline(last.start[0]) =~ s:middle_p && last.range  > 0)
      " Looks like a middle inner match, start over without looking for
      " s:middle_p
      let result = s:FindTextObject(a:first, a:last, '', 1)

    else
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
          "let result = [a:first, a:last]
          let result = [[0,0],[0,0]]
        endif
      endif

    endif
  endif
  "echom 'Result: '.string(result) . ', first: ' . string(first) . ', last' .
        \ string(last). ', spos: ' . spos . ', sflags: ' . sflags . ', epos: ' . epos . ', eflags: ' . eflags. '. middle_p: '.a:middle
  return result

endfunction "}}}2

function! s:Match(line, part) " {{{2
  call cursor(a:line, 1)
  let result = search(a:part, 'cW', a:line) > 0 && !eval(s:skip_e)
  "echom result
  return result
endfunction " }}}2

" vim: set et sw=2 sts=2: {{{1
