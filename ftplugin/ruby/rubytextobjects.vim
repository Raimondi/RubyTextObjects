" File:        ftplugin/ruby/rubytextobj.vim
" Version:     0.1a
" Modified:    2011-01-00
" Description: This ftplugin provides new text objects for Ruby.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      The new text objects are 'ir' and 'ar'. Place this file in
"              'ftplugin/ruby/' inside $HOME/.vim or somewhere else in your
"              runtimepath.
" ============================================================================

" Mappings {{{1
if exists('no_plugin_maps') || exists('no_ruby_maps')
  " User doesn't want this functionality.
  finish
endif

if !exists('testing_RubyTextObj')
  " Be nice with existing mappings

  onoremap <silent> <buffer> <expr> <Plug>RubyTextObjAll <SID>RubyTxtObjOuter(0)
  if !hasmapto('<Plug>RubyTextObjAll', 'o')
    omap <unique> <buffer> ar <Plug>RubyTextObjAll
  endif

  onoremap <silent> <buffer> <expr> <Plug>RubyTextObjIn <SID>RubyTxtObjInner(0)
  if !hasmapto('<Plug>RubyTextObjIn', 'o')
    omap <unique> <buffer> ir <Plug>RubyTextObjIn
  endif

  vnoremap <silent> <buffer> <Plug>RubyTextObjAll :call <SID>RubyTxtObjOuter(1)<CR><Esc>gv
  if !hasmapto('<Plug>RubyTextObjAll', 'v')
    vmap <unique> <buffer> ar <Plug>RubyTextObjAll
  endif

  vnoremap <silent> <buffer> <Plug>RubyTextObjIn :call <SID>RubyTxtObjInner(1)<CR><Esc>gv
  if !hasmapto('<Plug>RubyTextObjIn', 'v')
    vmap <unique> <buffer> ir <Plug>RubyTextObjIn
  endif
else
  " Unless we are testing, be merciless in this case
  onoremap <silent> <buffer> <expr> ar <SID>RubyTxtObjOuter(0)
  onoremap <silent> <buffer> <expr> ir <SID>RubyTxtObjInner(0)
  vnoremap <silent> <buffer> ar :call <SID>RubyTxtObjOuter(1)<CR><Esc>gv
  vnoremap <silent> <buffer> ir :call <SID>RubyTxtObjInner(1)<CR><Esc>gv
endif

" }}}1

" Some shared variables {{{1
" Lines where this expression returns 1 will be skipped
let s:skip_e  = 'getline(''.'') =~ ''^\s*#'' || synIDattr(synID(line("."), col("."), 0), "name") =~? ''\%(string\)\|\%(comment\)'''

" Start of the block matches this
let s:start_p = '\%(\<def\>\|\<do\>\|\<module\>\|\<class\>\|\<case\>\|\%(^\|;\)\s*\%(\<if\>\|\<unless\>\|\<begin\>\|\<catch\>\|\<until\>\|\<while\>\|\<for\>\)\)'

" Middle of the block matches this
let s:middle_p= '\%(^\|;\)\s*\%(\<els\%(e\|if\)\>\|\<rescue\>\|\<ensure\>\|\<when\>\)'

" End of the block matches this
let s:end_p   = '\%(^\|;\)\s*\<end\>'

" Don't wrap or move the cursor
let s:flags = 'Wn'

" }}}1

" Load guard for functions {{{1
if exists('loaded_RubyTextObj') && !exists('testing_RubyTextObj')
  " No need to beyond this twice, unless testing.
  finish
elseif exists('testing_RubyTextObj')
  echom '----Loaded on: '.strftime("%Y %b %d %X")

  function! Test() range " {{{2
    return s:Match(a:firstline, 'start').', '.s:Match(a:firstline, 'middle').', '.s:Match(a:firstline, 'end')
    "  return s:FindTextObject(a:firstline, a:lastline, s:start_p, s:middle_p,
    "        \s:end_p, s:flags, s:skip_e)
  endfunction " }}}2

endif
let loaded_RubyTextObj = '0.1a'
 "}}}1

function! s:RubyTxtObjOuter(visual) range "{{{1
  let lastline      = line('$')
  let start         = 0
  let middle_p      = ''
  let end           = -1
  let count1        = v:count1
  let visual        = visualmode() ==# 'V'

  let t_start = a:firstline + 1
  let t_end   = a:lastline  - 1
  let passes  = 0

  let match_both_outer = (
        \ s:Match(t_start - 1, 'start') &&
        \ s:Match(t_end + 1, 'end'))
  while  count1 > 0 &&
        \ (!(count1 > 1) || (t_start - 1 > 1 && t_end + 1 < lastline))
    let passes  += 1
    let t_start -= 1
    let t_end   += 1

    let [t_start, t_end] = s:FindTextObject(t_start, t_end, s:start_p, middle_p,
          \ s:end_p, s:flags, s:skip_e)

    if t_start > 0 && t_end > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    if match_both_outer &&
          \ start == a:firstline && end == a:lastline && passes == 1
      continue
    endif
    let count1  -= 1
  endwhile

  if a:visual
    if end >= start && start >= 1 && end >= 1
      " Do magic
      exec "normal! \<Esc>".start.'G0V'.end."G"
    endif
  else
    if end >= start && start >= 1 && end >= 1
      " Do magic
      return ':exec "normal! '.start.'G0V'.end."G\"\<CR>"
    else
      " No pair found, do nothing
      return "\<Esc>"
    endif
  endif

endfunction " }}}1

function! s:RubyTxtObjInner(visual) range "{{{1
  let lastline      = line('$')
  let start         = 0
  let middle_p      = s:middle_p
  let end           = -1
  let count1        = v:count1
  let visual        = a:visual ? visualmode() ==# 'V' : 0

  let t_start = a:firstline
  let t_end   = a:lastline
  let passes  = 0

  let match_both_outer = (
        \ s:Match(t_start - 1, 'start') &&
        \ s:Match(t_end + 1, 'end'))
  let start_matches = s:Match(t_start, 'start')
  let middle_matches= s:Match(a:firstline, 'm')
  let end_matches   = s:Match(t_end, 'e')

  while  count1 > 0 &&
        \ (!(count1 > 1) || (t_start - 1 > 1 && t_end + 1 < lastline))
    let passes += 1

    " If a middle pattern is matched, use it as start
    if passes == 1 && middle_matches
      let t_end   += 1
    elseif passes > 1 || (!start_matches && !end_matches) || visual
      let t_start -= 1
      let t_end   += 1
    endif

    let [t_start, t_end] = s:FindTextObject(t_start, t_end, s:start_p,
          \ s:middle_p, s:end_p, s:flags, s:skip_e)

    if t_start > 0 && t_end > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    if match_both_outer &&
          \ start == (a:firstline - 1) && end == (a:lastline + 1) &&
          \ passes == 1 && visual
      continue
    endif
    let count1  -= 1
  endwhile

  if (end - start) > 1
    " There is an inner section, use it
    let start += 1
    let end   -= 1
  else
    " There is no inner section, nothing to do
    let start = 0
    let end = 0
  endif

  if a:visual
    if end >= start && start >= 1 && end >= 1
      " Do magic for visual mapping
      exec "normal! \<Esc>".start.'G0V'.end."G"
    endif
  else
    if end >= start && start >= 1 && end >= 1
      " Do magic for operator pending mapping
      return ':exec "normal! '.start.'G0V'.end."G\"\<CR>"
    else
      " No pair found, cancel operator
      return "\<Esc>"
    endif
  endif
endfunction "}}}1

function! s:FindTextObject(first, last, start, middle, end, flags, skip) "{{{1

  let first = {'start':0, 'end':0, 'range':0}
  let last  = {'start':0, 'end':0, 'range':0}

  if a:first == a:last " Range is the current line {{{2
    " searchpair() starts looking at the cursor position. Find out where that
    " should be. Also determine if the current line should be searched.
    if s:Match(a:first, 'e')
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if s:Match(a:first, 's')
      let epos   = 9999
      let eflags = a:flags
    else
      let epos   = 1
      let eflags = a:flags.'c'
    endif

    " Let's see where they are
    call cursor(a:first, spos)
    let first.start  = searchpair(a:start,a:middle,a:end,sflags,a:skip)
    call cursor(a:first, epos)
    let first.end    = searchpair(a:start,a:middle,a:end,eflags,a:skip)

    let result = [first.start, first.end]

  else " Range is not the current line {{{2

    " Let's find a set with the first line of the range
    if s:Match(a:first, 'e')
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if s:Match(a:first, 's')
      let epos   = 9999
      let eflags = a:flags
    else
      let epos   = 1
      let eflags = a:flags.'c'
    endif

    call cursor(a:first, spos)
    let first.start  = searchpair(a:start,a:middle,a:end,sflags,a:skip)
    call cursor(a:first, epos)
    let first.end    = searchpair(a:start,a:middle,a:end,eflags,a:skip)
    let first.range  = first.end - first.start

    " Let's find the second set with the last line of the range
    if s:Match(a:last, 'e')
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if s:Match(a:last, 's')
      let epos   = 9999
      let eflags = a:flags
    else
      let epos   = 1
      let eflags = a:flags.'c'
    endif

    call cursor(a:last, spos)
    let last.start  = searchpair(a:start,a:middle,a:end,sflags,a:skip)
    call cursor(a:last, epos)
    let last.end    = searchpair(a:start,a:middle,a:end,eflags,a:skip)
    let last.range  = last.end - last.start

    " Now, decide what to return
    if first.range > last.range
      if first.start <= last.start && first.end >= last.end
        " last is inside first
        let result = [first.start, first.end]
      else
        " Something is wrong, last is not inside first
        let result = [0,0]
      endif
    elseif first.range < last.range
      if first.start >= last.start && first.end <= last.end
        " first is inside last
        let result = [last.start, last.end]
      else
        " Something is wrong, first is not inside last
        let result = [0,0]
      endif
    else
      let result = [first.start, first.end]
    endif
  endif "}}}2

  "echom string(result) . ', first: ' . string(first) . ', last' .
  "      \ string(last) . ', epos: ' . epos . ', spos: ' . spos .
  "      \ ', sflags: ' . sflags . ', eflags: ' . eflags

  return result

endfunction "}}}1

function! s:Match(line, part) " {{{1
  call cursor(a:line, 1)
  if a:part =~ '\ms\%[tart]'
    call search(s:start_p, 'cW', a:line)
    let result = getline('.') =~# s:start_p && !eval(s:skip_e)
  elseif a:part =~ '\mm\%[iddle]'
    call search(s:middle_p, 'cW', a:line)
    let result = getline('.') =~# s:middle_p && !eval(s:skip_e)
  elseif a:part =~ '\me\%[nd]'
    call search(s:end_p, 'cW', a:line)
    let result = getline('.') =~# s:end_p && !eval(s:skip_e)
  else
    throw 'Oops!'
  endif
  "echom result
  return result
endfunction " }}}1
